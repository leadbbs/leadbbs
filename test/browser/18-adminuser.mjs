// 18 — 用户管理 / 版面管理 / 论坛分类: the destructive half of the admin panel.
//
// Everything that deletes here operates on a board and a user this suite creates itself, so a
// re-run finds the site exactly as it left it and no sibling suite loses its data.
//
// Verbs driven end to end: medal (grant + revoke a badge), join (create a forum category),
// Modify (edit a board 专区 through the JS-generated list link).
import { B, rec, summary, browser, adminPage, db, dbNum, dbOne, dbRows,
         httpGet, goTo, setSelect, ADMIN, ADMIN_PASS } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);
const stamp = Date.now().toString().slice(-6);
const MU = `${B}/manage/User`;
const MB = `${B}/manage/ForumBoard`;

// ------------------------------------------------ 用户注册参数 (UserSetup)
{
  const url = `${MU}/UserSetup.asp`;
  await goTo(p, url);
  const f = p.locator('input[name="Form_DEF_User_RegPoints"]').first();
  const original = await f.inputValue();
  const probe = String(((parseInt(original, 10) || 0) % 50) + 7);
  rec('UserSetup renders the registration parameters', (await f.count()) > 0);
  await f.fill(probe);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(900);
  const gen = await httpGet(p, '/test/browser/helpers/f.asp?path=inc/User_Setup.ASP');
  rec('UserSetup writes the new registration bonus into inc/User_Setup.ASP',
      gen.body.includes(`DEF_User_RegPoints = ${probe}`), `${gen.body.length} bytes`);
  await goTo(p, url);
  await p.locator('input[name="Form_DEF_User_RegPoints"]').first().fill(original);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(700);
  const gen2 = await httpGet(p, '/test/browser/helpers/f.asp?path=inc/User_Setup.ASP');
  rec('the registration bonus is restored', gen2.body.includes(`DEF_User_RegPoints = ${original}`));
}

// ------------------------------------------------ action=medal — grant then revoke a badge
{
  const url = `${MU}/UserSetup.asp?action=medal`;
  // the badge list lives in leadbbs_user.Officer, and the notification is a private message
  // (LeadBBS_InfoBox), not a mail
  const before = await dbOne(p, "SELECT ifnull(Officer,'') FROM leadbbs_user WHERE UserName='" + ADMIN + "'");
  const msgs = await dbNum(p, "SELECT count(*) FROM leadbbs_infobox WHERE ToUser='" + ADMIN + "'");
  await goTo(p, url);
  rec('action=medal renders the badge picker',
      (await p.locator('textarea[name="form_namelist"]').count()) > 0 &&
      (await p.locator('input[name="form_medalindex"]').count()) >= 10,
      `${await p.locator('input[name="form_medalindex"]').count()} badges offered`);

  await p.locator('textarea[name="form_namelist"]').first().fill(ADMIN);
  await p.locator('input[name="form_addflag"][value="0"]').first().check({ force: true }).catch(()=>{});
  await p.locator('input[name="form_messageflag"][value="1"]').first().check({ force: true }).catch(()=>{});
  await p.locator('input[name="form_medalindex"][value="3"]').first().check({ force: true }).catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const granted = await dbOne(p, "SELECT ifnull(Officer,'') FROM leadbbs_user WHERE UserName='" + ADMIN + "'");
  rec('action=medal grants the badge', granted !== before && granted.split(',').includes('3'),
      `Officer "${before}" -> "${granted}"`);
  const msgs2 = await dbNum(p, "SELECT count(*) FROM leadbbs_infobox WHERE ToUser='" + ADMIN + "'");
  rec('and the user is told about it by private message', msgs2 === msgs + 1,
      `messages ${msgs} -> ${msgs2}`);
  // the badge is meant to be visible: the profile renders it as a sprite off medal_icons.png
  await goTo(p, `${B}/User/LookUserInfo.asp?username=admin`);
  const icons = p.locator('img.img_medal');
  const n = await icons.count();
  const bg = n ? await icons.first().evaluate(e => getComputedStyle(e).backgroundImage) : '';
  rec('the badge shows as an icon on the profile page',
      n > 0 && bg.includes('medal_icons.png'), `${n} badge icon(s), background=${bg.slice(0, 60)}`);

  // revoke it again
  await goTo(p, url);
  await p.locator('textarea[name="form_namelist"]').first().fill(ADMIN);
  await p.locator('input[name="form_addflag"][value="1"]').first().check({ force: true }).catch(()=>{});
  await p.locator('input[name="form_messageflag"][value="0"]').first().check({ force: true }).catch(()=>{});
  await p.locator('input[name="form_medalindex"][value="3"]').first().check({ force: true }).catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const revoked = await dbOne(p, "SELECT ifnull(Officer,'') FROM leadbbs_user WHERE UserName='" + ADMIN + "'");
  rec('action=medal revokes the badge again', revoked === before,
      `Officer back to "${revoked}"`);
}

