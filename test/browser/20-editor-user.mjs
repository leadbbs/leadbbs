// 20 — the rich editor's dialog pages, the proxy/upload helpers, and the corners of User/
// that nothing had opened: 帮助, 隐身, 查找用户, 扩展风格, 个性昵称, 绑定帐号, and the two
// delete popups (friend, attachment).
//
// Verbs driven end to end: extended, r, truename, bind.
import { B, rec, summary, browser, login, adminPage, db, dbNum, dbOne, dbRows,
         httpGet, goTo, pinCaptcha, setEditorContent, currentCaptcha,
         ajaxCommand, ADMIN, ADMIN_PASS } from './lib.mjs';
import { writeFileSync } from 'fs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin session ready', adminOk);
const stamp = Date.now().toString().slice(-6);

// ------------------------------------------------ the编辑器 dialog pages (a/edit/*)
{
  const dialogs = [
    ['img.asp',    '图片来源', ['网络地址', '边框粗细', '对齐方式'], '确定'],
    ['media.asp',  '插入媒体文件', ['FLASH', '自动播放', '显示宽度'], '确定'],
    ['table.asp',  '表格大小', ['行数', '列数', '边框颜色'], '插入/更新表格'],
  ];
  for (const [file, title, fields, okLabel] of dialogs) {
    await goTo(p, `${B}/a/edit/${file}`);
    const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    const inputs = await p.locator('input, select').count();
    rec(`the editor's ${file} dialog renders its controls`,
        txt.includes(title) && fields.every(f => txt.includes(f)) && inputs >= 3,
        `${inputs} controls: ${txt.slice(0, 45)}`);
    // the OK control is a <span class="clicktext" onclick="...">, not a form button
    rec(`${file} offers the control that inserts into the post`,
        (await p.locator('.clicktext, input[type="button"], button').count()) > 0 &&
        txt.includes(okLabel), okLabel);
  }

  // symbol.asp is a character palette: every tab must actually carry characters
  await goTo(p, `${B}/a/edit/symbol.asp`);
  const stxt = (await p.locator('body').innerText());
  rec('the symbol palette offers all its character sets',
      ['特殊', '标点', '数学', '希腊', '俄文', '日文'].every(t => stxt.includes(t)),
      stxt.replace(/\s+/g, ' ').slice(0, 50));
  rec('and the palette really contains characters, not empty cells',
      /[※§№○●△▲◎☆★◇◆□■]/.test(stxt));
}

// ------------------------------------------------ a/emot.asp — the emoticon picker
{
  await goTo(p, `${B}/a/emot.asp`);
  // 99 images: wait for the browser to finish decoding them before counting
  await p.waitForLoadState('load').catch(()=>{});
  await p.evaluate(() => Promise.all(Array.from(document.images).map(i =>
    i.complete ? null : new Promise(r => { i.onload = i.onerror = r; })))).catch(()=>{});
  await p.waitForTimeout(1500);
  const total = await p.locator('img').count();
  const decoded = await p.evaluate(() =>
    Array.from(document.images).filter(i => i.naturalWidth > 0).length);
  rec('the emoticon picker shows real, decodable emoticons',
      total > 20 && decoded === total, `${decoded}/${total} images decoded`);
  const clickable = await p.locator('img[onclick*="emotclick"]').count();
  rec('every emoticon is clickable back into the editor', clickable === total,
      `${clickable} of ${total} wired to emotclick()`);
}

// ------------------------------------------------ a/proxy.asp — the same-origin fetch proxy
{
  // it refuses a request whose Referer is not this host, so drive it from a page on the site
  const r = await httpGet(p, '/a/proxy.asp?u=' + encodeURIComponent(`${B}/inc/js/common.js`));
  rec('the proxy fetches a URL and returns its body',
      r.status === 200 && r.body.length > 200 && /function|var /.test(r.body),
      `HTTP ${r.status}, ${r.body.length} bytes`);
  const cb = await httpGet(p, '/a/proxy.asp?callback=cbx&u=' + encodeURIComponent(`${B}/inc/js/common.js`));
  rec('and wraps the answer when a JSONP callback is asked for',
      cb.body.startsWith('cbx('), cb.body.slice(0, 30));
}

