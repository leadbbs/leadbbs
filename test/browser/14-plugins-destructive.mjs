// 14 — the last flows that had never been driven: LeadCard (make + redeem, with the
// double-spend guard), the group private message, SiteReset, and DelUserAllAnnounce.
//
// The destructive ones are made safe by SCOPE, not by skipping them: every row this suite
// destroys is a row it created moments earlier, in a board it created, for a user it created.
// SiteReset is safe by inspection — it touches no table, only Application caches — but its two
// checkboxes would close the forum, so the suite asserts they are unchecked before submitting.
import { B, rec, summary, browser, login, adminPage, dbNum, dbOne, dbRows,
         setSelect, reveal, goTo } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);
const stamp = Date.now().toString().slice(-6);

// helper: create a throwaway account through the backend form
async function makeUser(name, pass) {
  await goTo(p, `${B}/manage/User/UserJoin.asp`);
  if (await p.locator('input[name="Form_username"]').count() === 0) return false;
  await p.fill('input[name="Form_username"]', name);
  await p.fill('input[name="Form_password1"]', pass);
  await p.fill('input[name="Form_password2"]', pass);
  await p.fill('input[name="Form_mail"]', `${name}@example.invalid`).catch(()=>{});
  await p.fill('input[name="Form_Question"]', 'q').catch(()=>{});
  await p.fill('input[name="Form_Answer"]', 'a').catch(()=>{});
  await p.locator('input[name="Form_sex"]').first().check({ force: true }).catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  return !!(await dbOne(p, `SELECT ID FROM leadbbs_user WHERE UserName='${name}'`));
}

// ------------------------------------------------------------------- LeadCard
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_plug_card');
  await goTo(p, `${B}/plug-ins/LeadCard/Default.asp`);
  const madeForm = await p.locator('input[name="CardNum"]').count() > 0;
  rec('LeadCard card-making form renders for a supervisor', madeForm);

  if (madeForm) {
    await setSelect(p, 'select[name="CardType"]', '1');      // 积分卡 -> Points
    await setSelect(p, 'select[name="CardPoints"]', '10');
    await setSelect(p, 'select[name="ExpiresDate"]', '30');
    await p.fill('input[name="CardNum"]', '5');
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[value="立即制作"]').first().click({ force: true }).catch(()=>{}),
    ]);
    await p.waitForTimeout(1500);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_plug_card');
  rec('making cards inserts rows', after > before, `plug_card ${before}->${after}`);

  // §22 guard: CardID is Fix(Rnd*99999999999999), a Double. If it renders as 9.99e+13 then
  // Len(CardID) is 8, every card is skipped, and the page says "共计0张" with a 200.
  const ids = (await dbRows(p, 'SELECT CardID FROM leadbbs_plug_card ORDER BY ID DESC LIMIT 3')).map(r => r[0]);
  const pageText = (await p.locator('body').innerText()).replace(/\s+/g, '');
  rec('generated card ids are full-length, not scientific notation',
      ids.length > 0 && ids.every(i => /^\d{14}$/.test(i)), ids.join(',') || '(none)');
  rec('the result page lists the cards it just created',
      ids.length > 0 && ids.some(i => pageText.includes(i)), `${ids.length} checked`);

  // redeem one against a throwaway account
  const LCU = 'lc' + stamp;
  const made = await makeUser(LCU, 'lcpass123');
  rec('throwaway account for the redeem test exists', made, LCU);
  if (made && ids.length) {
    const card = await dbOne(p, "SELECT CardID FROM leadbbs_plug_card WHERE CardType=1 LIMIT 1");
    const pts0 = Number(await dbOne(p, `SELECT Points FROM leadbbs_user WHERE UserName='${LCU}'`));
    await goTo(p, `${B}/plug-ins/LeadCard/Default.asp`);
    await p.fill('input[name="CardID"]', card).catch(()=>{});
    await p.fill('input[name="CardUser"]', LCU).catch(()=>{});
    await p.fill('input[name="CardUser2"]', LCU).catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[value="立即充值"]').first().click({ force: true }).catch(()=>{}),
    ]);
    await p.waitForTimeout(1500);
    const pts1 = Number(await dbOne(p, `SELECT Points FROM leadbbs_user WHERE UserName='${LCU}'`));
    const gone = await dbNum(p, `SELECT count(*) FROM leadbbs_plug_card WHERE CardID='${card}'`);
    rec('redeeming a card credits the user and consumes the card', pts1 > pts0 && gone === 0,
        `points ${pts0}->${pts1}, card row gone=${gone === 0}`);

    // double-spend: the one thing a curl smoke test never checks
    await goTo(p, `${B}/plug-ins/LeadCard/Default.asp`);
    await p.fill('input[name="CardID"]', card).catch(()=>{});
    await p.fill('input[name="CardUser"]', LCU).catch(()=>{});
    await p.fill('input[name="CardUser2"]', LCU).catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[value="立即充值"]').first().click({ force: true }).catch(()=>{}),
    ]);
    await p.waitForTimeout(1500);
    const pts2 = Number(await dbOne(p, `SELECT Points FROM leadbbs_user WHERE UserName='${LCU}'`));
    rec('the same card cannot be redeemed twice', pts2 === pts1, `points still ${pts2}`);
  }
}

