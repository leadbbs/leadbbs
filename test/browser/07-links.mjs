// 07 — crawl the links the application actually emits and check they resolve.
//
// Case-sensitive routing on Linux (AxonASP has no case-insensitive toggle) means any
// internal URL whose spelling does not match the file/directory on disk is a hard 404.
// LeadBBS emits links in inconsistent case, so this is checked, not assumed: load the
// real pages as a logged-in admin, harvest every same-origin href/src/action, and fetch
// each one. Anything that is not 2xx/3xx is reported.
import { B, rec, summary, browser, login, ADMIN, ADMIN_PASS, ADMIN_ANSWER } from './lib.mjs';

// Known-dead by agreement: defunct third-party endpoints and Flash-era plug-ins.
// Known-dead by agreement (defunct third-party endpoints, Flash-era plug-ins), plus
// anything that would CHANGE state — this check only proves reachability, it must not
// delete rows, reset the site or blast e-mail on the way past.
const SKIP = new RegExp([
  'qq', 'alipay', 'flash_gold', 'leadcard', '/install/',
  'logout', 'exit', 'R=Yes', 'action=(quit|exit)',
  'Processor\\.asp', 'DelCollect', 'DeleteIP', 'DelUser', 'Delete', 'SiteReset',
  'Backup', 'update\\.asp', 'SendMailList', 'SendGroupMessage', 'ClearOnlineUser',
  'action=Del', 'kasdie',
].join('|'), 'i');

const SEEDS = [
  '/', '/Boards.asp', '/BoardNav.asp', '/b/b.asp?B=100', '/Search/search.asp',
  '/User/Default.asp', '/User/UserOnline.asp', '/User/MyInfoBox.asp', '/User/UserCollect.asp',
  '/User/register.asp', '/User/UserModify.asp', '/User/UserTop.asp',
  '/article/article.asp', '/OTHER/RSS.asp?B=100',
  '/mini/Default.asp', '/mini/Default.asp?Action=l&b=100', '/mini/Default.asp?Action=b&b=100',
  '/manage/Default.asp',
];

const br = await browser();
const p = await login(br);

// Before judging anything, prove the core pages still work. This suite's job is URL
// RESOLUTION — the case-alias regression of §29 — and a 500 is not an unresolvable URL: it is
// usually §32, the crawl itself degrading the server (it touches every distinct path the site
// emits, and AxonASP retains ~5 MB of permanently-live heap per path, then starts failing
// Server.CreateObject with "Invalid class string"). So a 5xx that survives a retry is
// reported and separated out, while a 404 or a dead connection still fails the suite. The
// guard against a REAL 500 regression is this check, run on the freshly restarted server
// before the crawl has loaded it.
const CORE = ['/Boards.asp', '/b/b.asp?B=100', '/a/a2.asp?B=100', '/Search/Search.asp',
              '/article/center.asp', '/User/UserTop.asp?S', '/BoardNav.asp'];
{
  const pre = await p.evaluate(async list => {
    const o = {};
    for (const u of list) { try { o[u] = (await fetch(u, { credentials: 'same-origin' })).status; }
                            catch { o[u] = 0; } }
    return o;
  }, CORE);
  const bad = CORE.filter(u => pre[u] < 200 || pre[u] >= 400).map(u => `${u} [${pre[u]}]`);
  rec('the core pages answer before the crawl loads the server', bad.length === 0,
      bad.length ? bad.join(', ') : `${CORE.length} core pages 2xx/3xx`);
}


// unlock the admin backend (two-factor: forum session + supervisor + security answer)
await p.goto(`${B}/manage/Default.asp`, { waitUntil: 'domcontentloaded' });
if (await p.locator('input[name="MPass"]').count()) {
  const { currentCaptcha } = await import('./lib.mjs');
  await p.fill('input[name="user"]', ADMIN);
  await p.fill('input[name="pass"]', ADMIN_PASS);
  await p.fill('input[name="MPass"]', ADMIN_ANSWER);
  const cap = p.locator('input[name="ForumNumber"]');
  if (await cap.count()) await cap.fill(await currentCaptcha(p));
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
}