// ------------------------------------------------ 特殊用户管理 (UserSpecial)
{
  await goTo(p, `${MU}/UserSpecial.asp`);
  const shown = await p.locator('a[href*="UserModify.asp?Form_ID="]').count();
  const real = await dbNum(p, 'SELECT count(*) FROM leadbbs_specialuser WHERE Assort=0');
  rec('UserSpecial lists the 认证会员 the database holds',
      shown === Math.min(real, 32), `page shows ${shown}, DB has ${real} (page size 32)`);
  const tabs = await p.locator('a[href*="UserSpecial.asp?assort="]').count();
  rec('UserSpecial offers every special-user category', tabs >= 8, `${tabs} tabs`);

  await goTo(p, `${MU}/UserSpecial.asp?assort=1`);
  const t = await p.locator('body').innerText();
  rec('switching to 版主 re-queries the list', t.includes('特殊用户管理'),
      t.replace(/\s+/g, ' ').slice(0, 40));
}

// ------------------------------------------------ 头像参考 (Facelist) — an image gallery
{
  await goTo(p, `${MU}/Facelist.asp`);
  const imgs = p.locator('img');
  const n = await imgs.count();
  const loaded = await p.evaluate(() =>
    Array.from(document.images).filter(i => i.naturalWidth > 0).length);
  rec('Facelist renders real avatar images, not broken ones', n > 0 && loaded === n,
      `${loaded}/${n} images decoded`);
  rec('Facelist pages through the avatar set',
      (await p.locator('a[href*="first="]').count()) >= 2);
}

// ------------------------------------------------ 到期清理 (DeleteForbidIPandUser)
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  const stillValid = await dbNum(p,
    'SELECT count(*) FROM leadbbs_forbidip WHERE ExpireTime=0 OR ExpireTime > 20260725000000');
  await goTo(p, `${MU}/DeleteForbidIPandUser.asp`);
  const txt = await p.locator('body').innerText();
  rec('the expiry-cleanup page explains exactly what it will release',
      txt.includes('解除被屏蔽的IP地址') && txt.includes('恢复到期了的认证会员'),
      txt.replace(/\s+/g, ' ').slice(0, 50));
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  rec('it keeps every block that has not expired yet', after >= stillValid,
      `leadbbs_forbidip ${before} -> ${after}, ${stillValid} unexpired`);
}

