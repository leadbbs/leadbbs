// Admin panel + moderation, driven through the real UI.
import { B, rec, summary, browser, adminPage, db, dbNum, goTo } from './lib.mjs';
const br = await browser();
// adminPage() unlocks the backend and hands back a USABLE tab: the manage index is a
// frameset, and the tab that submits the unlock stops committing later navigations.
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin two-factor login reaches the control panel', adminOk);

// --- admin pages render (as an admin sees them) ---
// assert on a real marker for each page, not on text length (most content is in fields)
for (const [name, url, marker] of [
  ['user management', 'manage/User/UserManage.asp', '用户'],
  ['board management', 'manage/ForumBoard/ForumBoardManage.asp', '版面'],
  ['site settings', 'manage/SiteManage/SiteSetup.asp', '设置'],
  ['SQL executor', 'manage/Database/ExecuteString.asp', 'SQL'],
  ['CMS centre', 'article/center.asp', 'CMS'],
]) {
  await p.goto(`${B}/${url}`, { waitUntil:'domcontentloaded' });
  const body = await p.locator('body').innerText();
  rec(`${name} page renders for admin`, body.includes(marker) && !body.includes('管理员登陆'), marker);
}

// --- create a board through the real admin form ---
const bn = 'UIBoard' + Date.now().toString().slice(-5);
const bb = await dbNum(p, 'SELECT count(*) FROM leadbbs_boards');
await p.goto(`${B}/manage/ForumBoard/ForumBoardJoin.asp`, { waitUntil:'domcontentloaded' });
const freeId = 100 + Math.floor(Math.random()*800) + 1000;
await p.fill('input[name="GBL_BoardID"]', String(freeId)).catch(()=>{});
await p.fill('input[name="GBL_BoardName"]', bn).catch(e=>rec('board name field', false, e.message));
await p.evaluate(() => {           // pick the first real category in the assort select
  const s = document.querySelector('select[name="GBL_BoardAssort"]');
  if (s && s.options.length > 1) { s.selectedIndex = 1; s.dispatchEvent(new Event('change',{bubbles:true})); }
});
// fill the remaining required fields exactly as an admin would
await p.fill('input[name="GBL_LastWriter"]', 'admin').catch(()=>{});
// leave GBL_LastWriteTime at its pre-filled 14-digit timestamp (that is what the app expects)
await p.fill('input[name="GBL_TopicNum"]', '0').catch(()=>{});
await p.fill('input[name="GBL_AnnounceNum"]', '0').catch(()=>{});
await p.fill('textarea[name="GBL_BoardIntro"], input[name="GBL_BoardIntro"]', 'created by the browser test').catch(()=>{});
await Promise.all([
  p.waitForNavigation({waitUntil:'domcontentloaded'}).catch(()=>{}),
  p.locator('input[type="submit"]').first().click({force:true}).catch(()=>{}),
]);
await p.waitForTimeout(1500);
const ba = await dbNum(p, 'SELECT count(*) FROM leadbbs_boards');
rec('create a board via the admin UI', ba === bb + 1, `boards ${bb}->${ba} (${bn})`);

