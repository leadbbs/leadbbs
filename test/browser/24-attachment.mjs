// 24 — attachments, judged by what a reader sees rather than by what the database holds.
//
// Suite 03 has asserted "an attachment row was created" since the beginning, and it was true
// the whole time a user was reporting that their picture never appeared. Two reasons it could
// be true and useless:
//
//   * the fixture was a 1x1 transparent GIF, so even a perfectly working forum rendered
//     nothing a human could see — the assertion could not distinguish success from failure;
//   * an image over 2 MB was rejected by a cap the form never mentioned (it advertised
//     DEF_FileMaxBytes, 8024K, while Upload_File enforced a hardcoded 2 MB on images), and the
//     rejection message was thrown away by a2.asp's redirect. The post appeared with the
//     picture silently missing and no error anywhere.
//
// So this suite uses a 160x80 image and asserts its rendered size in a guest's browser, and
// checks that a file which is refused says so — before the post is lost, and after.
import { B, rec, summary, browser, login, goTo, dbOne, loadCaptcha, setSelect,
         currentCaptcha, setEditorContent } from './lib.mjs';
import { writeFileSync } from 'fs';
import { deflateSync } from 'zlib';

const br = await browser();
const stamp = Date.now().toString().slice(-7);
const NAME = 'at' + stamp;
const PASS = 'atpass123';
const BOARD = 100;

// Both fixtures are generated here rather than pasted as base64: a fixture that is silently
// corrupt is worse than no fixture, because the failure it produces looks like an app bug.
function png(w, h, pixel) {
  const px = Buffer.alloc(h * (1 + w * 3));
  for (let y = 0, o = 0; y < h; y++) { px[o++] = 0;
    for (let x = 0; x < w; x++) { const [r, g, b] = pixel(x, y); px[o++] = r; px[o++] = g; px[o++] = b; } }
  const T = [...Array(256)].map((_, n) => { let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1; return c >>> 0; });
  const crc = b => { let c = 0xffffffff; for (const x of b) c = T[(c ^ x) & 0xff] ^ (c >>> 8); return (c ^ 0xffffffff) >>> 0; };
  const chunk = (t, d) => { const L = Buffer.alloc(4); L.writeUInt32BE(d.length);
    const body = Buffer.concat([Buffer.from(t), d]); const C = Buffer.alloc(4); C.writeUInt32BE(crc(body));
    return Buffer.concat([L, body, C]); };
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4); ihdr[8] = 8; ihdr[9] = 2;
  return Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]), chunk('IHDR', ihdr),
                        chunk('IDAT', deflateSync(px, { level: 1 })), chunk('IEND', Buffer.alloc(0))]);
}
// 160x80 solid red: big enough that "did the reader see it" is a real question.
const SMALL = '/tmp/leadbbs-att-small.png';
writeFileSync(SMALL, png(160, 80, () => [220, 40, 40]));
// ~4 MB of genuine noise (xorshift32, |0 arithmetic so it does not lose precision and turn
// compressible): an ordinary phone photo, comfortably over the 2 MB image cap.
const BIG = '/tmp/leadbbs-att-big.png';
{
  let s0 = 0x2545f491;
  const rnd = () => { s0 ^= s0 << 13; s0 |= 0; s0 ^= s0 >>> 17; s0 ^= s0 << 5; s0 |= 0; return s0 & 0xff; };
  writeFileSync(BIG, png(1400, 1000, () => [rnd(), rnd(), rnd()]));
}