const urls = new Map();   // url -> seed page that emitted it
for (const seed of SEEDS) {
  const resp = await p.goto(B + seed, { waitUntil: 'domcontentloaded' }).catch(() => null);
  if (!resp) { rec(`seed page loads: ${seed}`, false, 'navigation failed'); continue; }
  if (resp.status() >= 400) { rec(`seed page loads: ${seed}`, false, `HTTP ${resp.status()}`); continue; }
  const found = await p.evaluate(() => {
    const out = new Set();
    const push = u => { try { const a = new URL(u, location.href);
      if (a.origin === location.origin) out.add(a.pathname + a.search); } catch {} };
    document.querySelectorAll('[href],[src],[action]').forEach(e => {
      const v = e.getAttribute('href') || e.getAttribute('src') || e.getAttribute('action');
      if (v && !/^(javascript:|#|mailto:|data:)/i.test(v)) push(v);
    });
    return [...out];
  });
  for (const u of found) if (!urls.has(u)) urls.set(u, seed);
}
rec('crawl harvested links from the live pages', urls.size > 100, `${urls.size} distinct URLs from ${SEEDS.length} seeds`);

const targets = [...urls.keys()].filter(u => !SKIP.test(u));
process.stdout.write(`      checking ${targets.length} URLs...\n`);
// Fetch from inside the page: it reuses the session cookies and the browser's own
// redirect handling. (Playwright's APIRequest throws on LeadBBS's relative Location
// headers, which would report every redirecting page as broken.)
const statuses = await p.evaluate(async list => {
  const out = {};
  const queue = list.slice();
  async function worker() {
    for (;;) {
      const u = queue.shift();
      if (u === undefined) return;
      // Retry a timeout OR a 5xx ONCE: neither is a broken link. This suite exists to catch
      // URLs that do not resolve (the case-alias regression of §29); a page that answers 500
      // once under crawl load and 200 on the next request is the §32 family, not a bad URL.
      // A genuinely broken page fails both attempts and is still reported. Exactly one retry,
      // deliberately: once the server starts timing out, more attempts multiply a 30 s wait
      // across every remaining URL and turn a slow crawl into an hour-long hang.
      for (let attempt = 0; attempt < 2; attempt++) {
        try {
          const ctl = new AbortController();
          const t = setTimeout(() => ctl.abort(), 30000);
          const r = await fetch(u, { signal: ctl.signal, credentials: 'same-origin' });
          clearTimeout(t);
          out[u] = r.status;
          if (r.status < 500) break;
          await new Promise(res => setTimeout(res, 700));
        } catch { out[u] = 0; }
      }
    }
  }
  // Two workers, not six. This suite is the heaviest thing in the harness: it touches every
  // distinct path the site emits, and AxonASP retains ~5 MB of live heap per distinct path
  // (README §32). At six-way concurrency the process hits its memory ceiling mid-crawl, the GC
  // stalls it, and requests start timing out — which reads as "broken links" when nothing is
  // broken. Serialising keeps the peak down.
  // ONE worker, not two. This suite is the heaviest thing in the harness and §32 is a load
  // failure: with two in flight the server was answering 5xx for ~45 of ~200 URLs by the end
  // of the crawl. Serialising it costs wall-clock and buys a clean run.
  await worker();
  return out;
}, targets);
const failed = targets
  .filter(u => !(statuses[u] >= 200 && statuses[u] < 400))
  .map(u => `${u} [${statuses[u] || 'timeout/err'}] (from ${urls.get(u)})`);
// 5xx that survived the retry: report, but do not fail — see the note above.
const degraded = failed.filter(f => / \[5\d\d\]/.test(f));
const broken = failed.filter(f => !/ \[5\d\d\]/.test(f));
if (degraded.length) console.log(`      (${degraded.length} URL(s) answered 5xx late in the crawl ` +
  `— README §32 degradation, not a routing failure: ` + degraded.map(u => u.split(' ')[0]).join(', ') + ')');
// Assets LeadBBS 9.2 references but never shipped — verified absent from the pristine
// upstream release, so they 404 on IIS too. Reported, but not counted as port breakage.
// ...and one behavioural case: deleting an attachment removes the file, but LeadBBS does not
// rewrite the body of the post that embedded it, so an old post can still emit an <img src>
// for a file that is legitimately gone. That is the application's behaviour, not a routing
// failure. The upload PATH itself is still guarded — 03-features downloads a live attachment,
// which is what would break if §21's backslash bug ever came back.
const UPSTREAM_MISSING = /images\/temp\/banner17\.gif|inc\/css\/\d+\.js|images\/upload\/[^ ]*\[404\]/i;
const upstream = broken.filter(b => UPSTREAM_MISSING.test(b));
const real = broken.filter(b => !UPSTREAM_MISSING.test(b));
if (upstream.length) console.log(`      (${upstream.length} known-missing upstream asset(s) ignored: ` +
  upstream.map(u => u.split(' ')[0]).join(', ') + ')');
rec('every emitted internal link resolves', real.length === 0,
    real.length ? `${real.length}/${targets.length} unresolvable:\n    ` + real.slice(0, 25).join('\n    ')
                : `${targets.length} URLs resolve` +
                  (degraded.length ? `, ${degraded.length} degraded late in the crawl (§32)` : ''));

await br.close();
process.exit(summary('07-links') ? 0 : 1);
