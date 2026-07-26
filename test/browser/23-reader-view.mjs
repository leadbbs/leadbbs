// 23 — what a NON-admin sees. Every other suite drives the forum as `admin`, and two bugs
// hid in that blind spot for the whole of this pass:
//
//   * §27 (duplicate column names) — `b/inc/Board_fun.asp` selected `T1.id` and `T2.ID` in the
//     same list, so the board's topic list handed out the AUTHOR'S USER ID as the post id and
//     every link on it led to "指定的帖子不存在或已被删除。". Admin never saw it because the
//     admin path serves the cached list from `b/inc/cache_fun.asp`, whose copy of the query
//     was already aliased.
//   * §43 (non-ASCII regex escape) — posting a topic wrote the row and THEN raised 800A1399,
//     so the poster got an error page for a post that had actually been created.
//
// Suite 06 already posts as an ordinary member and it passed throughout, because it asserted
// `announce count went up`. That is the trap docs/coverage-gaps.md warns about: the flow
// completing is not the user succeeding. Everything here asserts a rendered artefact — the
// page a reader gets when they click the link.
import { B, rec, summary, browser, login, goTo, dbOne, dbNum, dbRows,
         setEditorContent, currentCaptcha, loadCaptcha, setSelect } from './lib.mjs';

const br = await browser();
const stamp = Date.now().toString().slice(-7);
const NAME = 'rv' + stamp;
const PASS = 'rvpass123';
const BOARD = 100;

const isError = t => /Server Application error|800A[0-9A-F]{4}|error parsing regexp/i.test(t);
const text = p => p.evaluate(() => document.body.innerText.replace(/\s+/g, ' '));

