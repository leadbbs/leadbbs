// 06 — member lifecycle and the remaining member-facing features, all through the real UI:
// registration, first login, posting as an ordinary member, logout, polls (create + vote),
// favourites removal and friends.
import { B, rec, summary, browser, login, db, dbNum, dbOne, currentCaptcha,
         setEditorContent, ajaxCommand, reveal, setSelect, loadCaptcha, goToAuthed} from './lib.mjs';

const br = await browser();
const stamp = Date.now().toString().slice(-7);
const NAME = 'bt' + stamp;          // LeadBBS caps usernames, keep it short
const PASS = 'btpass123';

// ---------------------------------------------------------------- registration
// NOTE: unlike login(), this context must NOT block User/number.asp — that request is
// what generates the session captcha code, and registration requires it.
const ctx = await br.newContext();
const rp = await ctx.newPage();
rp.on('dialog', d => d.accept());
await rp.goto(`${B}/User/register.asp`, { waitUntil: 'domcontentloaded' });
await Promise.all([
  rp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
  rp.locator('input[value="我同意"]').click({ force: true }),      // the agreement gate
]);
const haveForm = await rp.locator('input[name="Form_username"]').count() > 0;
rec('registration form reachable past the agreement page', haveForm, rp.url().replace(B, ''));

if (haveForm) {
  await rp.fill('input[name="Form_username"]', NAME);
  await rp.fill('input[name="Form_password1"]', PASS);
  await rp.fill('input[name="Form_password2"]', PASS);
  // the security question lives in the optional "填写更多资料" block, which the
  // checkbox reveals; Form_Question itself stays hidden and is filled by the select
  await rp.locator('input[name="moreinfo"]').check({ force: true });
  await rp.waitForTimeout(300);
  await setSelect(rp, 'select[name="sel_question"]', '我的家乡是？');
  await rp.fill('input[name="Form_Answer"]', 'btanswer');
  // The captcha a USER sees. It is lazy-loaded: on page load the <img> is a 1x1
  // images/blank.gif behind a 点此显示验证码 prompt, and only focusing the field (or clicking
  // the prompt) swaps in the real image. Assert the picture actually appears — the rest of
  // this suite reads the code from the session, so a permanently blank captcha would
  // otherwise pass every check while making registration impossible for a real person.
  const capBefore = await rp.evaluate(() => {
    const i = document.getElementById('verifycode');
    return { w: i ? i.naturalWidth : -1, src: i ? i.getAttribute('src') : '' };
  });
  await rp.locator('input[name="ForumNumber"]').focus().catch(()=>{});
  await rp.waitForTimeout(1500);
  const capAfter = await rp.evaluate(() => {
    const i = document.getElementById('verifycode');
    return { w: i ? i.naturalWidth : -1, src: i ? i.getAttribute('src') : '' };
  });
  rec('the captcha image is a placeholder until the field is focused',
      /blank\.gif/i.test(capBefore.src) && capBefore.w <= 1, `${capBefore.src} (${capBefore.w}px)`);
  rec('focusing the captcha field loads the real image',
      /number\.asp/i.test(capAfter.src) && capAfter.w > 20, `${capAfter.src.slice(0, 40)} (${capAfter.w}px)`);

  // ...and the image has CHARACTERS ON IT. "naturalWidth > 20" was true of a completely
  // blank white rectangle for the whole of §41/§42: the GIF decoded at 90x27 and carried no
  // pixels a human could read, so every check here passed while nobody could actually
  // register. Draw it to a canvas and count what is on it.
  const ink = await rp.evaluate(async () => {
    const img = new Image();
    img.src = '/User/number.asp?r=1&probe=' + Math.random();
    await new Promise(r => { img.onload = r; img.onerror = r; });
    if (!img.naturalWidth) return { colours: 0, dark: 0, total: 0 };
    const c = document.createElement('canvas');
    c.width = img.naturalWidth; c.height = img.naturalHeight;
    const g = c.getContext('2d'); g.drawImage(img, 0, 0);
    const d = g.getImageData(0, 0, c.width, c.height).data;
    const seen = new Set(); let dark = 0;
    for (let i = 0; i < d.length; i += 4) {
      seen.add(`${d[i]},${d[i+1]},${d[i+2]}`);
      if (d[i] + d[i+1] + d[i+2] < 400) dark++;
    }
    return { colours: seen.size, dark, total: d.length / 4 };
  });
  rec('the captcha actually has characters drawn on it',
      ink.colours >= 2 && ink.dark > 120 && ink.dark < ink.total * 0.6,
      `${ink.colours} colours, ${ink.dark}/${ink.total} inked pixels`);

  await rp.fill('input[name="ForumNumber"]', await loadCaptcha(rp));
  await Promise.all([
    rp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    rp.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await rp.waitForTimeout(1200);
  const uid = await dbOne(rp, `SELECT ID FROM leadbbs_user WHERE UserName='${NAME}'`);
  rec('registration creates the user account', !!uid, `${NAME} -> user id ${uid || 'none'}`);
}
await ctx.close();

// ------------------------------------------------- login + post as that member
const mp = await login(br, NAME, PASS);
const memberIn = await mp.locator('text=退出').count() > 0;
rec('new member can log in through the real login form', memberIn, NAME);

if (memberIn) {
  const before = await dbNum(mp, 'SELECT count(*) FROM leadbbs_announce');
  const title = 'Member ' + stamp;
  await mp.goto(`${B}/a/a2.asp?B=100`, { waitUntil: 'domcontentloaded' });
  await mp.fill('input[name="Form_Title"]', title);
  await setEditorContent(mp, 'Posted by an ordinary member through the browser.');
  const cap = mp.locator('input[name="ForumNumber"]');
  if (await cap.count()) await cap.fill(await currentCaptcha(mp));
  await Promise.all([
    mp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    mp.locator('input[type="submit"], input[type="image"]').first().click({ force: true }),
  ]);
  await mp.waitForTimeout(1500);
  const after = await dbNum(mp, 'SELECT count(*) FROM leadbbs_announce');
  const mine = await dbNum(mp, `SELECT count(*) FROM leadbbs_announce WHERE Title='${title}'`);
  rec('ordinary member can post a topic', after > before && mine === 1, `announce ${before}->${after}`);

  // ------------------------------------------------------------------ logout
  await mp.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
  const out = mp.locator('a:has-text("退出")').first();
  if (await mp.locator('a:has-text("退出")').count()) {
    await reveal(out);
    await Promise.all([
      mp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      out.click({ force: true }),
    ]);
    await mp.waitForTimeout(800);
  }
  await mp.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
  const stillIn = await mp.locator('text=退出').count() > 0;
  rec('logout ends the session', !stillIn, stillIn ? 'still logged in' : 'logged out');
}

// ------------------------------------------------------- polls: create + vote
const p = await login(br);
const pollTitle = 'Poll ' + stamp;
{
  await p.goto(`${B}/a/a2.asp?B=100&VoteFlag=yes`, { waitUntil: 'domcontentloaded' });
  const isPoll = await p.locator('textarea[name="Form_VoteItem"]').count() > 0;
  rec('poll post form opens from the board page link', isPoll, 'Form_VoteItem present');
  if (isPoll) {
    await p.fill('input[name="Form_Title"]', pollTitle);
    await setEditorContent(p, 'Poll created through the browser.');
    await p.fill('textarea[name="Form_VoteItem"]', 'Option A\nOption B\nOption C');
    const cap = p.locator('input[name="ForumNumber"]');
    if (await cap.count()) await cap.fill(await currentCaptcha(p));
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"], input[type="image"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1500);
    const aid = await dbOne(p, `SELECT ID FROM leadbbs_announce WHERE Title='${pollTitle}'`);
    const items = await dbNum(p, `SELECT count(*) FROM leadbbs_voteitem WHERE AnnounceID=${aid || 0}`);
    rec('poll topic created with its options', !!aid && items === 3, `announce ${aid}, ${items} vote items`);

    if (aid) {
      const votesBefore = await dbNum(p, 'SELECT count(*) FROM leadbbs_voteuser');
      await p.goto(`${B}/a/a.asp?B=100&ID=${aid}`, { waitUntil: 'domcontentloaded' });
      const opt = p.locator('form[id^="PollForm"] input[type="radio"], form[id^="PollForm"] input[type="checkbox"]').first();
      const votable = await opt.count() > 0;
      rec('poll renders a votable form on the topic page', votable);
      if (votable) {
        await reveal(opt);
        await opt.check({ force: true });
        // the vote button sits OUTSIDE the form, in #pollbtn
        const psub = p.locator('#pollbtn input[type="button"]').first();
        await reveal(psub);
        await psub.click({ force: true, timeout: 8000 }).catch(()=>{});
        await p.waitForTimeout(2000);
        const votesAfter = await dbNum(p, 'SELECT count(*) FROM leadbbs_voteuser');
        rec('voting through the UI records the vote', votesAfter > votesBefore, `voteuser ${votesBefore}->${votesAfter}`);
      }
    }
  }
}

// --------------------------------------------------- remove a favourite via UI
{
  const me = await dbOne(p, "SELECT ID FROM leadbbs_user WHERE UserName='admin'");
  // add one first through the topic page's 加入收藏 link, so the suite is self-contained
  // and repeatable (it removes what it added)
  // a PLAIN topic: a poll topic renders the ballot instead of the usual post furniture,
  // so its 加入收藏 link is not where this expects it
  const fresh = await dbOne(p, `SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100
      AND PollNum=0 AND TopicType=0
      AND ID NOT IN (SELECT AnnounceID FROM leadbbs_collectanc WHERE UserID=${me}) ORDER BY ID DESC LIMIT 1`);
  if (fresh) {
    // Click until the row lands. On a loaded CI runner the first click has been observed to
    // do nothing at all -- the handler binds late, or the page is still parsing -- and the
    // check then failed with a detail that said only which topic it tried. Favouriting twice
    // is harmless (the app refuses a duplicate), the DB row is still the assertion, and the
    // failure detail now carries what the page actually said.
    let why = '';
    for (let attempt = 0; attempt < 3; attempt++) {
      await goToAuthed(p, `${B}/a/a.asp?B=100&ID=${fresh}`);
      const links = await p.locator('a[onclick*="Collect&"]').count();
      if (!links) { why = `no 加入收藏 link on the page (attempt ${attempt + 1})`; continue; }
      await ajaxReady(p);
      await reveal(p.locator('a[onclick*="Collect&"]').first());
      await p.locator('a[onclick*="Collect&"]').first().click({ force: true });
      await p.waitForTimeout(2000);
      if (await dbNum(p, `SELECT count(*) FROM leadbbs_collectanc WHERE UserID=${me} AND AnnounceID=${fresh}`)) break;
      why = (await p.evaluate(() => (document.body.innerText || '').replace(/\s+/g, ' ')))
              .slice(0, 90) || `clicked, no row (attempt ${attempt + 1})`;
    }
    if (why) console.log(`      (favourite needed retries: ${why})`);
  }
  const collectSql = `SELECT count(*) FROM leadbbs_collectanc WHERE UserID=${me} AND AnnounceID=${fresh || 0}`;
  const added = await waitRow(p, collectSql, 1);
  rec('add a favourite from the topic page', added === 1,
      added === 1 ? `topic ${fresh}` : `topic ${fresh} — no leadbbs_collectanc row after 3 clicks`);

  const before = await dbNum(p, `SELECT count(*) FROM leadbbs_collectanc WHERE UserID=${me}`);
  await goToAuthed(p, `${B}/User/UserCollect.asp`);
  // each row's delete control is <a href="javascript:kill(<collectID>);">, which opens
  // DelCollect.asp in a popup window
  const del = p.locator('a[href^="javascript:kill("]').first();
  const have = await p.locator('a[href^="javascript:kill("]').count() > 0;
  rec('favourites list renders a delete control per row', have && before > 0, `${before} favourite(s)`);
  if (have) {
    const [popup] = await Promise.all([
      p.waitForEvent('popup', { timeout: 8000 }).catch(() => null),
      del.click({ force: true }),
    ]);
    // the popup asks for confirmation (DeleteSureFlag) before it removes anything
    if (popup) {
      await popup.waitForLoadState('networkidle').catch(()=>{});
      await popup.locator('form input[type="submit"]').first().click({ force: true }).catch(()=>{});
      await popup.waitForTimeout(1500);
    }
    await p.waitForTimeout(1200);
  }
  const after = await dbNum(p, `SELECT count(*) FROM leadbbs_collectanc WHERE UserID=${me}`);
  rec('remove a favourite through the UI', before > 0 && after < before, `collect ${before}->${after}`);
}

// The last three checks are fire-and-forget AJAX: nothing navigates, so there is no event to
// await and a fixed sleep is a guess. On a freshly restarted server the first such request can
// take several seconds while AxonASP compiles the page, and the suite read the database too
// early. Poll instead, and wait for the handler to exist before clicking — these links are
// <a href="Processor.asp?…" onclick="return(a_msg(…))">, and an undefined handler does not
// prevent the default, so the browser navigates away instead of firing the AJAX call.
// 30 s, not 15: under the coverage census every page also pays for the instrumentation probe
// and the sampler polling alongside, and these AJAX actions were still being read too early.
async function waitRow(page, sql, want, ms = 30000) {
  const t0 = Date.now();
  let n = await dbNum(page, sql);
  while (n !== want && Date.now() - t0 < ms) {
    await page.waitForTimeout(500);
    n = await dbNum(page, sql);
  }
  return n;
}
async function ajaxReady(page) {
  await page.waitForFunction(
    () => typeof a_msg === 'function' && typeof a_command === 'function',
    null, { timeout: 20000 }).catch(() => {});
}

// ------------------------------------------------------- add a friend via UI
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_frienduser');
  // the topic the new member posted above always qualifies (different author, plain topic)
  const other = await dbOne(p, `SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100
      AND PollNum=0 AND TopicType=0
      AND UserID<>(SELECT ID FROM leadbbs_user WHERE UserName='admin') ORDER BY ID DESC LIMIT 1`);
  let note = '';
  for (let attempt = 0; other && attempt < 3; attempt++) {
    await goToAuthed(p, `${B}/a/a.asp?B=100&ID=${other}`);
    if (!(await p.locator('a[onclick*="AddFriend"]').count())) { note = 'no 加为好友 link'; continue; }
    note = await ajaxCommand(p, 'a[onclick*="AddFriend"]') || '';
    await p.waitForTimeout(1500);
    if (await dbNum(p, 'SELECT count(*) FROM leadbbs_frienduser') > before) break;
  }
  const after = await waitRow(p, 'SELECT count(*) FROM leadbbs_frienduser', before + 1);
  rec('add a friend from the post UI', after > before,
      after > before ? `frienduser ${before}->${after}`
                     : `frienduser ${before}->${after} after 3 attempts${note ? ' — ' + String(note).slice(0, 70) : ''}`);
}

await br.close();
process.exit(summary('06-member') ? 0 : 1);