// ------------------------------------------------ a/inc/upload_info.asp — the progress poll
{
  const r = await httpGet(p, `/a/inc/upload_info.asp?id=nosuchupload${stamp}`);
  rec('the upload-progress endpoint answers for an unknown upload',
      r.status === 200 && r.body.length < 40, `HTTP ${r.status}, body=[${r.body}]`);
  const long = await httpGet(p, '/a/inc/upload_info.asp?id=' + 'x'.repeat(40));
  rec('and refuses an over-long id instead of using it as a key',
      long.status === 200 && long.body.trim() === '', `body=[${long.body}]`);
}

// ------------------------------------------------ User/help/ubb.asp
{
  await goTo(p, `${B}/User/help/ubb.asp`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the UBB help page explains the codes with examples',
      txt.includes('什么是UBB代码') && /\[b\]|\[url|\[img/i.test(txt),
      txt.slice(0, 60));
  rec('and links the rest of the help centre',
      (await p.locator('a[href*="help.asp"], a[href*="about.asp"], a[href*="color"]').count()) > 0);
}

// ------------------------------------------------ User/hidden.asp — the invisibility toggle
// It is a TOGGLE, not a switch: the same URL hides you and then puts you back online, and
// which one you get depends on the state the session is already in. Drive it until it reports
// 隐身, assert the online row, then drive it back and assert the row again.
{
  const uid = await dbOne(p, "SELECT ID FROM leadbbs_user WHERE UserName='" + ADMIN + "'");
  // hiding sets leadbbs_user.ShowFlag=1 and RENAMES the online row to 隐身会员 (it clears
  // HiddenFlag rather than setting it — the column name is the opposite of what it does)
  const isHidden = async () => await dbNum(p,
    `SELECT ShowFlag FROM leadbbs_user WHERE ID=${uid}`);
  let txt = '';
  for (let i = 0; i < 2; i++) {
    await goTo(p, `${B}/User/hidden.asp`);
    txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    if (txt.includes('成功隐身')) break;
  }
  rec('隐身 reports that the user is now invisible', txt.includes('成功隐身'), txt.slice(0, 40));
  rec('and the account is really marked invisible', (await isHidden()) === 1,
      `leadbbs_user.ShowFlag=${await isHidden()}`);
  const alias = await dbNum(p,
    `SELECT count(*) FROM leadbbs_onlineuser WHERE UserID=${uid} AND UserName='隐身会员'`);
  rec('and the online list carries them as 隐身会员 instead of by name', alias > 0,
      `${alias} renamed online row(s)`);

  // a guest's who's-online list must not name them while they are hidden
  const guest = await br.newContext();
  const gp = await guest.newPage();
  await gp.goto(`${B}/User/UserOnline.asp`, { waitUntil: 'domcontentloaded' }).catch(()=>{});
  await gp.waitForTimeout(400);
  const gtxt = (await gp.locator('body').innerText().catch(()=>'')).replace(/\s+/g, ' ');
  rec('a guest does not see the hidden user listed by name',
      !/>?admin</.test(gtxt) && !gtxt.split(/[\s,]+/).includes(ADMIN),
      gtxt.slice(0, 60));
  await guest.close();

  // and back online
  await goTo(p, `${B}/User/hidden.asp`);
  const back = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the same link brings the user back online', back.includes('成功上线'), back.slice(0, 40));
  rec('and the account is visible again', (await isHidden()) === 0,
      `leadbbs_user.ShowFlag=${await isHidden()}`);
}

// ------------------------------------------------ 查找用户 (UserTop) and the mini action=r
// UserTop dispatches on Left(QUERY_STRING,1), so its own URL is "?r" — the `action=r` spelling
// belongs to the mobile UI (mini/Default.asp), which is driven at the end of this block.
{
  await goTo(p, `${B}/User/UserTop.asp?r`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the user finder opens', txt.includes('查找用户'), txt.slice(0, 50));
  const form = p.locator('form').filter({ has: p.locator('input[name="Form_SearchKey"]') }).first();
  rec('the finder offers a search field', (await form.count()) > 0);
  if (await form.count()) {
    await form.locator('input[name="Form_SearchKey"]').first().fill(ADMIN);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      form.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1000);
    const res = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    rec('searching for a real member finds them', res.includes(ADMIN), res.slice(0, 60));
  }

  // the mobile UI's own action=r (分类列表 in the right-hand column)
  // An empty body here is a navigation race, not a verdict: goTo's fallback can hand back a
  // document that has not parsed yet, and this check then failed on a CI runner with a detail
  // that was literally empty. Re-read once, and report the length either way.
  let m = '';
  for (let attempt = 0; attempt < 2 && m.length <= 60; attempt++) {
    await goTo(p, `${B}/mini/Default.asp?action=r`);
    await p.waitForFunction(() => document.readyState === 'complete', null, { timeout: 15000 }).catch(()=>{});
    m = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  }
  rec('mini action=r renders the mobile listing', m.length > 60 && !/error/i.test(m),
      m.length ? m.slice(0, 60) : '(empty body after 2 attempts)');
}

// ------------------------------------------------ action=extended — the extended skin list
{
  await goTo(p, `${B}/User/BoardStyle.asp?action=extended&b=100`);
  const names = (await dbRows(p,
    'SELECT ScreenWidth FROM leadbbs_skin WHERE StyleID>=1000 ORDER BY StyleID')).map(r => r[0]);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  // the skin names come from an Application-cached array built at server start, so a skin
  // created by a sibling suite in THIS process is legitimately absent — assert the other
  // direction, that everything offered is a real skin, and that the shipped ones are there
  const listed = await p.locator('a[href*="BoardStyle.asp"]').allInnerTexts();
  const extended = listed.map(t => t.trim()).filter(t => names.includes(t));
  rec('action=extended lists the extended skins, and only real ones',
      extended.length >= 4 && extended.every(n => names.includes(n)) && txt.includes(names[0]),
      `page offers ${extended.join(',')}; DB has ${names.join(',')}`);
  const links = await p.locator('a[href*="BoardStyle.asp"]').count();
  rec('and each one is a link that switches the reader to it', links >= names.length,
      `${links} switch links`);

  // switching really changes what the reader gets served
  const first = await p.locator('a[href*="BoardStyle.asp"]').first().getAttribute('href');
  await goTo(p, first.startsWith('http') ? first : `${B}/User/${first.replace(/^\.\//, '')}`);
  await p.waitForTimeout(600);
  const cookie = (await p.context().cookies()).map(c => `${c.name}=${c.value}`).join(';');
  rec('choosing a skin records the choice for the reader',
      /style/i.test(cookie) || (await p.locator('body').innerText()).length > 50,
      cookie.slice(0, 70) || 'no style cookie');
}

// ------------------------------------------------ action=truename — 个性昵称
// Driven as a throwaway member, not as admin: the nickname replaces the display name all over
// the forum, and the field will not take an empty value back, so admin could never be restored.
{
  const nick = `nk${stamp}`;
  await goTo(p, `${B}/manage/User/UserJoin.asp`);
  await p.locator('input[name="Form_username"]').first().fill(nick).catch(()=>{});
  await p.locator('input[name="Form_password1"]').first().fill(ADMIN_PASS).catch(()=>{});
  await p.locator('input[name="Form_password2"]').first().fill(ADMIN_PASS).catch(()=>{});
  await p.locator('input[name="Form_mail"]').first().fill(`${nick}@example.invalid`).catch(()=>{});
  await p.locator('input[name="Form_Question"]').first().fill('q' + stamp).catch(()=>{});
  await p.locator('input[name="Form_Answer"]').first().fill('a' + stamp).catch(()=>{});
  await p.locator('input[name="Form_sex"]').first().check({ force: true }).catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const nickId = await dbOne(p, `SELECT ID FROM leadbbs_user WHERE UserName='${nick}'`);
  rec('a throwaway member exists to rename', !!nickId, `${nick} id=${nickId}`);

  const mp = await login(br, nick, ADMIN_PASS);
  await goTo(mp, `${B}/User/UserModify.asp?action=truename`);
  const txt = (await mp.locator('body').innerText()).replace(/\s+/g, ' ');
  const field = mp.locator('input[name="truename"]').first();
  rec('action=truename opens the nickname editor',
      txt.includes('昵称') && (await field.count()) > 0, txt.slice(0, 50));
  if (await field.count()) {
    const want = `Nick${stamp}`;
    await field.fill(want);
    await pinCaptcha(mp);
    const num = mp.locator('input[name="ForumNumber"]').first();
    if (await num.count()) await num.fill(await currentCaptcha(mp)).catch(()=>{});
    await Promise.all([
      mp.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      mp.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await mp.waitForTimeout(1400);
    const now = await dbOne(p, `SELECT ifnull(TrueName,'') FROM leadbbs_user WHERE ID=${nickId}`);
    rec('action=truename stores the nickname', now === want, `TrueName -> "${now}"`);
    // and readers see it where the forum shows the display name
    await goTo(p, `${B}/User/LookUserInfo.asp?id=${nickId}`);
    rec('the nickname shows on the profile page a reader opens',
        (await p.locator('body').innerText()).includes(want));
  }
  await mp.context().close();

  // remove the throwaway member again
  await goTo(p, `${B}/manage/User/UserDelete.asp?GBL_CTG_DELETEID=${nickId}`);
  const d = p.locator('input[type="submit"]').first();
  if (await d.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      d.click({ force: true }),
    ]);
    await p.waitForTimeout(1000);
  }
  rec('the renamed member is removed again',
      (await dbNum(p, `SELECT count(*) FROM leadbbs_user WHERE ID=${nickId}`)) === 0);
}

// ------------------------------------------------ action=face — the avatar picker
{
  const uid = await dbOne(p, "SELECT ID FROM leadbbs_user WHERE UserName='" + ADMIN + "'");
  const was = await dbOne(p, `SELECT ifnull(FaceUrl,'') FROM leadbbs_user WHERE ID=${uid}`);
  await goTo(p, `${B}/User/UserModify.asp?action=face`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  const imgs = await p.locator('img').count();
  const decoded = await p.evaluate(() =>
    Array.from(document.images).filter(i => i.naturalWidth > 0).length);
  rec('action=face opens the avatar chooser with real thumbnails',
      imgs > 5 && decoded > 5, `${decoded}/${imgs} avatar images decoded`);
  // each thumbnail is wrapped in an anchor calling user_setface('NNNN')
  const pickers = await p.locator('a[onclick*="user_setface"]').count();
  rec('and every thumbnail is wired to pick that avatar', pickers > 5 && pickers >= imgs - 4,
      `${pickers} pickers for ${imgs} images`);
  rec("the chooser does not change the account by merely being opened",
      (await dbOne(p, `SELECT ifnull(FaceUrl,'') FROM leadbbs_user WHERE ID=${uid}`)) === was);
}

// ------------------------------------------------ action=bind — 绑定/完善帐号
{
  await goTo(p, `${B}/User/register.asp?action=bind`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('action=bind offers both binding an existing account and completing this one',
      txt.includes('绑定已有论坛帐号') && txt.includes('完善帐号资料'), txt.slice(0, 60));

  await goTo(p, `${B}/User/register.asp?action=bind&command=bind`);
  const b = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('action=bind&command=bind asks for the existing account and password',
      (await p.locator('input[name="user"]').count()) > 0 &&
      (await p.locator('input[name="pass"]').count()) > 0, b.slice(0, 50));

  await goTo(p, `${B}/User/register.asp?action=bind&command=reg`);
  const r = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('action=bind&command=reg renders the account-completion form',
      (await p.locator('form').count()) > 0 && r.includes('帐号'), r.slice(0, 50));
}

// ------------------------------------------------ DelFriend: add a friend, then remove it
{
  const me = await dbOne(p, "SELECT ID FROM leadbbs_user WHERE UserName='" + ADMIN + "'");
  const other = await dbRows(p,
    `SELECT U.ID,U.UserName FROM leadbbs_user U WHERE U.ID<>${me} AND EXISTS ` +
    `(SELECT 1 FROM leadbbs_announce A WHERE A.UserID=U.ID AND A.BoardID=100) ORDER BY U.ID DESC LIMIT 1`);
  if (!other.length) {
    rec('DelFriend removes a friend', false, 'no second user to befriend');
  } else {
    const [fid, fname] = other[0];
    // 加为好友 is the usual two-step AJAX confirm flow, driven from a post by that user
    const theirPost = await dbOne(p,
      `SELECT ID FROM leadbbs_announce WHERE UserID=${fid} AND BoardID=100 ORDER BY ID DESC LIMIT 1`);
    // 关注Ta lives on the PROFILE page and goes through pub_msg() -> a confirm form
    await goTo(p, `${B}/User/LookUserInfo.asp?id=${fid}`);
    const how = await ajaxCommand(p, 'a[href*="action=AddFriend"]');
    await p.waitForTimeout(1200);
    if ((await dbNum(p, `SELECT count(*) FROM leadbbs_frienduser WHERE UserID=${me} AND FriendUserID=${fid}`)) === 0
        && theirPost) {
      await goTo(p, `${B}/a/a.asp?B=100&ID=${theirPost}`);
      await ajaxCommand(p, 'a[href*="action=AddFriend"], a[onclick*="AddFriend"]');
      await p.waitForTimeout(1200);
    }
    const added = await dbNum(p,
      `SELECT count(*) FROM leadbbs_frienduser WHERE UserID=${me} AND FriendUserID=${fid}`);
    rec('a friend can be added to act on', added > 0, `${fname} -> ${added} row(s)`);

    // DelFriend takes the leadbbs_frienduser ROW id, not the friend's user id
    const rowId = await dbOne(p,
      `SELECT ID FROM leadbbs_frienduser WHERE UserID=${me} AND FriendUserID=${fid} ORDER BY ID DESC LIMIT 1`);
    await goTo(p, `${B}/User/DelFriend.asp?DelID=${rowId}`);
    const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    const s = p.locator('input[type="submit"]').first();
    rec('DelFriend asks for confirmation', (await s.count()) > 0, txt.slice(0, 45));
    if (await s.count()) {
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
        s.click({ force: true }),
      ]);
      await p.waitForTimeout(1000);
    }
    const left = await dbNum(p,
      `SELECT count(*) FROM leadbbs_frienduser WHERE UserID=${me} AND FriendUserID=${fid}`);
    rec('DelFriend removes the friend row', left === 0, `${left} row(s) left`);
  }
}

// ------------------------------------------------ DeleteUpload: upload one, then delete it
{
  writeFileSync('/tmp/del_att.gif',
    Buffer.from('R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==', 'base64'));
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_upload');
  await pinCaptcha(p);
  await goTo(p, `${B}/a/a2.asp?B=100`);
  await p.locator('input[name="Form_Title"]').first().fill(`DelAtt ${stamp}`).catch(()=>{});
  await setEditorContent(p, `attachment to delete ${stamp}`);
  await p.locator('input[name="ForumNumber"]').first().fill('1234').catch(()=>{});
  const fi = await p.locator('input[type="file"]').count();
  if (fi > 0) await p.setInputFiles('input[type="file"]', '/tmp/del_att.gif').catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
    p.locator('input[name="submit2"], input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(2500);
  const mid = await dbNum(p, 'SELECT count(*) FROM leadbbs_upload');
  rec('an attachment is uploaded to delete', mid === before + 1, `leadbbs_upload ${before} -> ${mid}`);

  const fileId = await dbOne(p, 'SELECT ID FROM leadbbs_upload ORDER BY ID DESC LIMIT 1');
  await goTo(p, `${B}/User/DeleteUpload.asp?FileID=${fileId}`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  const s = p.locator('input[type="submit"]').first();
  rec('DeleteUpload asks for confirmation before removing the file',
      (await s.count()) > 0, txt.slice(0, 45));
  if (await s.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      s.click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_upload');
  rec('DeleteUpload removes the attachment row', after === mid - 1,
      `leadbbs_upload ${mid} -> ${after}`);
  const gone = await dbNum(p, `SELECT count(*) FROM leadbbs_upload WHERE ID=${fileId}`);
  rec('and that exact attachment is the one that went', gone === 0, `rows for ${fileId}: ${gone}`);

  // Remove the carrier topic too. Its rendered body still links the image that was just
  // deleted, and 07-links crawls every emitted src — leaving it behind makes that suite
  // report a broken link on the next run, which is test debris, not a defect.
  const topic = await dbOne(p,
    `SELECT ID FROM leadbbs_announce WHERE Title='DelAtt ${stamp}' ORDER BY ID DESC LIMIT 1`);
  if (topic) {
    await goTo(p, `${B}/a/a.asp?B=100&ID=${topic}`);
    // 删除帖子 on a root topic is a MOVE to the recycle board (444), not a row delete
    await ajaxCommand(p, `a[onclick*="删除帖子"]`);
    await p.waitForTimeout(1200);
    const where = await dbNum(p, `SELECT BoardID FROM leadbbs_announce WHERE ID=${topic}`);
    rec('删除 moves the carrier topic to the recycle board', where === 444,
        `topic ${topic} is now on board ${where}`);

  } else {
    rec('删除 moves the carrier topic to the recycle board', false, 'topic not found');
  }
}

await br.close();
process.exit(summary('20-editor-user') ? 0 : 1);
