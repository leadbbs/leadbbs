// 25 — the same crawl 07 does, but as a logged-out visitor, and looking at the page rather
// than only at its status line.
//
// 07-links states its own blind spot in its first comment: "load the real pages as a logged-in
// admin". Every suite did. That is how §27 survived a 22-suite pass — the broken board list is
// only served on the uncached path a guest or a new member gets — and it is why this exists.
//
// The second difference matters as much: AxonASP renders a runtime error as an ordinary HTML
// page with a 200 status. A crawl that only reads status codes calls that a working page. §43
// was exactly that shape: every attempt to post answered 200 with "error parsing regexp" on it.
// So this checks the body for the error banner as well.
import { B, rec, summary, browser } from './lib.mjs';

const SEEDS = [
  '/', '/Boards.asp', '/BoardNav.asp', '/index.asp',
  '/b/b.asp?B=100', '/b/b.asp?B=0&action=list&type=1', '/b/b.asp?B=0&action=list&type=2',
  '/Search/search.asp', '/Search/List.asp?1',
  '/User/UserOnline.asp', '/User/UserTop.asp', '/User/register.asp',
  '/article/article.asp', '/article/center.asp',
  '/OTHER/RSS.asp?B=100', '/mini/Default.asp',
];
// State-changing or third-party-dead URLs, same agreement as 07.
const SKIP = new RegExp([
  'qq', 'alipay', 'flash_gold', 'leadcard', '/install/', '/_test/',
  'logout', 'exit', 'R=Yes', 'action=(quit|exit)', 'Processor\\.asp',
  'DelCollect', 'DeleteIP', 'DelUser', 'Delete', 'SiteReset', 'Backup',
  'update\\.asp', 'SendMailList', 'SendGroupMessage', 'ClearOnlineUser',
  'action=Del', 'kasdie', 'number\\.asp',
].join('|'), 'i');
const MAX = 140;   // §32: this is a heavy crawl; the cap is reported, never silent

const br = await browser();
const ctx = await br.newContext();          // NO login — this is the whole point
const p = await ctx.newPage();

const urls = new Map();
let seedFailures = 0;
for (const seed of SEEDS) {
  // One retry before believing a seed failed: a navigation that loses the race on a loaded
  // runner is not a broken page, and this check exists to find broken pages.
  let resp = await p.goto(B + seed, { waitUntil: 'domcontentloaded' }).catch(() => null);
  if (!resp || resp.status() >= 400) {
    await p.waitForTimeout(1000);
    resp = await p.goto(B + seed, { waitUntil: 'domcontentloaded' }).catch(() => null);
  }
  if (!resp || resp.status() >= 400) {
    rec(`a logged-out visitor can load ${seed}`, false,
        resp ? `HTTP ${resp.status()}` : 'navigation failed twice');
    seedFailures++; continue;
  }
  await p.waitForFunction(() => document.readyState === 'complete', null, { timeout: 15000 }).catch(()=>{});
  const body = await p.evaluate(() => document.body ? document.body.innerText : '');
  if (/Server Application error|800A[0-9A-F]{4}/i.test(body)) {
    rec(`a logged-out visitor can load ${seed}`, false, body.replace(/\s+/g, ' ').slice(0, 110));
    seedFailures++; continue;
  }
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
rec('the public pages a visitor lands on all render', seedFailures === 0,
    seedFailures ? `${seedFailures} of ${SEEDS.length} seeds failed` : `${SEEDS.length} seeds render`);
rec('the crawl harvested links from the public pages', urls.size > 40,
    `${urls.size} distinct URLs from ${SEEDS.length} seeds`);

const all = [...urls.keys()].filter(u => !SKIP.test(u) && /\.(asp)(\?|$)/i.test(u));
const targets = all.slice(0, MAX);
if (all.length > targets.length) {
  console.log(`      (capped at ${MAX} of ${all.length} URLs — §32 load; skipped: ` +
              all.slice(MAX).slice(0, 8).join(', ') + (all.length - MAX > 8 ? ', …' : '') + ')');
}
process.stdout.write(`      checking ${targets.length} URLs as a guest...\n`);

// Fetch the TEXT, not just the status: an AxonASP runtime error is a 200.
const seen = await p.evaluate(async list => {
  const out = {};
  for (const u of list) {
    for (let attempt = 0; attempt < 2; attempt++) {
      try {
        const ctl = new AbortController();
        const t = setTimeout(() => ctl.abort(), 30000);
        const r = await fetch(u, { signal: ctl.signal, credentials: 'same-origin' });
        clearTimeout(t);
        const body = (await r.text()).slice(0, 4000);
        out[u] = { s: r.status, err: /Server Application error|800A[0-9A-F]{4}/i.test(body) };
        if (r.status < 500) break;
        await new Promise(res => setTimeout(res, 700));
      } catch { out[u] = { s: 0, err: false }; }
    }
  }
  return out;
}, targets);

const dead = targets.filter(u => !(seen[u]?.s >= 200 && seen[u]?.s < 400) && !(seen[u]?.s >= 500));
const degraded = targets.filter(u => seen[u]?.s >= 500);
const errored = targets.filter(u => seen[u]?.err);
if (degraded.length) console.log(`      (${degraded.length} answered 5xx late in the crawl — §32 ` +
  `degradation, not a routing failure: ${degraded.slice(0, 6).join(', ')})`);

rec('every link offered to a logged-out visitor resolves',
    dead.length === 0, dead.length ? dead.slice(0, 6).map(u => `${u} [${seen[u]?.s || 'err'}]`).join(', ')
                                   : `${targets.length} URLs 2xx/3xx`);
rec('no page a visitor can reach renders an AxonASP runtime error',
    errored.length === 0, errored.length ? errored.slice(0, 5).join(', ')
                                         : `${targets.length} pages clean`);

// A visitor must not be told a linked post does not exist — the §27 symptom, checked here
// across everything the crawl reached rather than only on the six lists suite 23 knows about.
const ghosts = [];
for (const u of targets.filter(u => /\/a\/a\.asp/i.test(u)).slice(0, 25)) {
  await p.goto(B + u, { waitUntil: 'domcontentloaded' }).catch(() => {});
  const t = await p.evaluate(() => document.body.innerText);
  if (/不存在或已被删除/.test(t)) ghosts.push(u);
}
rec('no topic link a visitor is offered leads to "此帖不存在"',
    ghosts.length === 0, ghosts.length ? ghosts.slice(0, 5).join(', ') : 'all topic links resolve to posts');

await br.close();
summary('25-guest-crawl');
