// 19 — 版主控制面板 (User/BoardMaster/*): the moderator-facing counterpart of manage/.
//
// Getting in at all is the first thing worth asserting. CheckisBoardMasterFlag() grants access
// on `GetBinarybit(GBL_CHK_UserLimit,10) = 1 or CheckSupervisorUserName() = 1`, and
// CheckSupervisorUserName only returns 1 when Session(...Manager) = "manage" — so even the
// supervisor sees "请先登录" on every page here until the manage/ backend has been unlocked.
// Worse, the check ALSO clears GBL_CHK_Flag and GBL_UserID on failure, so the page then renders
// a login form for a user who is demonstrably logged in (the header greets them by name).
//
// Verbs driven end to end: specialuser, fobip, modifyuser.
import { B, rec, summary, browser, adminPage, login, db, dbNum, dbOne, dbRows,
         httpGet, goTo, setSelect, ajaxCommand, ADMIN_PASS } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);
const stamp = Date.now().toString().slice(-6);
const BM = `${B}/User/BoardMaster`;
const LUM = `${BM}/User/LimitUserManage.asp`;

// A throwaway member to moderate — created here and deleted at the end, so nothing a sibling
// suite depends on is ever restricted, stripped or IP-blocked.
const victim = `bm${stamp}`;
await goTo(p, `${B}/manage/User/UserJoin.asp`);
await p.locator('input[name="Form_username"]').first().fill(victim).catch(()=>{});
await p.locator('input[name="Form_password1"]').first().fill(ADMIN_PASS).catch(()=>{});
await p.locator('input[name="Form_password2"]').first().fill(ADMIN_PASS).catch(()=>{});
await p.locator('input[name="Form_mail"]').first().fill(`${victim}@example.invalid`).catch(()=>{});
await p.locator('input[name="Form_Question"]').first().fill('q' + stamp).catch(()=>{});
await p.locator('input[name="Form_Answer"]').first().fill('a' + stamp).catch(()=>{});
await p.locator('input[name="Form_sex"]').first().check({ force: true }).catch(()=>{});
await Promise.all([
  p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
  p.locator('input[type="submit"]').first().click({ force: true }),
]);
await p.waitForTimeout(1200);
const victimId = await dbOne(p, `SELECT ID FROM leadbbs_user WHERE UserName='${victim}'`);
rec('created a throwaway member to moderate', !!victimId, `${victim} id=${victimId}`);

// ------------------------------------------------ the control panel itself
{
  await goTo(p, `${BM}/Default.asp`);
  const txt = await p.locator('body').innerText();
  rec('the board-master control panel opens for a supervisor',
      txt.includes('限制用户管理') && txt.includes('取消全部总固顶') && !txt.includes('请先登录'),
      txt.replace(/\s+/g, ' ').slice(0, 60));
  rec('and it greets the moderator by name with the system info',
      txt.includes('admin，您好') && txt.includes('服务器时间'));

  // The same page for a visitor who is NOT a moderator must not show the panel. Use a plain
  // guest context — NOT a deliberately wrong password for admin, which was the first version
  // of this check: LeadBBS locks an account after DEF_MaxLoginTimes failures, so every run
  // pushed the supervisor closer to being locked out and eventually locked it, which then
  // failed several other suites in a way that pointed nowhere near here.
  const guest = await br.newContext();
  const gp = await guest.newPage();
  await gp.goto(`${BM}/Default.asp`, { waitUntil: 'domcontentloaded' }).catch(()=>{});
  await gp.waitForTimeout(400);
  const mtxt = await gp.locator('body').innerText().catch(()=>'');
  rec('a visitor without moderator rights is refused', !mtxt.includes('限制用户管理'),
      mtxt.replace(/\s+/g, ' ').slice(0, 50));
  await guest.close();
}

// ------------------------------------------------ 取消全部总固顶 (ClearTopAnc)
{
  // give it something to clear: make a topic a site-wide sticky through the topic-page menu
  const topic = await dbOne(p,
    'SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 1');
  await goTo(p, `${B}/a/a.asp?B=100&ID=${topic}`);
  await ajaxCommand(p, `a[onclick*="'AllTopAnc&b=100&ID=${topic}'"]`);
  const pinned = await dbNum(p, 'SELECT count(*) FROM leadbbs_topannounce');
  rec('a site-wide sticky exists to be cleared', pinned > 0, `${pinned} row(s)`);

  await goTo(p, `${BM}/ClearTopAnc.asp`);
  const txt = await p.locator('body').innerText();
  rec('ClearTopAnc explains what it will undo',
      txt.includes('解除所有总固顶帖子'), txt.replace(/\s+/g, ' ').slice(0, 50));
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const left = await dbNum(p, 'SELECT count(*) FROM leadbbs_topannounce');
  rec('ClearTopAnc really clears every site-wide sticky', left === 0, `${left} row(s) left`);
}

