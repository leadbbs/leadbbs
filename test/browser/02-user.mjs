// User-area flows, driven through the real UI.
import { B, rec, summary, browser, login, pinCaptcha, db, dbNum, dbOne, ADMIN, ADMIN_PASS } from './lib.mjs';
const br = await browser();
const p = await login(br);

// --- profile page reachable from the UI ---
await p.goto(`${B}/User/UserModify.asp`, { waitUntil:'domcontentloaded' });
rec('profile page opens', (await p.locator('input[name="Form_homepage"]').count()) > 0);

// --- edit profile by typing + clicking save ---
const hp = 'http://ui' + Date.now().toString().slice(-6) + '.example';
await p.fill('input[name="Form_homepage"]', hp).catch(()=>{});
await p.fill('input[name="oldpass"]', ADMIN_PASS).catch(()=>{});
await Promise.all([
  p.waitForNavigation({waitUntil:'domcontentloaded'}).catch(()=>{}),
  p.locator('form[name="LeadBBSFm"] input[type="submit"], input[name="submit"]').first().click({force:true}).catch(()=>{}),
]);
await p.waitForTimeout(1500);
const saved = await db(p, "SELECT Homepage FROM leadbbs_user WHERE UserName='" + ADMIN + "'");
rec('profile edit saves via the real form', saved.includes(hp), saved.split('\n').pop());

// --- private message: open the compose page and send ---
const before = await dbNum(p, "SELECT count(*) FROM leadbbs_infobox WHERE ToUser='testuser001'");
await p.goto(`${B}/User/SendMessage.asp?user=testuser001`, { waitUntil:'domcontentloaded' });
const mark = 'PMUI' + Date.now().toString().slice(-5);
await p.fill('input[name="SdM_ToUser"]', 'testuser001').catch(()=>{});
await p.fill('input[name="SdM_Title"]', 'Title ' + mark).catch(()=>{});
await p.evaluate(m => { const f=document.forms[0]; if(f.elements['SdM_Content']) f.elements['SdM_Content'].value='Body '+m; }, mark);
await Promise.all([
  p.waitForNavigation({waitUntil:'domcontentloaded'}).catch(()=>{}),
  p.locator('input[type="submit"]').first().click({force:true}).catch(()=>{}),
]);
await p.waitForTimeout(1500);
const after = await dbNum(p, "SELECT count(*) FROM leadbbs_infobox WHERE ToUser='testuser001'");
rec('send a private message through the UI', after === before + 1, `infobox ${before}->${after}`);

// --- recipient sees it in their inbox UI ---
const br2 = await browser();
const p2 = await login(br2, 'testuser001', 'Test123456');
await p2.goto(`${B}/User/MyInfoBox.asp`, { waitUntil:'domcontentloaded' });
rec('recipient sees the message in their inbox', (await p2.content()).includes(mark), mark);
await br2.close();

// --- who's online page renders users ---
await p.goto(`${B}/User/UserOnline.asp`, { waitUntil:'domcontentloaded' });
rec('who-is-online lists users', (await p.content()).includes(ADMIN));

// --- user profile/info page ---
await p.goto(`${B}/User/LookUserInfo.asp`, { waitUntil:'domcontentloaded' });
rec('user info page renders', (await p.locator('body').innerText()).length > 200);

// --- the page heading DisplayUserNavigate writes ---
// It was defined only in manage/inc/bbsmanage_fun.asp, which these pages do not include,
// so the heading silently vanished here (and would have been a hard error on IIS).
for (const [url, heading] of [
  ['User/UserCollect.asp', '我的帖子收藏夹'],
  ['User/UserDelete.asp', '用户自我删除'],
  ['User/Help/Cal.asp', '论坛日历'],
]) {
  await p.goto(`${B}/${url}`, { waitUntil: 'domcontentloaded' });
  const body = await p.locator('body').innerText();
  rec(`page heading renders on ${url}`, body.includes(heading), heading);
}

// --- §46: a seven-digit online-user id must render as digits, not 2.361371e+06 ---
// Three conditions have to line up before this heading renders at all, which is why the §46
// sweep and 04-admin's eight-page scientific-notation check both missed it: the viewer must not
// be a supervisor (a supervisor takes the username branch unless the subject is a guest), the
// subject's LeadBBS_onlineUser row must exist, and the id must be past a million. Every suite
// ran as the admin, and that table is auto-increment — so a fixture minutes old cannot reach
// the failing range, while a production forum's ids are seven digits. The seed therefore starts
// leadbbs_onlineuser at a realistic value; without that this check cannot fail.
await p.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });      // the admin's online row
const olid = await dbOne(p,
  "SELECT ID FROM leadbbs_onlineuser WHERE UserName='" + ADMIN + "' ORDER BY ID DESC LIMIT 1");
rec('the fixture has realistic online-user ids', olid.length >= 7,
    `id=${olid}${olid.length >= 7 ? '' : ' — below 7 digits this check cannot fail; seed ' +
     'leadbbs_onlineuser with AUTO_INCREMENT=2361371'}`);

const viewer = await login(br, 'testuser001', 'Test123456');   // a NON-supervisor viewer
await viewer.goto(`${B}/User/LookUserInfo.asp?Evol=more&OlID=${olid}`, { waitUntil:'domcontentloaded' });
await viewer.waitForTimeout(500);
const vtext = await viewer.locator('body').innerText();
const sci = vtext.match(/\d\.\d+e[+-]\d+/gi) || [];
rec('an online-user id is rendered as digits, not scientific notation',
    sci.length === 0, sci.length ? sci.join(', ') : 'no exponent notation on the page');
rec('the online-member heading names the id it was asked about',
    vtext.includes(`第[${olid}]号`),
    (vtext.split('\n').map(s => s.trim()).find(l => l.includes('号在线人员')) || '(heading missing)').slice(0, 70));

await br.close();
process.exit(summary('02-user') ? 0 : 1);