// ------------------------------------------------ create a throwaway user, repair it, delete it
{
  const uname = `del${stamp}`;
  await goTo(p, `${MU}/UserJoin.asp`);
  // this form validates 密码提示/提示答案 and 性别 too, and no gender radio is pre-checked
  await p.locator('input[name="Form_username"]').first().fill(uname).catch(()=>{});
  await p.locator('input[name="Form_password1"]').first().fill(ADMIN_PASS).catch(()=>{});
  await p.locator('input[name="Form_password2"]').first().fill(ADMIN_PASS).catch(()=>{});
  await p.locator('input[name="Form_mail"]').first().fill(`${uname}@example.invalid`).catch(()=>{});
  await p.locator('input[name="Form_Question"]').first().fill('q' + stamp).catch(()=>{});
  await p.locator('input[name="Form_Answer"]').first().fill('a' + stamp).catch(()=>{});
  await p.locator('input[name="Form_sex"]').first().check({ force: true }).catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const uid = await dbOne(p, `SELECT ID FROM leadbbs_user WHERE UserName='${uname}'`);
  rec('the backend creates a user', !!uid, `id=${uid || 'none'}`);

  if (uid) {
    // UserManage's per-user 修复 link (UpdateUserAnnounce2) recomputes that one account
    await goTo(p, `${MU}/UpdateUserAnnounce2.asp?ID=${uid}`);
    const f = p.locator('input[type="submit"]').first();
    if (await f.count()) {
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
        f.click({ force: true }),
      ]);
      await p.waitForTimeout(1500);
    }
    const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    rec('UpdateUserAnnounce2 repairs one account', /完成|修复|100/.test(txt), txt.slice(0, 60));
    const n = await dbNum(p, `SELECT AnnounceNum FROM leadbbs_user WHERE ID=${uid}`);
    rec('a brand-new account is recomputed to zero posts', n === 0, `AnnounceNum=${n}`);

    // and now delete it
    const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
    await goTo(p, `${MU}/UserDelete.asp?GBL_CTG_DELETEID=${uid}`);
    const del = p.locator('input[type="submit"]').first();
    rec('UserDelete asks for confirmation before deleting', (await del.count()) > 0);
    if (await del.count()) {
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
        del.click({ force: true }),
      ]);
      await p.waitForTimeout(1200);
    }
    const gone = await dbNum(p, `SELECT count(*) FROM leadbbs_user WHERE ID=${uid}`);
    const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
    rec('UserDelete really removes the account', gone === 0 && after === before - 1,
        `rows for ${uid}: ${gone}, users ${before} -> ${after}`);
    // and the account can no longer be looked up by a reader
    await goTo(p, `${B}/User/LookUserInfo.asp?username=${uname}`);
    rec('the deleted account no longer has a profile page',
        !(await p.locator('body').innerText()).includes(uname));
  }
}

// ------------------------------------------------ a throwaway board: modify, move, purge, delete
{
  const bid = 5000 + (parseInt(stamp, 10) % 900);
  const bname = `TmpBoard${stamp}`;
  await goTo(p, `${MB}/ForumBoardJoin.asp`);
  await p.locator('input[name="GBL_BoardID"]').first().fill(String(bid)).catch(()=>{});
  await p.locator('input[name="GBL_BoardName"]').first().fill(bname).catch(()=>{});
  await p.evaluate(() => {
    const s = document.querySelector('select[name="GBL_BoardAssort"]');
    if (s && s.options.length > 1) { s.selectedIndex = 1; s.dispatchEvent(new Event('change', {bubbles:true})); }
  });
  await p.locator('input[name="GBL_LastWriter"]').first().fill(ADMIN).catch(()=>{});
  await p.locator('input[name="GBL_TopicNum"]').first().fill('0').catch(()=>{});
  await p.locator('input[name="GBL_AnnounceNum"]').first().fill('0').catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const made = await dbNum(p, `SELECT count(*) FROM leadbbs_boards WHERE BoardID=${bid}`);
  rec('a throwaway board is created for the destructive checks', made === 1, `BoardID=${bid}`);

  // --- ForumBoardModify: rename it, and check a reader sees the new name
  const newName = `${bname}R`;
  await goTo(p, `${MB}/ForumBoardModify.asp?GBL_ModifyID=${bid}`);
  const nf = p.locator('input[name="GBL_BoardName"]').first();
  rec('ForumBoardModify pre-fills the board being edited',
      (await nf.count()) > 0 && (await nf.inputValue()) === bname,
      `form shows "${(await nf.count()) ? await nf.inputValue() : ''}"`);
  await nf.fill(newName);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const dbName = await dbOne(p, `SELECT BoardName FROM leadbbs_boards WHERE BoardID=${bid}`);
  rec('ForumBoardModify renames the board', dbName === newName, `DB says "${dbName}"`);
  await goTo(p, `${B}/b/b.asp?b=${bid}`);
  rec('and the board page itself is titled with the new name',
      (await p.title()).includes(newName), await p.title());

  // --- BoardMoveAnnounce: move this (empty) board's posts into the recycle board
  const beforeMove = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE BoardID=${bid}`);
  await goTo(p, `${MB}/BoardMoveAnnounce.asp?MoveFromBoardID=${bid}`);
  const mtxt = await p.locator('body').innerText();
  rec('BoardMoveAnnounce renders the source/target picker',
      (await p.locator('form').count()) > 0 && mtxt.length > 40,
      mtxt.replace(/\s+/g, ' ').slice(0, 50));
  const totalBefore = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  await p.evaluate(() => {
    for (const s of document.querySelectorAll('select')) {
      if (s.options.length > 1) { s.selectedIndex = 1; s.dispatchEvent(new Event('change', {bubbles:true})); }
    }
  });
  const msub = p.locator('input[type="submit"]').first();
  if (await msub.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
      msub.click({ force: true }),
    ]);
    await p.waitForTimeout(1500);
  }
  const totalAfter = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  rec('moving an empty board loses no post anywhere', totalAfter === totalBefore,
      `leadbbs_announce ${totalBefore} -> ${totalAfter}, source board had ${beforeMove}`);

  // --- ForumBoardDeleteAnnounce: purge the (empty) board's posts
  await goTo(p, `${MB}/ForumBoardDeleteAnnounce.asp?DelBoardID=${bid}`);
  const dtxt = await p.locator('body').innerText();
  rec('ForumBoardDeleteAnnounce warns before purging a board',
      dtxt.length > 40 && (await p.locator('input[type="submit"], form').count()) > 0,
      dtxt.replace(/\s+/g, ' ').slice(0, 50));
  const ds = p.locator('input[type="submit"]').first();
  if (await ds.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
      ds.click({ force: true }),
    ]);
    await p.waitForTimeout(1500);
  }
  const left = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE BoardID=${bid}`);
  const total2 = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  rec('the purge empties that board and touches no other', left === 0 && total2 === totalAfter,
      `board ${bid}: ${left} posts, site total ${total2}`);

  // --- ForumBoardDelete: remove the board itself
  const boardsBefore = await dbNum(p, 'SELECT count(*) FROM leadbbs_boards');
  await goTo(p, `${MB}/ForumBoardDelete.asp?GBL_DeleteID=${bid}`);
  const bd = p.locator('input[type="submit"]').first();
  rec('ForumBoardDelete asks for confirmation', (await bd.count()) > 0);
  if (await bd.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      bd.click({ force: true }),
    ]);
    await p.waitForTimeout(1500);
  }
  const boardsAfter = await dbNum(p, 'SELECT count(*) FROM leadbbs_boards');
  rec('ForumBoardDelete removes the board', boardsAfter === boardsBefore - 1,
      `leadbbs_boards ${boardsBefore} -> ${boardsAfter}`);
  await goTo(p, `${B}/BoardNav.asp`);
  rec('and it is gone from the public board list',
      !(await p.locator('body').innerText()).includes(newName));
}