// ------------------------------------------------------------------ a fresh member
{
  const ctx = await br.newContext();
  const rp = await ctx.newPage();
  rp.on('dialog', d => d.accept());
  await rp.goto(`${B}/User/register.asp`, { waitUntil: 'domcontentloaded' });
  await Promise.all([
    rp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    rp.locator('input[value="我同意"]').click({ force: true }),
  ]);
  await rp.fill('input[name="Form_username"]', NAME);
  await rp.fill('input[name="Form_password1"]', PASS);
  await rp.fill('input[name="Form_password2"]', PASS);
  await rp.locator('input[name="moreinfo"]').check({ force: true });
  await rp.waitForTimeout(300);
  await setSelect(rp, 'select[name="sel_question"]', '我的家乡是？');
  await rp.fill('input[name="Form_Answer"]', 'atanswer');     // the app rejects a short answer
  await rp.fill('input[name="ForumNumber"]', await loadCaptcha(rp));
  await Promise.all([
    rp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    rp.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await rp.waitForTimeout(1200);
  await ctx.close();
}
// LeadBBS refuses posts made within DEF_PostInterval seconds of each other; a member who has
// just registered is inside that window, and the post would silently not be created.
await new Promise(r => setTimeout(r, 11000));
const mp = await login(br, NAME, PASS);
const alerts = [];
mp.on('dialog', d => alerts.push(d.message()));   // login() already accepts them

const uid = Number(await dbOne(mp, `SELECT ID FROM leadbbs_user WHERE UserName='${NAME}'`) || 0);
rec('a fresh member exists to post attachments', uid > 0, `${NAME} -> ${uid || 'none'}`);

// --------------------------------------------- the form states the limit it really enforces
await goTo(mp, `${B}/a/a2.asp?B=${BOARD}`);
const note = await mp.evaluate(() => {
  const m = document.body.innerText.replace(/\s+/g, ' ').match(/注：附件大小限制[^。]{0,60}/);
  return m ? m[0] : '';
});
rec('the post form states the image cap as well as the attachment cap',
    /图片最大\s*\d+K/.test(note), note || '(no limit note on the form)');

// ------------------------------------------------- an in-limit image a guest can actually see
let goodId = 0;
{
  const title = 'Att ' + stamp;
  const cap = mp.locator('input[name="ForumNumber"]');
  await mp.fill('input[name="Form_Title"]', title);
  await setEditorContent(mp, 'attachment that should be visible ' + stamp);
  if (await cap.count()) await cap.fill(await currentCaptcha(mp));
  await mp.setInputFiles('input[name="file0"]', SMALL);
  await Promise.all([
    mp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    mp.locator('input[name="submit2"]').first().click({ force: true }),
  ]);
  await mp.waitForTimeout(3000);
  if (process.env.DEBUG24) console.log('DEBUG after small submit:', (await mp.evaluate(()=>document.body.innerText.replace(/\s+/g,' '))).slice(0,400));
  goodId = Number(await dbOne(mp, `SELECT ID FROM leadbbs_announce WHERE Title='${title}'`) || 0);
  const rows = Number(await dbOne(mp, `SELECT count(*) FROM leadbbs_upload WHERE AnnounceID=${goodId}`));
  rec('a member can attach an image to a topic', rows === 1, `${rows} upload row(s) for post ${goodId}`);
}

if (goodId) {
  const gctx = await br.newContext();
  const gp = await gctx.newPage();
  await goTo(gp, `${B}/a/a.asp?b=${BOARD}&id=${goodId}`);
  await gp.waitForTimeout(2500);
  // The UBB tag is expanded client-side by a/inc/leadcode.js, so this has to be measured in a
  // browser: the server sends "[upload=N,0]name[/upload]" as literal text.
  const imgs = await gp.evaluate(() => [...document.images]
    .filter(i => /file\.asp/i.test(i.src))
    .map(i => ({ nw: i.naturalWidth, nh: i.naturalHeight, cw: i.clientWidth })));
  const big = imgs.find(i => i.nw >= 100);
  rec('a logged-out reader SEES the attached image, at its real size',
      !!big, big ? `${big.nw}x${big.nh} rendered ${big.cw}px` : `images found: ${JSON.stringify(imgs)}`);
  rec('the reader is not shown a raw [upload=] tag',
      !(await gp.evaluate(() => document.body.innerText.includes('[upload='))), 'ubb expanded');
  await gctx.close();
}

// ------------------------------------------ an over-cap image is refused, and says so, twice
{
  alerts.length = 0;
  await goTo(mp, `${B}/a/a2.asp?B=${BOARD}`);
  await mp.setInputFiles('input[name="file0"]', BIG);
  await mp.waitForTimeout(600);
  rec('picking an over-cap image warns the poster immediately',
      alerts.some(a => /不能超过/.test(a)), alerts.join(' | ') || '(no warning)');
  const cleared = await mp.evaluate(() => {
    const f = document.querySelector('input[name="file0"]');
    return !f || !f.files || f.files.length === 0;
  });
  rec('the refused file is dropped from the form rather than posted without it',
      cleared, cleared ? 'input cleared' : 'file still attached');
}

// The client check is the friendly half; the server must still explain itself to anything that
// does not run it. This is the half that a2.asp used to discard with Response.Clear.
{
  const title = 'Big ' + stamp;
  await new Promise(r => setTimeout(r, 11000));    // post interval again
  await goTo(mp, `${B}/a/a2.asp?B=${BOARD}`);
  await mp.evaluate(() => { window.upl_onchange = function () {}; });
  await mp.fill('input[name="Form_Title"]', title);
  await setEditorContent(mp, 'oversize attachment ' + stamp);
  const cap = mp.locator('input[name="ForumNumber"]');
  if (await cap.count()) await cap.fill(await currentCaptcha(mp));
  await mp.setInputFiles('input[name="file0"]', BIG);
  await Promise.all([
    mp.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    mp.locator('input[name="submit2"]').first().click({ force: true }),
  ]);
  await mp.waitForTimeout(3000);
  const shown = await mp.evaluate(() => document.body.innerText.replace(/\s+/g, ' '));
  rec('a server-side attachment refusal is shown to the poster, not swallowed by the redirect',
      shown.includes('上传失败'),
      shown.includes('上传失败') ? shown.slice(Math.max(0, shown.indexOf('上传失败') - 40), shown.indexOf('上传失败') + 5)
                                 : 'redirected away with no message');
  const id = Number(await dbOne(mp, `SELECT ID FROM leadbbs_announce WHERE Title='${title}'`) || 0);
  const rows = Number(await dbOne(mp, `SELECT count(*) FROM leadbbs_upload WHERE AnnounceID=${id}`));
  rec('the refused file is not stored', rows === 0, `${rows} upload row(s) for post ${id}`);
}

await br.close();
summary('24-attachment');
