// Shared helpers for the browser-driven LeadBBS test suite.
// Everything here drives the REAL UI: real forms, real buttons, real AJAX.
import { chromium } from 'playwright';
import { appendFileSync } from 'fs';

export const B = process.env.LEADBBS_URL || 'http://localhost:9596';
// Credentials come from the environment so that no real deployment's password is published
// here. The defaults are the values a fresh LeadBBS install ships with -- change them on any
// server that is reachable by anyone else, and set these three variables before running.
export const ADMIN        = process.env.LEADBBS_ADMIN_USER   || 'admin';
export const ADMIN_PASS   = process.env.LEADBBS_ADMIN_PASS   || 'leadbbs123';
export const ADMIN_ANSWER = process.env.LEADBBS_ADMIN_ANSWER || 'leadbbsans';
export const results = [];
export function rec(name, ok, detail='') {
  results.push({name, ok});
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? '   — ' + detail : ''}`);
}
export function summary(title) {
  const p = results.filter(r=>r.ok).length;
  console.log(`\n=== ${title}: ${p}/${results.length} passed ===`);
  const failed = results.filter(r=>!r.ok);
  if (failed.length) console.log('FAILED: ' + failed.map(f=>f.name).join(' | '));
  return failed.length === 0;
}
// DEPTH measurement. `action=` is LeadBBS's universal verb parameter, and the depth question
// is "which verbs does the suite actually put on the wire" — not "which does a suite mention".
// Recording it at the BROWSER is the only honest answer: it sees the real request a real form
// produced, including the multipart bodies curl-level tests never generate (§20).
//
// Enabled only when LEADBBS_VERBLOG is set (test/coverage/browser_census.sh sets it), so a
// normal `run-all.sh` is unaffected. Every context is hooked — several suites open their own.
const VERBLOG = process.env.LEADBBS_VERBLOG || '';
function recordVerbs(where) {
  const seen = new Set();
  for (const m of String(where).matchAll(/(?:^|[?&\r\n"])action=([A-Za-z_][A-Za-z0-9_]*)/g)) seen.add(m[1]);
  // multipart: name="action"\r\n\r\nVALUE
  for (const m of String(where).matchAll(/name="action"\r?\n\r?\n([A-Za-z_][A-Za-z0-9_]*)/g)) seen.add(m[1]);
  for (const v of seen) appendFileSync(VERBLOG, v + '\n');
}
function hookVerbs(ctx) {
  ctx.on('request', r => {
    try {
      recordVerbs(r.url());
      const d = r.postData();
      if (d) recordVerbs(d);
    } catch { /* a request that dies before postData is available tells us nothing */ }
  });
}
export async function browser() {
  const br = await chromium.launch({ headless: true, args: ['--no-sandbox'] });
  if (VERBLOG) {
    const orig = br.newContext.bind(br);
    br.newContext = async (...a) => { const c = await orig(...a); hookVerbs(c); return c; };
  }
  return br;
}
// A real logged-in browser page (posts the actual login form).
export async function login(br, user = ADMIN, pass = ADMIN_PASS) {
  const ctx = await br.newContext();
  // The captcha IMAGE (User/number.asp) regenerates the session code every time it loads,
  // which would invalidate any code we pin. Intercept just that request so the pinned code
  // stays valid; everything else on the page loads normally.
  //
  // FULFIL it with a stub rather than abort()ing: an aborted route is still an outstanding
  // request as far as Playwright's networkidle accounting is concerned, so aborting made
  // waitUntil:'networkidle' hang on every page that shows a captcha.
  const PIXEL = Buffer.from('R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==', 'base64');
  await ctx.route('**/number.asp*', r =>
    r.fulfill({ status: 200, contentType: 'image/gif', body: PIXEL }));
  const page = await ctx.newPage();
  page.on('dialog', d => d.accept());
  // retry once: this 2-core box intermittently misses even domcontentloaded while the same
  // URL fetches in milliseconds
  try {
    await page.goto(`${B}/User/Login.asp`, { waitUntil: 'domcontentloaded', timeout: 20000 });
  } catch {
    await page.goto(`${B}/User/Login.asp`, { waitUntil: 'commit', timeout: 20000 });
    await page.waitForTimeout(800);
  }
  await page.fill('#login_form input[name="user"]', user);
  await page.fill('#login_form input[name="pass"]', pass);
  await Promise.all([
    page.waitForNavigation({waitUntil:'domcontentloaded'}).catch(()=>{}),
    page.locator('#login_form input[type="submit"]').click({force:true}),
  ]);
  await page.waitForTimeout(900);
  return page;
}
// Unlock the manage/ backend: LeadBBS wants a live forum session PLUS the supervisor
// name, the account's security answer and the captcha. login() blocks the captcha image
// (so a pinned code stays valid), hence pinCaptcha + the pinned value here.
export async function adminLogin(page, user = ADMIN, pass = ADMIN_PASS, answer = ADMIN_ANSWER) {
  await page.goto(`${B}/manage/default.asp`, { waitUntil: 'domcontentloaded' });
  if (await page.locator('input[name="MPass"]').count() === 0) return true;   // already unlocked
  await page.fill('input[name="user"]', user).catch(()=>{});
  await page.fill('input[name="pass"]', pass).catch(()=>{});
  await page.fill('input[name="MPass"]', answer).catch(()=>{});
  await pinCaptcha(page);
  await page.fill('input[name="ForumNumber"]', '1234').catch(()=>{});
  await Promise.all([
    page.waitForNavigation({ waitUntil:'domcontentloaded' }).catch(()=>{}),
    page.locator('input[type="submit"]').first().click({ force:true }).catch(()=>{}),
  ]);
  await page.waitForTimeout(1200);
  const body = await page.content();
  const ok = body.includes('论坛信息一览') || body.includes('管理中心首页');
  return ok;
}
// Navigate with one retry. On a small box some manage/ pages intermittently fail to reach
// even 'domcontentloaded' within the default timeout while the same URL fetches in ~35 ms;
// retrying with 'commit' (which resolves as soon as the response starts) rides that out.
// It still throws if both attempts fail, so a genuinely broken page is not masked.
export async function goTo(page, url, opts = {}) {
  try {
    return await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 20000, ...opts });
  } catch {
    const r = await page.goto(url, { waitUntil: 'commit', timeout: 20000, ...opts });
    // 'commit' resolves as soon as the response STARTS, so the document may not be parsed
    // yet: a caller reading innerText here can legitimately see an empty string, and one
    // looking for a link can miss one that is about to exist. A flat 800 ms was enough on a
    // fast box and not on a loaded CI runner -- wait for the real signal instead.
    await page.waitForFunction(() => document.readyState !== 'loading',
                               null, { timeout: 20000 }).catch(() => {});
    return r;
  }
}
// Log in, unlock the backend, and hand back a page that is actually usable.
//
// The manage index is a frameset: once a tab submits the unlock form and lands there, its
// top-level navigations stop committing, and the pending navigation blocks page.evaluate —
// so the SQL oracle hangs rather than failing. The unlock lives in the SESSION, so abandon
// that tab and continue in a fresh one from the same context.
export async function adminPage(br, user = ADMIN, pass = ADMIN_PASS) {
  const lp = await login(br, user, pass);
  const ok = await adminLogin(lp);
  const page = await lp.context().newPage();
  page.on('dialog', d => d.accept());
  await page.goto(`${B}/BoardNav.asp`, { waitUntil: 'domcontentloaded' });
  return { page, ok };
}
// Navigate, and make sure the page really came back authenticated.
//
// The forum ships DEF_RepeatLoginTimeOut = 300 ("防重复登录"), so an account that logged in from
// another session moments earlier can have a request render as a guest even though the session
// cookie is valid — we have watched Boards.asp report logged-in, a/a.asp render the guest
// header, and Boards.asp report logged-in again, all within the same second. It is rare, it is
// not caused by anything the suite does wrong, and a page rendered for a guest is missing the
// per-post controls, so a check looking for one fails for the wrong reason. Reload once.
export async function goToAuthed(page, url, opts = {}) {
  await goTo(page, url, opts);
  const guest = async () => !(await page.evaluate(() => document.body.innerText.includes('退出')));
  if (await guest()) {
    await page.waitForTimeout(1200);
    await goTo(page, url, opts);
  }
  return !(await guest());
}

// Navigate and return the page's text, once the document is actually there.
//
// Every mini/Default.asp mode answers in under 150 ms with a 3-7 KB body, so when a check on a
// loaded CI runner reads an EMPTY string from one, the page is not slow -- the read raced the
// parse. That produced failures whose detail was literally empty, twice, on different suites.
// Wait for readyState, and if the body is still implausibly short, fetch it once more before
// believing it. `min` is the length below which a page of this kind cannot be real.
export async function readBody(page, url, { min = 30, tries = 2 } = {}) {
  let text = '';
  for (let i = 0; i < tries; i++) {
    try { await goTo(page, url); } catch { await page.waitForTimeout(800); continue; }
    await page.waitForFunction(() => document.readyState === 'complete',
                               null, { timeout: 15000 }).catch(() => {});
    text = (await page.evaluate(() => document.body ? document.body.innerText : '')).replace(/\s+/g, ' ');
    if (text.length >= min) break;
    await page.waitForTimeout(700);
  }
  // Still empty? Distinguish a broken PAGE from a lost RENDER. These endpoints answer in
  // milliseconds with a few KB, so an empty innerText is almost always the read racing the
  // parse -- but "almost always" is not an assertion. Fetch the same URL and judge on that:
  // if the server really returns nothing, the caller should still fail.
  if (text.length < min) {
    const raw = await page.evaluate(async u => {
      try { const r = await fetch(u, { credentials: 'same-origin' }); return (await r.text()) || ''; }
      catch { return ''; }
    }, url).catch(() => '');
    if (raw.length >= min) {
      text = raw.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
    }
  }
  return text;
}

export async function isLoggedIn(page) {
  await page.goto(`${B}/Boards.asp`, { waitUntil:'domcontentloaded' });
  return (await page.locator('text=退出').count()) > 0;
}
// pin the session captcha so forms requiring it can be driven
export async function pinCaptcha(page) {
  await page.evaluate(async () => { await fetch('/test/browser/helpers/setcaptcha.asp'); });
}
// Read the CURRENT session verification code. The captcha IMAGE regenerates the code
// on every load, so in a real browser we must read what the session actually holds
// (right before submitting) rather than pinning a value up front.
export async function currentCaptcha(page) {
  return (await page.evaluate(async () => (await fetch('/test/browser/helpers/rndnum.asp')).text())).trim();
}
// Some forms (registration) render the captcha <img> as blank.gif and only fetch the real
// one — which is what generates the session code — when the field is focused. Do what a
// user does, then read the code the session now holds.
export async function loadCaptcha(page) {
  const f = page.locator('input[name="ForumNumber"]').first();
  if (await f.count()) await f.focus().catch(()=>{});
  await page.waitForTimeout(1000);
  return await currentCaptcha(page);
}
// Fetch/POST from inside the page's own session. Needed where the thing under test is not a
// page render: a static download (the SQL dump), or a POST-only session-bound endpoint (the
// chat poll). Using the page's fetch keeps the LeadBBS auth cookie attached.
export async function httpGet(page, url, timeoutMs = 15000) {
  return await page.evaluate(async ([u, t]) => {
    const c = new AbortController(); const id = setTimeout(() => c.abort(), t);
    try {
      const r = await fetch(u, { credentials: 'same-origin', signal: c.signal });
      return { status: r.status, body: await r.text() };
    } catch { return { status: 0, body: '' }; } finally { clearTimeout(id); }
  }, [url, timeoutMs]);
}
export async function httpPost(page, url, body, timeoutMs = 15000) {
  return await page.evaluate(async ([u, b, t]) => {
    const c = new AbortController(); const id = setTimeout(() => c.abort(), t);
    try {
      const r = await fetch(u, {
        method: 'POST', credentials: 'same-origin', signal: c.signal,
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: b });
      return { status: r.status, body: await r.text() };
    } catch { return { status: 0, body: '' }; } finally { clearTimeout(id); }
  }, [url, body, timeoutMs]);
}
// read-only DB peek (used only to CONFIRM what the UI reported, never as the sole assertion)
export async function db(page, sql) {
  return (await page.evaluate(async ([s, t]) => {
    const c = new AbortController(); const id = setTimeout(() => c.abort(), t);
    try {
      return await (await fetch('/test/browser/helpers/q.asp?sql=' + encodeURIComponent(s), { signal: c.signal })).text();
    } finally { clearTimeout(id); }
    // Strip only line endings, NOT all whitespace: a row whose columns are all empty is
    // "\t\t", and .trim() ate it — so "did this action blank the column?" silently became
    // "the query returned nothing", which reads as a broken feature.
  }, [sql, 20000])).replace(/^[\r\n]+|[\r\n]+$/g, '');
}
// all data rows (drops the header line), each split into columns
export async function dbRows(page, sql) {
  const t = await db(page, sql);
  return t.split('\n').slice(1)
    .map(l => l.replace(/\r$/, ''))
    .filter(l => l !== '')                       // an all-empty row is still a row
    .map(l => l.split('\t').map(c => c.trim()));
}
export async function dbOne(page, sql) {
  const r = await dbRows(page, sql);
  return r.length ? r[0][0] : '';
}
export async function dbNum(page, sql) {
  const t = await db(page, sql); const last = t.split('\n').pop().trim();
  return parseInt(last, 10) || 0;
}
// Many moderation links sit in drop-down menus that CSS keeps display:none until hover.
// A hidden element has no box, so even a forced click never dispatches. Un-hide the
// ancestors — exactly what hovering does — then click for real.
export async function reveal(locator) {
  await locator.evaluate(el => {
    for (let n = el; n && n !== document.body; n = n.parentElement) {
      if (getComputedStyle(n).display === 'none') n.style.display = 'block';
      if (getComputedStyle(n).visibility === 'hidden') n.style.visibility = 'visible';
    }
  }).catch(() => {});
}
// Pick a value in a <select>. LeadBBS replaces some selects with a custom widget and
// leaves the real element display:none, so fall back to setting the value and firing
// 'change' (which is what the widget itself does, and what the inline handlers listen for).
export async function setSelect(page, selector, value) {
  const sel = page.locator(selector).first();
  try {
    await sel.selectOption(String(value), { force: true, timeout: 4000 });
    return 'native';
  } catch {
    await sel.evaluate((el, v) => {
      const opt = Array.from(el.options).find(o => o.value === v) ||
                  (Number.isInteger(+v) ? el.options[+v] : null);
      if (opt) el.value = opt.value;
      el.dispatchEvent(new Event('change', { bubbles: true }));
      if (el.onchange) el.onchange();
    }, String(value));
    return 'scripted';
  }
}
// Most moderation actions go through a_command()/a_msg() -> layer_view(), which fetches a
// CONFIRM FORM from Processor.asp into a floating layer; the action only happens when that
// form is submitted. Clicking the link alone does nothing — drive both halves.
// `fill` is an optional {name: value} map applied to the confirm form before submitting.
export async function ajaxCommand(page, linkSelector, fill = {}) {
  const link = page.locator(linkSelector).first();
  if (await page.locator(linkSelector).count() === 0) return 'no link';
  // Wait for the handler to exist before clicking. These links are
  // <a href="Processor.asp?..." onclick="return(a_command(...))"> — if a_command has not been
  // defined yet (inc/js is still loading), the inline handler throws, the default is NOT
  // prevented, and the browser NAVIGATES to Processor.asp instead of opening the layer. The
  // layer then never appears and the retry clicks on a page that no longer has the link.
  await page.waitForFunction(
    () => typeof a_command === 'function' && typeof a_msg === 'function',
    null, { timeout: 20000 }).catch(() => {});
  await reveal(link);
  await link.click({ force: true });
  const form = page.locator('.ajaxbox form, #anc_delbody form, #anc_msgbody form').first();
  try { await form.waitFor({ timeout: 8000 }); } catch { return 'no confirm form'; }
  for (const [k, v] of Object.entries(fill)) {
    const f = form.locator(`[name="${k}"]`).first();
    if (await f.count() === 0) continue;
    const tag = await f.evaluate(e => e.tagName + ':' + (e.type || ''));
    if (tag.startsWith('SELECT')) {
      // the confirm form floats in a layer; Playwright's actionability check can time out
      // on it, so fall back to setting the value and firing the change event
      await f.selectOption(String(v), {force:true, timeout:5000}).catch(async () => {
        await f.evaluate((el, val) => {
          el.value = val;
          el.dispatchEvent(new Event('change', {bubbles:true}));
        }, String(v));
      });
    } else if (/radio|checkbox/.test(tag)) {
      const opt = form.locator(`input[name="${k}"][value="${v}"]`).first();
      await (await opt.count() ? opt : f).check({force:true}).catch(()=>{});
    } else {
      await f.fill(String(v)).catch(()=>{});
    }
  }
  const submit = form.locator('input[type="submit"], button[type="submit"]').first();
  if (await submit.count() === 0) return 'no submit';
  await submit.click({ force: true });
  await page.waitForTimeout(1800);
  return 'submitted';
}
// Dump the controls of whatever confirm form a command link opened (for building tests).
export async function formControls(page) {
  return await page.evaluate(() => {
    const f = document.querySelector('.ajaxbox form, #anc_delbody form, #anc_msgbody form');
    if (!f) return null;
    return Array.from(f.querySelectorAll('input,select,textarea')).map(e =>
      `${e.tagName.toLowerCase()}:${e.type||''}:${e.name||''}=${(e.value||'').slice(0,24)}`);
  });
}
// Fill the LeadBBS rich editor. The editor is an iframe (name=LEADEDT) exposed as
// the globals edt_doc / edt_win; client-side validation measures ITS content
// (edt_getdoclen), not the hidden Form_Content textarea — so we must type there.
export async function setEditorContent(page, text) {
  return await page.evaluate(t => {
    try {
      if (typeof edt_doc !== 'undefined' && edt_doc && edt_doc.body) {
        edt_doc.body.innerHTML = t;
        if (typeof edt_checkContent === 'function') edt_checkContent();
        return 'editor len=' + (typeof edt_getdoclen === 'function' ? edt_getdoclen() : '?');
      }
    } catch (e) { /* fall through */ }
    const el = document.getElementsByName('Form_Content')[0];
    if (el) { el.value = t; return 'textarea'; }
    return 'no editor';
  }, text);
}