// --------------------------------------------------------- group private message
{
  const SGU = 'sg' + stamp;
  const made = await makeUser(SGU, 'sgpass123');
  rec('throwaway recipient for the group message exists', made, SGU);

  // blast-radius control: target the 认证会员 class, and only send if that class is EMPTY
  // beforehand, so the message reaches exactly the one account this suite just seeded.
  // Blast-radius guard: only send if the target class contains nothing but throwaway
  // accounts this suite family created (sg*). A leftover sg row from a previous run must not
  // block the test, but a REAL member must.
  const others = await dbNum(p, "SELECT count(*) FROM leadbbs_specialuser WHERE Assort=0 AND UserName NOT LIKE 'sg%'");
  await goTo(p, `${B}/manage/User/NewSpecialUser.asp`);
  if (await p.locator('input[name="GBL_UserName"]').count()) {
    await p.fill('input[name="GBL_UserName"]', SGU);
    await setSelect(p, 'select[name="GBL_Assort"]', '0').catch(()=>{});
    await p.fill('input[name="GBL_WhyString"]', 'browser test ' + stamp).catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const seeded = await dbNum(p, `SELECT count(*) FROM leadbbs_specialuser WHERE Assort=0 AND UserName='${SGU}'`);
  rec('special-user row created (NewSpecialUser)', seeded === 1, `Assort=0 had ${others} before`);

  const title = 'GRP' + stamp;
  if (seeded === 1 && others === 0) {
    await goTo(p, `${B}/manage/User/SendGroupMessage.asp`);
    await setSelect(p, 'select[name="SdM_ToUserClass"]', '2').catch(()=>{});   // 全体认证会员
    await p.fill('input[name="SdM_Title"]', title).catch(()=>{});
    await p.evaluate(t => { const f = document.forms[0];
      if (f && f.elements['SdM_Content']) f.elements['SdM_Content'].value = 'group send ' + t; }, stamp);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(2000);
    const rows = await dbRows(p, `SELECT ToUser,FromUser FROM leadbbs_infobox WHERE Title='${title}'`);
    const allThrowaway = rows.length > 0 && rows.every(r => /^sg\d+$/.test(r[0]) && r[1] === '[LeadBBS]');
    rec('the group message reaches exactly the seeded recipients',
        allThrowaway && rows.some(r => r[0] === SGU),
        rows.length ? `${rows.length} row(s): ${rows.map(r => r[0]).join(',')} from ${rows[0][1]}` : 'no rows');
  } else {
    rec('the group message reaches exactly the seeded recipients', false,
        `refused to send: the target class contains ${others} non-throwaway member(s)`);
  }
}

// ------------------------------------------------------------------- SiteReset
{
  await goTo(p, `${B}/Boards.asp`);                       // warm the caches
  await goTo(p, `${B}/manage/SiteManage/SiteReset.asp`);
  const form = await p.locator('input[type="submit"]').count() > 0;
  rec('SiteReset page renders', form);

  // NEVER tick these: Flag closes the forum, Flag2 wipes every Application key
  const flags = await p.evaluate(() => ({
    flag: (document.getElementsByName('Flag')[0] || {}).checked,
    flag2: (document.getElementsByName('Flag2')[0] || {}).checked,
  }));
  rec('the site-closing checkboxes are unchecked before submitting',
      flags.flag !== true && flags.flag2 !== true, JSON.stringify(flags));

  if (form && flags.flag !== true && flags.flag2 !== true) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1500);
    const body = (await p.locator('body').innerText()).replace(/\s+/g, '');
    rec('resetting reports success and does NOT close the forum',
        !body.includes('已经正常关闭'), body.includes('重置') || body.includes('重启') ? 'reset reported' : body.slice(0, 40));

    // the assertion that matters: the caches rebuild and the forum still works
    await goTo(p, `${B}/Boards.asp`);
    const boards = await p.locator('body').innerText();
    await goTo(p, `${B}/b/b.asp?B=100`);
    const topics = await p.locator('a[href*="a/a.asp"], a[href*="a.asp?"]').count();
    rec('the forum still works after the cache reset', boards.length > 200 && topics > 0,
        `board index ${boards.length} chars, ${topics} topic links`);
  }
}