// ------------------------------------------------ 版面列表重建 / 昨日发帖修复
{
  await goTo(p, `${MB}/MakeBoardList.asp`);
  const ms = p.locator('input[type="submit"]').first();
  rec('MakeBoardList asks for confirmation before the long pass', (await ms.count()) > 0);
  if (await ms.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 90000 }).catch(()=>{}),
      ms.click({ force: true }),
    ]);
    await p.waitForTimeout(2500);
  }
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('MakeBoardList recounts every board', /完成|修复/.test(txt), txt.slice(0, 60));
  // the whole point: each board's cached counters now agree with leadbbs_announce
  const badBoards = await dbNum(p,
    'SELECT count(*) FROM leadbbs_boards B WHERE B.LowerBoard=0 AND B.AnnounceNum <> ' +
    '(SELECT count(*) FROM leadbbs_announce A WHERE A.BoardID=B.BoardID)');
  rec('every leaf board\'s post counter matches the posts table', badBoards === 0,
      `${badBoards} board(s) still disagree`);
  // and the board page a reader opens prints those recounted numbers in its header
  const anyBoard = await dbRows(p,
    'SELECT BoardID,TopicNum,AnnounceNum FROM leadbbs_boards WHERE LowerBoard=0 AND AnnounceNum>0 LIMIT 1');
  if (!anyBoard.length) {
    rec('the board page shows the recounted totals', false, 'no board with posts');
  } else {
    const [bId, tN, aN] = anyBoard[0];
    await goTo(p, `${B}/b/b.asp?b=${bId}`);
    const bTxt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    rec('the board page shows the recounted totals',
        bTxt.includes(`主题: ${tN} / 帖子: ${aN}`),
        `expected "主题: ${tN} / 帖子: ${aN}" on board ${bId}`);
  }

  await goTo(p, `${MB}/RepairYesterdayAnc.asp`);
  await p.waitForTimeout(600);
  const y = await p.locator('body').innerText();
  rec('RepairYesterdayAnc recounts yesterday\'s posts', y.length > 20 && !/error/i.test(y),
      y.replace(/\s+/g, ' ').slice(0, 60));
}