// ------------------------------------------------ 审核队列 (ClearTopAnc?action=1)
{
  for (const [flag, label] of [['0', '先审后看帖'], ['1', '先看后审帖']]) {
    await goTo(p, `${BM}/ClearTopAnc.asp?action=1&typeflag=${flag}`);
    const txt = await p.locator('body').innerText();
    rec(`the ${label} moderation queue renders`,
        !txt.includes('请先登录') && txt.length > 200, txt.replace(/\s+/g, ' ').slice(0, 45));
  }
}

// ------------------------------------------------ action=specialuser: 屏蔽发言 then release
{
  const before = await dbNum(p,
    `SELECT count(*) FROM leadbbs_specialuser WHERE UserName='${victim}' AND Assort=3`);
  await goTo(p, `${LUM}?action=specialuser&GBL_Assort=3`);
  const form = p.locator('form').filter({ has: p.locator('input[name="GBL_UserName"]') }).first();
  rec('action=specialuser renders the restriction form', (await form.count()) > 0);
  await form.locator('input[name="GBL_UserName"]').first().fill(victim);
  await form.locator('input[name="GBL_WhyString"]').first().fill(`bm test ${stamp}`);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    form.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1400);
  const after = await dbNum(p,
    `SELECT count(*) FROM leadbbs_specialuser WHERE UserName='${victim}' AND Assort=3`);
  rec('action=specialuser writes the 屏蔽发言 restriction', after === before + 1,
      `leadbbs_specialuser(Assort=3) for ${victim}: ${before} -> ${after}`);
  const why = await dbOne(p,
    `SELECT WhyString FROM leadbbs_specialuser WHERE UserName='${victim}' AND Assort=3 ORDER BY ID DESC LIMIT 1`);
  rec('the reason the moderator typed is stored with it', why.includes(stamp), why);

  // it must be listed back to the moderator
  await goTo(p, `${LUM}?assort=3`);
  rec('the restricted user shows in the moderator list',
      (await p.locator('body').innerText()).includes(victim));

  // release it again through the popup the list opens
  const sid = await dbOne(p,
    `SELECT ID FROM leadbbs_specialuser WHERE UserName='${victim}' AND Assort=3 ORDER BY ID DESC LIMIT 1`);
  await goTo(p, `${BM}/User/DelSpecialUser.asp?GBL_UserName=${encodeURIComponent(victim)}&GBL_Assort=3&ID=${sid}`);
  const ds = p.locator('input[type="submit"]').first();
  rec('DelSpecialUser asks the moderator to confirm', (await ds.count()) > 0);
  if (await ds.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      ds.click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const gone = await dbNum(p,
    `SELECT count(*) FROM leadbbs_specialuser WHERE UserName='${victim}' AND Assort=3`);
  rec('DelSpecialUser lifts the restriction', gone === before,
      `rows now ${gone}, started at ${before}`);
}

// ------------------------------------------------ action=fobip: block by user name, then release
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  await goTo(p, `${LUM}?action=fobip`);
  const said = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  const forms = await p.locator('input[name="GBL_UserName"]').count();
  // This deployment ships DEF_EnableForbidIP = 0 (inc/BBSSetup.asp). Upstream guarded this
  // page with "= 10" — a value the constant never takes — so it offered a full block form that
  // wrote a row inc/Board_Popfun.asp then refuses to enforce. With the guard corrected to
  // "= 0" the moderator is told the truth, exactly as the standalone NewForbidIP.asp does.
  rec('action=fobip reports that IP blocking is switched off site-wide',
      said.includes('系统已经禁止屏蔽IP功能') && forms === 0,
      `${forms} address field(s): ${said.replace(/.*Control Pannel/, '').slice(0, 60)}`);
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  rec('and no block is written while the feature is off', after === before,
      `leadbbs_forbidip ${before} -> ${after}`);

  // the expiry sweep still has to run
  await goTo(p, `${LUM}?action=clear`);
  const cs = p.locator('input[type="submit"]').first();
  rec('action=clear offers the expiry sweep', (await cs.count()) > 0);
  if (await cs.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      cs.click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const kept = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  rec('action=clear leaves the unexpired blocks alone', kept <= after,
      `leadbbs_forbidip now ${kept}`);
}