// ------------------------------------------------------------------- a fresh member
const ctx = await br.newContext();
const rp = await ctx.newPage();
rp.on('dialog', d => d.accept());
await rp.goto(`${B}/User/register.asp`, { waitUntil: 'domcontentloaded' });
await Promise.all([
  rp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
  rp.locator('input[value="我同意"]').click({ force: true }),
]);
if (await rp.locator('input[name="Form_username"]').count()) {
  await rp.fill('input[name="Form_username"]', NAME);
  await rp.fill('input[name="Form_password1"]', PASS);
  await rp.fill('input[name="Form_password2"]', PASS);
  await rp.locator('input[name="moreinfo"]').check({ force: true });
  await rp.waitForTimeout(300);
  await setSelect(rp, 'select[name="sel_question"]', '我的家乡是？');
  await rp.fill('input[name="Form_Answer"]', 'rvanswer');
  await rp.fill('input[name="ForumNumber"]', await loadCaptcha(rp));
  await Promise.all([
    rp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    rp.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await rp.waitForTimeout(1200);
}
const uid = await dbOne(rp, `SELECT ID FROM leadbbs_user WHERE UserName='${NAME}'`);
rec('a brand-new account can be registered', !!uid, `${NAME} -> ${uid || 'none'}`);
await ctx.close();

// --------------------------------------------- that member posts, and SEES it succeed
const mp = await login(br, NAME, PASS);
const title = 'Reader ' + stamp;
let newId = 0;
{
  const before = Number(await dbOne(mp, 'SELECT max(ID) FROM leadbbs_announce'));
  await goTo(mp, `${B}/a/a2.asp?B=${BOARD}`);
  await mp.fill('input[name="Form_Title"]', title);
  // The @-mention is deliberate: it is what drives the character class that raised §43.
  await setEditorContent(mp, `Hello @admin — posted by ${NAME} through the browser.`);
  const cap = mp.locator('input[name="ForumNumber"]');
  if (await cap.count()) await cap.fill(await currentCaptcha(mp));
  await Promise.all([
    mp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    mp.locator('input[name="submit2"], input[type="submit"]').first().click({ force: true }),
  ]);
  await mp.waitForTimeout(2500);

  const posted = await text(mp);
  rec('posting a topic does not end on a server error page',
      !isError(posted), isError(posted) ? posted.slice(0, 120) : 'no error banner');

  newId = Number(await dbOne(mp, `SELECT ID FROM leadbbs_announce WHERE Title='${title}'`) || 0);
  rec('the topic row is written', newId > before, `id ${newId}`);

  // §43 aborted the request *after* the insert, so everything below the regex silently never
  // ran. The @-mention PM is the cheapest observable proof that it does now.
  const pm = await dbNum(mp, `SELECT count(*) FROM leadbbs_infobox WHERE ToUser='admin'` +
                             ` AND Content LIKE '%${title}%'`);
  rec('the code after the @-mention regex still runs (mention PM delivered)',
      pm >= 1, `${pm} notification(s) to admin`);
}

// --------------------------------------- the poster, and a stranger, can open the topic
async function opens(page, who) {
  await goTo(page, `${B}/a/a.asp?b=${BOARD}&id=${newId}`);
  const t = await text(page);
  rec(`${who} can open the new topic by its link`,
      !/不存在或已被删除/.test(t) && t.includes(title) && !isError(t),
      /不存在或已被删除/.test(t) ? 'told the post does not exist'
        : t.includes(title) ? 'title rendered' : 'title missing');
}
if (newId) {
  await opens(mp, 'the author');
  const gctx = await br.newContext();
  const gp = await gctx.newPage();
  await opens(gp, 'a logged-out reader');
  await gctx.close();
}

// ------------------------------------------------- every topic link a reader is offered
// The check that would have caught §27: not "how many links are there" but "does the row
// each link names actually exist". A link to a user id 404s into 指定的帖子不存在.
const PAGES = [
  ['/index.asp',                     'the front page'],
  ['/Boards.asp',                    'the board index'],
  [`/b/b.asp?B=${BOARD}`,            'the board topic list'],
  ['/b/b.asp?B=0&action=list&type=1','the newest-posts list'],
  ['/b/b.asp?B=0&action=list&type=2','the newest-replies list'],
  ['/Search/List.asp?1',             'the search list'],
];
for (const [url, what] of PAGES) {
  for (const [page, who] of [[mp, 'a member'], [null, 'a guest']]) {
    let p = page, own = null;
    if (!p) { own = await br.newContext(); p = await own.newPage(); }
    await goTo(p, B + url);
    const ids = [...new Set(await p.$$eval('a[href*="a.asp"]', as => as
      .map(a => (a.getAttribute('href').match(/[?&]id=(\d+)/i) || [])[1])
      .filter(Boolean)))];
    if (ids.length) {
      const real = Number(await dbOne(p, `SELECT count(*) FROM leadbbs_announce WHERE ID IN (${ids.join(',')})`));
      const users = Number(await dbOne(p, `SELECT count(*) FROM leadbbs_user WHERE ID IN (${ids.join(',')})`));
      rec(`every topic link ${who} is shown on ${what} points at a real post`,
          real === ids.length && users === 0,
          `${real}/${ids.length} resolve` + (users ? `, ${users} are USER ids (§27)` : ''));
    } else {
      rec(`${what} offers ${who} at least one topic link`, false, 'no a.asp?id= links found');
    }
    if (own) await own.close();
  }
}

// One link per page, actually followed, as a guest — the assertion above trusts the database
// about what the id means; this one trusts the browser about what the reader gets.
{
  const gctx = await br.newContext();
  const gp = await gctx.newPage();
  await goTo(gp, `${B}/b/b.asp?B=${BOARD}`);
  const href = await gp.$$eval('a[href*="a.asp"]', as => {
    const a = as.find(x => /[?&]id=\d+/i.test(x.getAttribute('href') || ''));
    return a ? a.getAttribute('href') : '';
  });
  if (href) {
    await goTo(gp, new URL(href, `${B}/b/`).href);
    const t = await text(gp);
    rec('following the first topic link on the board shows a post, not a "does not exist" page',
        !/不存在或已被删除/.test(t) && !isError(t), href.slice(0, 60));
  } else {
    rec('the board offers a followable topic link', false, 'none found');
  }
  await gctx.close();
}

await br.close();
summary('23-reader-view');