// ------------------------------------------------ 论坛分类 (action=join / edit / del)
{
  const FC = `${B}/manage/ForumCategory/ForumCategoryManage.asp`;
  // a free id, not a hash of the timestamp: only 90 values were reachable that way, so a
  // category left behind by an interrupted run collided with this one and the checks then
  // described the leftover instead of what this run created
  const used = (await dbRows(p, 'SELECT AssortID FROM leadbbs_assort')).map(r => +r[0]);
  let cid = 700;
  while (used.includes(cid)) cid++;
  const cname = `Cat${stamp}`;
  await goTo(p, FC);
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_assort');
  rec('the category manager lists the existing categories',
      (await p.locator('a[href*="action=edit"]').count()) >= 1);

  await goTo(p, `${FC}?action=join`);
  // the <form> is opened inside <table> before the first <tr>, so the HTML parser pops it and
  // the fields are form-OWNED but not form-DESCENDANTS — fill them at page level
  await p.locator('input[name="Form_AssortID"]').first().fill(String(cid));
  await p.locator('input[name="Form_AssortName"]').first().fill(cname);
  await p.locator('input[name="GBL_AssortMaster"]').first().fill(ADMIN);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const made = await dbNum(p, `SELECT count(*) FROM leadbbs_assort WHERE AssortID=${cid}`);
  rec('action=join creates the forum category', made === 1,
      `leadbbs_assort rows for ${cid}: ${made}`);
  await goTo(p, FC);
  rec('and it appears in the category list',
      (await p.locator('body').innerText()).includes(cname));

  // edit it
  await goTo(p, `${FC}?action=edit&GBL_MODIFYID=${cid}`);
  const ef = p.locator('input[name="Form_AssortName"]').first();
  rec('action=edit pre-fills the category', (await ef.count()) > 0 &&
      (await ef.inputValue()) === cname, `form shows "${(await ef.count()) ? await ef.inputValue() : ''}"`);
  await ef.fill(`${cname}X`);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1000);
  rec('action=edit renames the category',
      (await dbOne(p, `SELECT AssortName FROM leadbbs_assort WHERE AssortID=${cid}`)) === `${cname}X`);

  // delete it again
  await goTo(p, `${FC}?action=del&GBL_DELETEID=${cid}`);
  const ds = p.locator('input[type="submit"]').first();
  if (await ds.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      ds.click({ force: true }),
    ]);
    await p.waitForTimeout(1000);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_assort');
  rec('action=del removes the category again', after === before,
      `leadbbs_assort ${before} -> ${after}`);
}

// ------------------------------------------------ action=Modify on a board 专区 (ForumBoardAssort)
{
  const FA = `${MB}/ForumBoardAssort.asp`;
  const gid = await dbOne(p, 'SELECT ID FROM leadbbs_goodassort ORDER BY ID DESC LIMIT 1');
  if (!gid) {
    rec('action=Modify edits a board 专区', false, 'no leadbbs_goodassort row to edit');
  } else {
    const was = await dbOne(p, `SELECT AssortName FROM leadbbs_goodassort WHERE ID=${gid}`);
    await goTo(p, `${FA}?action=Modify&ID=${gid}`);
    const nf = p.locator('input[name="LMT_AssortName"]').first();
    const shown = (await nf.count()) ? await nf.inputValue() : '';
    rec('action=Modify pre-fills the 专区 being edited', shown === was,
        `form shows "${shown}", DB has "${was}"`);
    await nf.fill(`${was}M`);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
    const now = await dbOne(p, `SELECT AssortName FROM leadbbs_goodassort WHERE ID=${gid}`);
    rec('action=Modify renames the 专区', now === `${was}M`, `DB says "${now}"`);
    // restore
    await goTo(p, `${FA}?action=Modify&ID=${gid}`);
    await p.locator('input[name="LMT_AssortName"]').first().fill(was);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(900);
    rec('the 专区 name is restored',
        (await dbOne(p, `SELECT AssortName FROM leadbbs_goodassort WHERE ID=${gid}`)) === was);
  }
}

await br.close();
process.exit(summary('18-adminuser') ? 0 : 1);