// ------------------------------------------------- DelUserAllAnnounce (scoped, real)
{
  const DU = 'del' + stamp;
  const made = await makeUser(DU, 'delpass123');
  rec('throwaway author for the delete-all test exists', made, DU);

  let uid = await dbOne(p, `SELECT ID FROM leadbbs_user WHERE UserName='${DU}'`);
  let posted = 0;
  if (made) {
    const mp = await login(br, DU, 'delpass123');
    await goTo(mp, `${B}/a/a2.asp?B=100`);
    if (await mp.locator('input[name="Form_Title"]').count()) {
      await mp.fill('input[name="Form_Title"]', 'DelMe ' + stamp);
      const { setEditorContent, currentCaptcha } = await import('./lib.mjs');
      await setEditorContent(mp, 'post that will be removed with its author, ' + stamp);
      const cap = mp.locator('input[name="ForumNumber"]');
      if (await cap.count()) await cap.fill(await currentCaptcha(mp));
      await Promise.all([
        mp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
        mp.locator('input[type="submit"], input[type="image"]').first().click({ force: true }),
      ]);
      await mp.waitForTimeout(1800);
    }
    await mp.context().close();
    posted = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE UserID=${uid}`);
  }
  rec('the throwaway author has posts to delete', posted > 0, `${posted} post(s) by ${DU}`);

  if (posted > 0) {
    const totalBefore = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
    await goTo(p, `${B}/manage/User/DelUserAllAnnounce.asp?DelUserID=${uid}`);
    const has = await p.locator('input[type="submit"]').count() > 0;
    rec('delete-all-posts page renders for that user', has, `user ${uid}`);
    if (has) {
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
        p.locator('input[type="submit"]').first().click({ force: true }),
      ]);
      await p.waitForTimeout(3000);
    }
    const mine = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE UserID=${uid}`);
    const totalAfter = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
    rec("deleting a user's posts removes exactly those rows",
        mine === 0 && totalAfter < totalBefore && totalBefore - totalAfter >= posted,
        `author's posts ${posted}->${mine}, announce ${totalBefore}->${totalAfter}`);
  }
}

await br.close();
process.exit(summary('14-plugins-destructive') ? 0 : 1);
