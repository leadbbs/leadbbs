// 10 — the mini/mobile UI, avatar upload and skin switching: the last flows that had
// only ever been checked as "the page renders".
import { B, rec, summary, browser, login, dbNum, dbOne, currentCaptcha, reveal } from './lib.mjs';

const br = await browser();
const p = await login(br, 'admin', 'leadbbs123');
const stamp = Date.now().toString().slice(-6);

// -------------------------------------------------------------- mini/mobile UI
{
  await p.goto(`${B}/mini/Default.asp`, { waitUntil: 'domcontentloaded' });
  const home = (await p.locator('body').innerText()).length > 40;
  rec('mini home renders', home);

  await p.goto(`${B}/mini/Default.asp?Action=b&b=100`, { waitUntil: 'domcontentloaded' });
  const list = await p.locator('a[href*="ction=a"][href*="id="]').count();
  rec('mini board page lists topics', list > 0, `${list} topic link(s)`);

  // and each of those topic links opens (this 500'd until mini got its own PrintTrueText)
  if (list > 0) {
    const href = await p.locator('a[href*="ction=a"][href*="id="]').first().getAttribute('href');
    const r = await p.goto(new URL(href, `${B}/mini/`).href, { waitUntil: 'domcontentloaded' }).catch(() => null);
    const body = r ? await p.locator('body').innerText() : '';
    rec('mini topic view opens', !!r && r.status() === 200 && body.length > 40,
        `${href} -> HTTP ${r ? r.status() : 'error'}`);
  }

  // post a topic from the mobile form (it submits to the same a/a2.asp handler)
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  const title = 'Mini ' + stamp;
  await p.goto(`${B}/mini/Default.asp?Action=p&b=100`, { waitUntil: 'domcontentloaded' });
  const hasForm = await p.locator('input[name="Form_Title"]').count() > 0;
  rec('mini post form renders', hasForm);
  if (hasForm) {
    await p.fill('input[name="Form_Title"]', title);
    await p.fill('textarea[name="Form_Content"]', 'Posted from the mobile UI at ' + stamp);
    const cap = p.locator('input[name="ForumNumber"]');
    if (await cap.count()) await cap.fill(await currentCaptcha(p));
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"], button[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(2000);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  const mine = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE Title='${title}'`);
  rec('posting from the mobile UI creates the topic', after > before && mine === 1, `announce ${before}->${after}`);
}

// ---------------------------------------------------------------- avatar upload
{
  const me = await dbOne(p, "SELECT ID FROM leadbbs_user WHERE UserName='admin'");
  const beforeDir = await dbOne(p, `SELECT PhotoDir FROM leadbbs_userface WHERE UserID=${me} ORDER BY ID DESC LIMIT 1`);
  // the avatar control lives on its own tab, not the main profile page
  await p.goto(`${B}/User/UserModify.asp?action=uploadface`, { waitUntil: 'domcontentloaded' });
  const input = p.locator('input[type="file"][name="userface"]').first();
  const has = await input.count() > 0;
  rec('avatar upload form is available on its tab', has);
  if (has) {
    // Setting an avatar is a TWO-step flow: upload, then crop (the crop needs a source
    // at least 20px each way, so use a real 100x100 image the site already ships).
    // The submit button is name="submit", which shadows form.submit — call the
    // prototype method so the real multipart post actually goes out.
    await reveal(input);
    await input.setInputFiles(new URL('../../images/face/0001.GIF', import.meta.url).pathname);   // .GIF on purpose: §48
    await p.waitForTimeout(800);
    await p.evaluate(() => {
      document.getElementsByName('upload_step')[0].value = '1';
      HTMLFormElement.prototype.submit.call(document.getElementById('LeadBBSFm'));
    });
    // the staged name arrives via the response's upload_resetajax() callback — wait for
    // it rather than guessing a timeout (a fixed wait made this flaky under load)
    await p.waitForFunction(
      () => (document.getElementsByName('upload_filename')[0] || {}).value,
      null, { timeout: 20000 }).catch(() => {});
    const staged = await p.evaluate(() => document.getElementsByName('upload_filename')[0].value);
    rec('avatar upload stages the image', /uface_/.test(staged || ''), staged || 'nothing staged');

    await p.evaluate(() => {
      const g = n => document.getElementsByName(n)[0];
      g('upload_step').value = ''; g('upload_x1').value = '0'; g('upload_y1').value = '0';
      g('upload_x2').value = '80'; g('upload_y2').value = '80';
      g('userface').value = '';
      HTMLFormElement.prototype.submit.call(document.getElementById('LeadBBSFm'));
    });
    await p.waitForTimeout(6000);
  }
  const dir = await dbOne(p, `SELECT PhotoDir FROM leadbbs_userface WHERE UserID=${me} ORDER BY ID DESC LIMIT 1`);
  rec('cropping saves the avatar', !!dir && dir !== beforeDir, `PhotoDir=${dir || 'none'}`);

  // and it must actually render on a post, not just exist in the table
  const tid = await dbOne(p, 'SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 1');
  const broken = [];
  p.on('response', r => { if (r.status() >= 400 && /face|upload/i.test(r.url())) broken.push(r.url()); });
  await p.goto(`${B}/a/a.asp?B=100&ID=${tid}`, { waitUntil: 'domcontentloaded' });
  const shown = await p.evaluate(() =>
    [...document.images].map(i => i.getAttribute('src')).filter(s => /upload\/face/i.test(s || '')));
  rec('the uploaded avatar renders on a post', shown.length > 0 && broken.length === 0,
      `${shown[0] || 'not shown'}${broken.length ? ', broken: ' + broken.length : ''}`);
}

// ------------------------------------------------------------------ skin switch
{
  const sheets = () => p.evaluate(() =>
    [...document.querySelectorAll('link[rel="stylesheet"]')].map(l => l.getAttribute('href')).join('|'));
  await p.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
  const before = await sheets();

  // the 风格 menu entry loads the picker into a layer; picking a style sets a cookie
  // client-side (LD.Cookie.Add) and reloads — so drive the real link, not the endpoint
  const menu = p.locator('a[onclick*="选择风格"]').first();
  const haveMenu = await p.locator('a[onclick*="选择风格"]').count() > 0;
  rec('skin picker is reachable from the page menu', haveMenu);
  let clicked = false;
  if (haveMenu) {
    await reveal(menu);
    await menu.click({ force: true });
    await p.waitForTimeout(2500);
    // pick a VISIBLE one: the picker markup also carries hidden entries
    const opt = p.locator('a[onclick*="setStyle"]:visible');
    const n = await opt.count();
    if (n > 1) {
      await reveal(opt.nth(1));
      await opt.nth(1).click({ force: true });
      await p.waitForTimeout(2500);
      clicked = true;
    }
    rec('skin picker lists the available styles', n > 1, `${n} style link(s)`);
  }
  await p.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
  const after = await sheets();
  rec('chosen skin is applied on the next page load', clicked && after !== before, `${before} -> ${after}`);
  // put the default back so the next run starts from a known skin
  await p.evaluate(() => { document.cookie = 'leadbbsstyle=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/'; });
}

await br.close();
process.exit(summary('10-mobile-misc') ? 0 : 1);