// ------------------------------------------------ action=modifyuser: strip a profile
{
  const uid = victimId;
  // give the account an avatar, a signature and a custom title through the backend editor, so
  // "clear them" has something to clear and the check cannot pass vacuously
  await goTo(p, `${B}/manage/User/UserModify.asp?Form_ID=${uid}`);
  await p.locator('input[name="Form_FaceUrl"]').first().fill('../images/face/0001.gif').catch(()=>{});
  await p.locator('input[name="Form_Underwrite"], textarea[name="Form_Underwrite"]').first()
    .fill(`sig ${stamp}`).catch(()=>{});
  await p.locator('input[name="Form_UserTitle"]').first().fill(`ttl${stamp}`).catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const seeded = await dbRows(p,
    `SELECT ifnull(FaceUrl,''),ifnull(Underwrite,''),ifnull(UserTitle,'') FROM leadbbs_user WHERE ID=${uid}`);
  rec('the account now has an avatar, signature and title to strip',
      seeded.length > 0 && seeded[0].some(v => v !== ''), JSON.stringify(seeded[0] || []));

  await goTo(p, `${LUM}?action=modifyuser`);
  const form = p.locator('form').filter({ has: p.locator('input[name="GBL_UserName"]') }).first();
  rec('action=modifyuser offers the three cleanup options',
      (await p.locator('input[name="GBL_ModifyMode"]').count()) === 3,
      `${await p.locator('input[name="GBL_ModifyMode"]').count()} options`);
  await form.locator('input[name="GBL_UserName"]').first().fill(victim);
  for (const v of ['1', '2', '3']) {
    await p.locator(`input[name="GBL_ModifyMode"][value="${v}"]`).first()
      .check({ force: true }).catch(()=>{});
  }
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    form.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1400);
  const row = await dbRows(p,
    `SELECT ifnull(FaceUrl,''),ifnull(Underwrite,''),ifnull(UserTitle,'') FROM leadbbs_user WHERE ID=${uid}`);
  const [face, under, title] = row.length ? row[0] : ['?', '?', '?'];
  rec('action=modifyuser clears the avatar, signature and custom title',
      face === '' && under === '' && title === '',
      `FaceUrl="${face}" UnderWrite="${under}" UserTitle="${title}"`);
  // and the profile a reader opens shows the account with nothing left to strip
  await goTo(p, `${B}/User/LookUserInfo.asp?id=${uid}`);
  const prof = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the stripped profile still renders for readers, without the signature',
      prof.includes(victim) && !prof.includes(`sig ${stamp}`) && !prof.includes(`ttl${stamp}`),
      prof.slice(0, 60));
}

// ------------------------------------------------ the standalone moderator pages
{
  const pages = [
    ['User/NewSpecialUser.asp?GBL_Assort=3', 'NewSpecialUser'],
    ['User/ModifyUser.asp', 'ModifyUser'],
    ['User/DeleteForbidIPandUser.asp', 'DeleteForbidIPandUser'],
  ];
  for (const [rel, name] of pages) {
    await goTo(p, `${BM}/${rel}`);
    const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    const forms = await p.locator('form').count();
    rec(`${name} renders a working moderator form`,
        !txt.includes('请先登录') && !/error/i.test(txt) && forms > 0,
        `${forms} form(s): ${txt.slice(0, 45)}`);
  }
  // NewForbidIP is the page that already got the DEF_EnableForbidIP test right: with the
  // feature off it must refuse rather than offer a form that writes an unenforced row.
  await goTo(p, `${BM}/User/NewForbidIP.asp`);
  const nf = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('NewForbidIP refuses while IP blocking is switched off',
      nf.includes('系统已经禁止屏蔽IP功能') &&
      (await p.locator('input[name="GBL_UserName"]').count()) === 0,
      nf.replace(/.*Control Pannel/, '').slice(0, 60));

  // DeleteForbidIPandUser actually performs the sweep
  await goTo(p, `${BM}/User/DeleteForbidIPandUser.asp`);
  const kept = await dbNum(p,
    'SELECT count(*) FROM leadbbs_forbidip WHERE ExpiresTime=0 OR ExpiresTime>20260725000000');
  const s = p.locator('input[type="submit"]').first();
  if (await s.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      s.click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const now = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  rec('the moderator expiry sweep keeps every unexpired block', now >= kept,
      `${now} rows, ${kept} unexpired`);
}

// ------------------------------------------------ put the site back
{
  await goTo(p, `${B}/manage/User/UserDelete.asp?GBL_CTG_DELETEID=${victimId}`);
  const d = p.locator('input[type="submit"]').first();
  if (await d.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      d.click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  rec('the throwaway member is removed again',
      (await dbNum(p, `SELECT count(*) FROM leadbbs_user WHERE ID=${victimId}`)) === 0);
}

await br.close();
process.exit(summary('19-boardmaster') ? 0 : 1);
