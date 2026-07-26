// 08 — administrative operations that change state, driven through the real backend UI:
// blocking and unblocking an IP, creating and editing a user account, and the site log.
import { B, rec, summary, browser, adminPage, dbNum, dbOne } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk, p.url().replace(B, ''));

const stamp = Date.now().toString().slice(-6);

// --------------------------------------------------------- block an IP range
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  await p.goto(`${B}/manage/User/NewForbidIP.asp`, { waitUntil: 'domcontentloaded' });
  const form = p.locator('form#fobform1');
  const ok = await form.count() > 0;
  rec('IP block form renders in the backend', ok);
  if (ok) {
    await form.locator('input[name="GBL_IPStart"]').fill('203.0.113.7');
    const end = form.locator('input[name="GBL_IPEnd"]');
    if (await end.count()) await end.fill('203.0.113.7');
    await form.locator('input[name="GBL_WhyString"]').fill('browser test ' + stamp);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      form.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  rec('blocking an IP writes the ban row', after > before, `forbidip ${before}->${after}`);
}

// ------------------------------------------------------- unblock it again (UI)
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  await p.goto(`${B}/manage/User/IPManage.asp`, { waitUntil: 'domcontentloaded' });
  // each row's 解除 link is <a href="javascript:kill(id)"> opening DeleteIP.asp in a popup
  const del = p.locator('a[href^="javascript:kill("]').first();
  const have = await p.locator('a[href^="javascript:kill("]').count() > 0;
  rec('IP list shows an unblock link per ban', have, `${before} ban(s)`);
  if (have) {
    const [popup] = await Promise.all([
      p.waitForEvent('popup', { timeout: 8000 }).catch(() => null),
      del.click({ force: true }),
    ]);
    if (popup) {
      await popup.waitForLoadState('networkidle').catch(()=>{});
      await popup.locator('form input[type="submit"]').first().click({ force: true }).catch(()=>{});
      await popup.waitForTimeout(1500);
    }
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_forbidip');
  rec('unblocking through the UI removes the ban row', after < before, `forbidip ${before}->${after}`);
}

// ------------------------------------------- create a user from the backend
const NEWUSER = 'adm' + stamp;
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  await p.goto(`${B}/manage/User/UserJoin.asp`, { waitUntil: 'domcontentloaded' });
  const ok = await p.locator('input[name="Form_username"]').count() > 0;
  rec('backend "add user" form renders', ok);
  if (ok) {
    await p.fill('input[name="Form_username"]', NEWUSER);
    await p.fill('input[name="Form_password1"]', 'admpass123');
    await p.fill('input[name="Form_password2"]', 'admpass123');
    const mail = p.locator('input[name="Form_mail"]');
    if (await mail.count()) await mail.fill(`${NEWUSER}@example.invalid`);
    // 密码提示/提示答案 and 性别 are required by this form's own validation; none of
    // the gender radios is pre-checked, so an unselected form fails with "性别错误!"
    await p.fill('input[name="Form_Question"]', 'q' + stamp).catch(()=>{});
    await p.fill('input[name="Form_Answer"]', 'a' + stamp).catch(()=>{});
    await p.locator('input[name="Form_sex"]').first().check({ force: true }).catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  const uid = await dbOne(p, `SELECT ID FROM leadbbs_user WHERE UserName='${NEWUSER}'`);
  rec('backend creates the user account', after > before && !!uid, `user ${before}->${after}, id ${uid || 'none'}`);
}

// --------------------------------------- edit that user's points from the backend
{
  const uid = await dbOne(p, `SELECT ID FROM leadbbs_user WHERE UserName='${NEWUSER}'`);
  if (!uid) {
    rec('backend edits the user record', false, 'user was not created');
  } else {
    const before = await dbOne(p, `SELECT Points FROM leadbbs_user WHERE ID=${uid}`);
    // the backend page selects the account with Form_ID, not ID
    await p.goto(`${B}/manage/User/UserModify.asp?Form_ID=${uid}`, { waitUntil: 'domcontentloaded' });
    const pts = p.locator('input[name="Form_Points"]').first();
    const ok = await pts.count() > 0;
    rec('backend user-edit form renders for that user', ok, `user id ${uid}`);
    if (ok) {
      await pts.fill(String(Number(before || 0) + 777));
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
        p.locator('input[type="submit"]').first().click({ force: true }),
      ]);
      await p.waitForTimeout(1200);
    }
    const after = await dbOne(p, `SELECT Points FROM leadbbs_user WHERE ID=${uid}`);
    rec('backend edits the user record', Number(after) === Number(before || 0) + 777, `points ${before} -> ${after}`);
  }
}

// --- board category: create one, then confirm the LIST renders it -----------------
// The list is emitted as JavaScript row callbacks built with Recordset.GetString's
// delimiters (#30), so this also proves the RsGetString replacement on real data.
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_goodassort');
  const cname = 'Cat' + stamp;
  await p.goto(`${B}/manage/ForumBoard/ForumBoardAssort.asp?action=Join`, { waitUntil: 'domcontentloaded' });
  const nameBox = p.locator('input[name="LMT_AssortName"]').first();
  const ok = await nameBox.count() > 0;
  rec('board-category add form renders', ok);
  if (ok) {
    await nameBox.fill(cname);
    const order = p.locator('input[name="Form_AssortID"]').first();
    if (await order.count()) await order.fill('1');
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('form#form1 input[type="submit"]').first().click({ force: true }).catch(()=>{}),
    ]);
    await p.waitForTimeout(1200);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_goodassort');
  rec('creating a board category writes the row', after > before, `goodassort ${before}->${after}`);

  await p.goto(`${B}/manage/ForumBoard/ForumBoardAssort.asp`, { waitUntil: 'domcontentloaded' });
  const shown = (await p.locator('body').innerText()).includes(cname);
  rec('board-category list renders the new row (GetString path)', shown, cname);
}

// ------------------------------------------------------- the site log records it
{
  await p.goto(`${B}/manage/SiteManage/ForumLog.asp`, { waitUntil: 'domcontentloaded' });
  const rows = await p.locator('table tr').count();
  const logged = await dbNum(p, 'SELECT count(*) FROM leadbbs_log');
  rec('forum log page renders the recorded admin actions', rows > 3 && logged > 0, `${rows} rows, ${logged} log entries`);
}

await br.close();
process.exit(summary('08-adminops') ? 0 : 1);
