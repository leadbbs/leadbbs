// Search, favourites, attachments and topic actions — through the real UI.
import { B, rec, summary, browser, login, pinCaptcha, db, dbNum, setEditorContent } from './lib.mjs';
import { writeFileSync } from 'fs';
const br = await browser();
const p = await login(br, 'testuser001', 'Test123456');

// --- SEARCH: type a keyword into the real search form and submit ---
const known = (await db(p, "SELECT Title FROM leadbbs_announce WHERE Title LIKE 'Topic UI%' ORDER BY ID DESC LIMIT 1")).split('\n').pop().trim();
const kw = known.split(' ').pop();
await p.goto(`${B}/Search/search.asp`, { waitUntil:'domcontentloaded' });
rec('search form renders', (await p.locator('input[name="key"]').count()) > 0);
await p.fill('input[name="key"]', kw).catch(()=>{});
await p.evaluate(() => { const r=document.querySelector('input[name="mode"][value="2"]'); if(r) r.checked=true; });
await Promise.all([
  p.waitForNavigation({waitUntil:'domcontentloaded'}).catch(()=>{}),
  p.locator('input[name="submit2"]').first().click({force:true}).catch(()=>{}),
]);
await p.waitForTimeout(1200);
rec('search returns the topic in the UI', (await p.content()).includes(kw), `kw=${kw}`);

// --- ATTACHMENT: post a topic with a real file input ---
const mark = 'ATTUI' + Date.now().toString().slice(-5);
// A 1x1 transparent GIF used to stand here. It made this whole block untrustworthy: a forum
// that rendered the attachment perfectly and one that dropped it both looked identical to a
// human, so the checks below could only ever confirm that a row existed. Use something with
// a size worth asserting, and assert it — see 24-attachment.mjs for the rest.
writeFileSync('/tmp/ui_att.gif', Buffer.from(
  'R0lGODdhQAAgAIABAOAoKP///ywAAAAAQAAgAAACS4yPqcvtD6OctNqLs968+w+G4kiW5omm6sq27gvH8kzX' +
  '9o3n+s73/g8MCofEovGITCqXzKbzCY1Kp9Sq9YrNarfcrvcLDovH5PKsAAA7', 'base64'));
await new Promise(r=>setTimeout(r,11000));
await pinCaptcha(p);
const ub = await dbNum(p, 'SELECT count(*) FROM leadbbs_upload');
await p.goto(`${B}/a/a2.asp?B=100`, { waitUntil:'domcontentloaded' });
await p.fill('input[name="Form_Title"]', 'Attach ' + mark).catch(()=>{});
await setEditorContent(p, 'post with an attachment ' + mark);
await p.fill('input[name="ForumNumber"]', '1234').catch(()=>{});
const fileInputs = await p.locator('input[type="file"]').count();
if (fileInputs > 0) await p.setInputFiles('input[type="file"]', '/tmp/ui_att.gif').catch(e=>console.log('  attach err', e.message));
await Promise.all([
  p.waitForNavigation({waitUntil:'domcontentloaded'}).catch(()=>{}),
  p.locator('input[name="submit2"], input[type="submit"]').first().click({force:true}).catch(()=>{}),
]);
await p.waitForTimeout(2500);
const ua = await dbNum(p, 'SELECT count(*) FROM leadbbs_upload');
rec('upload an attachment via the real file input', ua === ub + 1, `file inputs=${fileInputs}, upload ${ub}->${ua}`);

// --- the attachment is downloadable from the topic page ---
const up = (await db(p, 'SELECT ID FROM leadbbs_upload ORDER BY ID DESC LIMIT 1')).split('\n').pop().trim();
const resp = await p.evaluate(async id => {
  const r = await fetch('/a/file.asp?Lid='+id+'&s='+window.__dk, {redirect:'follow'});
  return r.status + ':' + (await r.blob()).size;
}, up).catch(()=>'n/a');
rec('attachment row created with a file', (await db(p,`SELECT PhotoDir FROM leadbbs_upload WHERE ID=${up}`)).includes('/'), 'PhotoDir set');

// ...and a reader can SEE it. The [upload=] tag is expanded client-side, so this must be
// measured in the browser rather than inferred from the row above.
{
  const aid = (await db(p, `SELECT AnnounceID FROM leadbbs_upload WHERE ID=${up}`)).split('\n').pop().trim();
  await p.goto(`${B}/a/a.asp?b=100&id=${aid}`, { waitUntil: 'domcontentloaded' });
  await p.waitForTimeout(2000);
  const shown = await p.evaluate(() => [...document.images]
    .filter(i => /file\.asp/i.test(i.src)).map(i => i.naturalWidth));
  rec('the attached image is visible on the topic page',
      shown.some(w => w >= 32), `rendered widths: ${JSON.stringify(shown)}`);
}

// --- FAVOURITE: click 加入收藏 on a topic page ---
const tid = (await db(p, "SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 1")).split('\n').pop().trim();
await p.evaluate(async () => { await fetch('/test/browser/helpers/q.asp?sql='+encodeURIComponent('SELECT 1')); });
const fb = await dbNum(p, 'SELECT count(*) FROM leadbbs_collectanc WHERE UserID=199083');
await p.goto(`${B}/a/a.asp?B=100&ID=${tid}`, { waitUntil:'domcontentloaded' });
// the forum's collect action is the link whose onclick calls a_msg(...,'Collect...')
const favLink = p.locator('a[onclick*="Collect"]');
rec('favourite link present on the topic page', await favLink.count() > 0);
if (await favLink.count() > 0) {
  await favLink.first().click({force:true}).catch(()=>{});
  await p.waitForTimeout(2500);
  const fa = await dbNum(p, 'SELECT count(*) FROM leadbbs_collectanc WHERE UserID=199083');
  rec('favourite recorded after clicking the link', fa === fb + 1, `collect ${fb}->${fa}`);
}
await br.close();
process.exit(summary('03-features') ? 0 : 1);
