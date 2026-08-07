// §32 bisect: is the driver SESSION COUNT rather than request count?
//
// Hold ONE authenticated browser session. Between checks, fire batches of cookie-less
// curls — every one of which makes AxonASP mint a brand-new session — and after each
// batch re-check the held session's authenticated pages.
//
// If the held session degrades as sessions accumulate while its own request count stays
// tiny, the driver is session count (cap / eviction / memory), not traffic.
import { chromium } from 'playwright';
import { execSync, spawn } from 'child_process';

// Same environment contract as test/browser/lib.mjs, so this driver points at whatever
// server the suites do rather than carrying its own idea of the deployment.
const B    = process.env.LEADBBS_URL          || 'http://localhost:9596';
const USER = process.env.LEADBBS_ADMIN_USER   || 'admin';
const PASS = process.env.LEADBBS_ADMIN_PASS   || 'leadbbs123';
const BATCH = parseInt(process.env.BATCH || '100', 10);
const BATCHES = parseInt(process.env.BATCHES || '30', 10);

const sh = c => { try { return execSync(c, { encoding: 'utf8' }).trim(); } catch { return ''; } };
const pid = () => sh("pgrep -f 'axonasp-http -c' | head -1");

function stats() {
  const p = pid();
  if (!p) return { rss: 0, fds: 0, thr: 0 };
  return {
    rss: Math.round((+sh(`ps -o rss= -p ${p}`) || 0) / 1024),
    fds: +sh(`ls /proc/${p}/fd 2>/dev/null | wc -l`) || 0,
    thr: +sh(`ls /proc/${p}/task 2>/dev/null | wc -l`) || 0,
  };
}

// each curl gets its own (absent) cookie jar => a brand-new session per request
// fire the flood ASYNCHRONOUSLY so authenticated navigation OVERLAPS it — the first
// reproduction happened with concurrent authenticated traffic, and the deadlock needs
// several requests to be inside the Application wait at the same moment
const PAR = process.env.PAR || '16';
function mintSessionsAsync(n) {
  return spawn('bash', ['-c',
    `seq ${n} | xargs -P ${PAR} -I{} curl -s -o /dev/null --max-time 20 "${B}/Boards.asp?s={}"`],
    { stdio: 'ignore', detached: true });
}

const br = await chromium.launch({ headless: true, args: ['--no-sandbox'] });
const ctx = await br.newContext();
await ctx.route('**/number.asp*', r => r.abort());
const page = await ctx.newPage();
page.on('dialog', d => d.accept());

await page.goto(`${B}/User/Login.asp`, { waitUntil: 'domcontentloaded' });
await page.fill('#login_form input[name="user"]', USER);
await page.fill('#login_form input[name="pass"]', PASS);
await Promise.all([
  page.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(() => {}),
  page.locator('#login_form input[type="submit"]').click({ force: true }),
]);
await page.waitForTimeout(500);

const tid = (await page.evaluate(async () => (await fetch('/test/browser/helpers/q.asp?sql=' + encodeURIComponent(
  'SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 AND PollNum=0 AND TopicType=0 ORDER BY ID DESC LIMIT 1'
))).text())).trim().split('\n').pop().trim();

async function check() {
  await page.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
  const boards = (await page.locator('text=退出').count()) > 0;
  await page.goto(`${B}/a/a.asp?B=100&ID=${tid}`, { waitUntil: 'domcontentloaded' });
  const topic = (await page.locator('a[onclick*="Collect&"]').count()) > 0;
  await page.goto(`${B}/User/UserModify.asp`, { waitUntil: 'domcontentloaded' });
  const profile = (await page.locator('input[name="Form_homepage"]').count()) > 0;
  return { boards, topic, profile };
}

console.log(`one held session; ${BATCH} cookie-less requests per batch (each mints a session)`);
console.log('sessions  boards  topic  profile  rssMB  fds  thr');
let minted = 0;
for (let i = 0; i <= BATCHES; i++) {
  let child = null;
  if (i > 0) { child = mintSessionsAsync(BATCH); minted += BATCH; }
  const c = await check();
  if (child) { try { process.kill(-child.pid, 'SIGKILL'); } catch {} }
  const s = stats();
  const bad = !c.topic || !c.profile;
  console.log(
    `${String(minted).padStart(8)}  ${c.boards ? 'ok    ' : 'GUEST '}  ${c.topic ? 'ok   ' : 'GUEST'}  ` +
    `${c.profile ? 'ok     ' : 'BROKEN '}  ${String(s.rss).padStart(5)}  ${String(s.fds).padStart(3)}  ${String(s.thr).padStart(3)}` +
    (bad ? '   <<< §32' : ''));
  if (bad) { console.log(`\nreproduced after ~${minted} minted sessions.`); break; }
}
await br.close();