// ...and remove it again. A board left behind is not free: every one of them adds a distinct
// a2.asp?B=<id> / b.asp?B=<id> path, AxonASP retains ~5 MB of live heap per distinct path
// (README §32), and 07-links — which fetches every emitted URL — was tipping the server over
// its ceiling once a dozen of these had accumulated across runs.
if (ba === bb + 1) {
  await p.goto(`${B}/manage/ForumBoard/ForumBoardDelete.asp?GBL_DeleteID=${freeId}`,
               { waitUntil: 'domcontentloaded' });
  const del = p.locator('input[type="submit"]').first();
  if (await del.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      del.click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const bd = await dbNum(p, 'SELECT count(*) FROM leadbbs_boards');
  rec('and remove it again, so boards do not accumulate across runs', bd === bb,
      `boards ${ba}->${bd}`);
}

// --- moderation: delete a reply from the topic page menu ---
// Pick a real reply. This used to fall through to an empty string when no reply existed,
// and an empty id turns the locator below into a prefix match that ANY delete link satisfies
// -- so the check passed while replies were not threading at all. Assert we have one.
const rid = (await db(p, 'SELECT ID FROM leadbbs_announce WHERE ParentID>0 ORDER BY ID DESC LIMIT 1')).split('\n').pop().trim();
rec('a threaded reply exists to moderate', /^\d+$/.test(rid), rid ? `reply ${rid}` : 'no row with ParentID>0');
const pid = (await db(p, `SELECT ParentID FROM leadbbs_announce WHERE ID=${rid}`)).split('\n').pop().trim();
const cb = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
await p.goto(`${B}/a/a.asp?B=100&ID=${pid}`, { waitUntil:'domcontentloaded' });
// the per-post link must carry the POST id (it used to carry the author's user id
// -- AxonASP #27, duplicate column names in the SELECT)
const delLink = p.locator(`a[onclick*="Del&b=100&ID=${rid}"]`);
rec('per-post delete link targets the right post id', await delLink.count() > 0, `ID=${rid}`);
if (await delLink.count() > 0) {
  // a_command() -> layer_view() fetches the confirm form into #anc_delbody; submit it
  await delLink.first().click({force:true});
  await p.waitForSelector('#anc_delbody form', {timeout:8000}).catch(()=>{});
  await p.locator('#anc_delbody form input[type="submit"]').first().click({force:true}).catch(()=>{});
  await p.waitForTimeout(2500);
  const ca = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  const gone = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE ID=${rid}`);
  rec('delete a post through the UI', ca < cb && gone === 0, `announce ${cb}->${ca}, row ${rid} gone=${gone===0}`);
}

// --- no page may render a number in scientific notation ---
// AxonASP hands MySQL BIGINTs back as Doubles and prints them as 2.26151e+06 once they pass a
// million (§15/§22). Wherever that lands in a URL or a hidden field it is not an id any more:
// it silently broke every reply in this port, and the topic id in the mobile-version link.
{
  const tidNow = (await db(p, 'SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 1')).split('\n').pop().trim();
  const PAGES = ['/index.asp', '/Boards.asp', '/b/b.asp?B=100', `/a/a.asp?B=100&ID=${tidNow}`,
                 `/a/a2.asp?B=100&ID=${tidNow}`, `/a/EditAnnounce.asp?B=100&ID=${tidNow}`,
                 '/b/b.asp?B=0&action=list&type=1', '/Search/List.asp?1'];
  const bad = [];
  for (const u of PAGES) {
    await goTo(p, B + u).catch(()=>{});
    const hits = [...new Set((await p.content()).match(/\b\d(?:\.\d+)?e[+-]\d+\b/gi) || [])];
    if (hits.length) bad.push(`${u} -> ${hits.slice(0, 2).join(', ')}`);
  }
  rec('no page renders an id in scientific notation (§15/§22)',
      bad.length === 0, bad.length ? bad.slice(0, 3).join(' | ') : `${PAGES.length} pages clean`);
}

// --- the admin panel's own navigation must exist ---
// §51 + §6: /manage/ rendered only the inner info panel, with no tab bar, no left nav and no
// content iframe, so the entire backend was reachable only by typing URLs. Every suite here
// drives management pages BY URL, which is exactly how you work around the bug -- so 25 suites
// passed while the administrative interface was missing. Assert the shell a human needs.
{
  await goTo(p, `${B}/manage/Default.asp`);
  await p.waitForFunction(() => document.readyState === 'complete', null, { timeout: 15000 }).catch(()=>{});
  const shell = await p.evaluate(() => ({
    tabs:   document.querySelectorAll('[id^=nav_assort_]').length,
    lists:  document.querySelectorAll('[id^=nav_itemlist]').length,
    iframe: !!document.querySelector('iframe[name=mainFrame]'),
    boards: document.body.innerHTML.includes('ForumBoardManage.asp'),
  }));
  rec('the admin panel renders its shell: tab bar, nav column and content frame',
      shell.tabs >= 8 && shell.iframe, `${shell.tabs} tabs, iframe=${shell.iframe}`);
  rec('the admin nav actually contains its menu items',
      shell.lists >= 8 && shell.boards, `${shell.lists} item lists, board link=${shell.boards}`);

  // and the column fills in when a section is chosen, which is how a human reaches the pages
  const filled = await p.evaluate(() => {
    try { nav_assortsel(3); } catch (e) { return 'ERR ' + e.message; }
    const c = document.querySelector('#nav_itemlist0');
    return c ? c.innerText.replace(/\s+/g, ' ').trim() : '(no column)';
  });
  rec('choosing a section populates the nav column',
      /论坛版面管理/.test(String(filled)), String(filled).slice(0, 70));
}

await br.close();
process.exit(summary('04-admin') ? 0 : 1);
