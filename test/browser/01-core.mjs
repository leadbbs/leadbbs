// Core forum flows, driven through the real browser UI.
// goTo(), not page.goto(): on this 2-core box a navigation intermittently misses even
// domcontentloaded while the same URL fetches in milliseconds, and a raw goto then throws and
// takes the whole suite down after every check has already passed. goTo retries with 'commit'.
import { B, rec, summary, browser, login, isLoggedIn, pinCaptcha, db, dbNum, setEditorContent,
         goTo, dbRows, dbOne} from './lib.mjs';

const br = await browser();
const page = await login(br);
rec('login via the real login form', await isLoggedIn(page));

// --- board list shows boards, as a user sees them ---
await goTo(page, `${B}/Boards.asp`, { waitUntil:'domcontentloaded' });
rec('board list shows a board link', await page.locator('a[href*="b/b.asp"], a[href*="b.asp?b="]').count() > 0);

// --- open a board and see topics ---
await goTo(page, `${B}/b/b.asp?B=100`, { waitUntil:'domcontentloaded' });
const topicLinks = await page.locator('a[href*="a/a.asp"], a[href*="a.asp?b="]').count();
rec('board page lists topics', topicLinks > 0, `${topicLinks} topic links`);

// --- POST a new topic through the real editor + real submit button ---
const mark = 'UI' + Date.now().toString().slice(-6);
await pinCaptcha(page);
const before = await dbNum(page, 'SELECT count(*) FROM leadbbs_announce');
await goTo(page, `${B}/a/a2.asp?B=100`, { waitUntil:'domcontentloaded' });
await page.fill('input[name="Form_Title"]', 'Topic ' + mark).catch(e=>rec('post: title field', false, e.message));
await setEditorContent(page, 'Body of ' + mark + ' typed through the browser.');
await page.fill('input[name="ForumNumber"]', '1234').catch(()=>{});
await Promise.all([
  page.waitForNavigation({ waitUntil:'domcontentloaded' }).catch(()=>{}),
  page.locator('input[type="submit"]').first().click({ force:true }).catch(e=>rec('post: click submit', false, e.message)),
]);
await page.waitForTimeout(2000);
const after = await dbNum(page, 'SELECT count(*) FROM leadbbs_announce');
rec('post a topic by clicking the real submit button', after === before + 1, `announce ${before}->${after}`);

// --- the new topic is visible in the UI (board page) ---
await goTo(page, `${B}/b/b.asp?B=100`, { waitUntil:'domcontentloaded' });
let seen = (await page.content()).includes(mark);
if (!seen) {  // board list is Application-cached; the permalink is authoritative
  const row = await db(page, `SELECT ID FROM leadbbs_announce WHERE Title LIKE '%${mark}%' ORDER BY ID DESC LIMIT 1`);
  const tid = (row.match(/\d{5,}/)||[])[0];
  if (tid) { await goTo(page, `${B}/a/a.asp?B=100&ID=${tid}`, { waitUntil:'domcontentloaded' }); seen = (await page.content()).includes(mark); }
}
rec('new topic is visible in the forum UI', seen, mark);

// --- REPLY via the topic page reply form ---
const row = await db(page, `SELECT ID FROM leadbbs_announce WHERE Title LIKE '%${mark}%' ORDER BY ID DESC LIMIT 1`);
const tid = (row.match(/\d{5,}/)||[])[0];
if (tid) {
  await new Promise(r=>setTimeout(r, 11000));           // flood control
  await pinCaptcha(page);
  const rb = await dbNum(page, 'SELECT count(*) FROM leadbbs_announce');
  await goTo(page, `${B}/a/a2.asp?B=100&ID=${tid}`, { waitUntil:'domcontentloaded' });
  await page.fill('input[name="Form_Title"]', 'Re ' + mark).catch(()=>{});
  await setEditorContent(page, 'Reply body ' + mark);
  await page.fill('input[name="ForumNumber"]', '1234').catch(()=>{});
  await Promise.all([
    page.waitForNavigation({ waitUntil:'domcontentloaded' }).catch(()=>{}),
    page.locator('input[type="submit"]').first().click({ force:true }).catch(()=>{}),
  ]);
  await page.waitForTimeout(2000);
  const ra = await dbNum(page, 'SELECT count(*) FROM leadbbs_announce');
  // at least one: the reply form has been seen to post twice when the page's own onsubmit
  // fires alongside the click, and what matters is that the reply exists and renders
  rec('reply via the topic reply form', ra >= rb + 1, `announce ${rb}->${ra}`);

  // ...and that it is a REPLY, not a new topic. "The row count went up" was true for the
  // whole of this port while every reply was silently being stored as its own top-level
  // topic: the hidden ID field carried the parent id in scientific notation (§15/§22), so
  // a2.asp could not parse it and fell back to creating a topic. Assert the threading.
  const child = (await dbRows(page,
    `SELECT ID,ParentID,RootIDBak FROM leadbbs_announce WHERE Content LIKE '%Reply body ${mark}%' ORDER BY ID DESC LIMIT 1`))[0] || [];
  rec('the reply is threaded under its topic, not stored as a new topic',
      child[1] === String(tid) && child[2] === String(tid),
      child.length ? `reply ${child[0]}: ParentID=${child[1]} RootIDBak=${child[2]} (topic ${tid})` : 'no reply row found');
  const kids = await dbOne(page, `SELECT ChildNum FROM leadbbs_announce WHERE ID=${tid}`);
  rec("the topic's reply count is incremented", Number(kids) >= 1, `ChildNum=${kids}`);

  await goTo(page, `${B}/a/a.asp?B=100&ID=${tid}`, { waitUntil:'domcontentloaded' });
  rec('reply visible on the topic page', (await page.content()).includes('Reply body ' + mark));

  // The reply form ON THE TOPIC PAGE — the one an actual reader uses. It is a different code
  // path from a2.asp?ID=..., and it is the one that was broken: a/a.asp rendered the parent id
  // into its hidden field as a Currency, which AxonASP prints as 2.26e+06, so every reply made
  // this way became a new top-level topic instead. Post through it and check the threading.
  {
    await new Promise(r=>setTimeout(r, 11000));         // flood control
    await pinCaptcha(page);
    const mark2 = mark + 'B';
    const idField = await page.$$eval('#LeadBBSFm input[name=ID]', is => is.map(i => i.value));
    rec('the topic page hands its reply form a plain integer id',
        idField.length > 0 && /^\d+$/.test(idField[0]), `hidden ID=${idField[0] || '(none)'}`);
    await setEditorContent(page, 'Reply body ' + mark2);
    await page.fill('input[name="ForumNumber"]', '1234').catch(()=>{});
    await Promise.all([
      page.waitForNavigation({ waitUntil:'domcontentloaded' }).catch(()=>{}),
      page.locator('#LeadBBSFm input[name="submit2"]').first().click({ force:true }).catch(()=>{}),
    ]);
    await page.waitForTimeout(2500);
    const c2 = (await dbRows(page,
      `SELECT ID,ParentID FROM leadbbs_announce WHERE Content LIKE '%Reply body ${mark2}%' ORDER BY ID DESC LIMIT 1`))[0] || [];
    rec('replying from the topic page threads under the topic',
        c2[1] === String(tid), c2.length ? `reply ${c2[0]}: ParentID=${c2[1]} (topic ${tid})` : 'no reply row');
  }
} else rec('reply via the topic reply form', false, 'no topic id');

await br.close();
process.exit(summary('01-core') ? 0 : 1);
