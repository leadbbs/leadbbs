// 09 — the CMS (文章中心): create a category and publish an article through the real
// backend forms, then read the article back on the public page.
import { B, rec, summary, browser, adminPage, dbNum, dbOne, setSelect, setEditorContent } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);

const stamp = Date.now().toString().slice(-6);
const CLASS = 'CmsCat' + stamp;
const TITLE = 'CmsArticle ' + stamp;

// ------------------------------------------------------- create a news category
{
  const before = await dbNum(p, 'SELECT count(*) FROM article_newsclass');
  await p.goto(`${B}/article/center.asp?action=newsclass`, { waitUntil: 'domcontentloaded' });
  const ok = await p.locator('input[name="form_classname"]').count() > 0;
  rec('CMS category form renders', ok);
  if (ok) {
    await p.fill('input[name="form_classname"]', CLASS);
    const ord = p.locator('input[name="form_orderflag"]');
    if (await ord.count()) await ord.fill('1');
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1500);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM article_newsclass');
  const cid = await dbOne(p, `SELECT ID FROM article_newsclass WHERE ClassName='${CLASS}'`);
  rec('CMS category is created', after > before && !!cid, `newsclass ${before}->${after}, id ${cid || 'none'}`);
}

// ------------------------------------------------------------ publish an article
const cid = await dbOne(p, `SELECT ID FROM article_newsclass WHERE ClassName='${CLASS}'`);
{
  const before = await dbNum(p, 'SELECT count(*) FROM article_newsarticle');
  await p.goto(`${B}/article/center.asp?action=newsarticle`, { waitUntil: 'domcontentloaded' });
  const ok = await p.locator('input[name="form_title"]').count() > 0;
  rec('CMS article form renders', ok);
  if (ok) {
    await p.fill('input[name="form_title"]', TITLE);
    const author = p.locator('input[name="form_author"]');
    if (await author.count()) await author.fill('admin');
    // the class is chosen with a select that writes the hidden form_classid
    if (cid) await p.evaluate(id => {
      const h = document.getElementsByName('form_classid')[0];
      if (h) h.value = id;
      document.querySelectorAll('select').forEach(s => {
        if ([...s.options].some(o => o.value === id)) { s.value = id; s.dispatchEvent(new Event('change', {bubbles:true})); }
      });
    }, String(cid));
    await setEditorContent(p, 'Article body published through the browser at ' + stamp);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(2000);
  }
  const after = await dbNum(p, 'SELECT count(*) FROM article_newsarticle');
  const aid = await dbOne(p, `SELECT ID FROM article_newsarticle WHERE Title='${TITLE}'`);
  rec('CMS article is published', after > before && !!aid, `newsarticle ${before}->${after}, id ${aid || 'none'}`);
}

// ---------------------------------------------- the article reads back publicly
{
  const aid = await dbOne(p, `SELECT ID FROM article_newsarticle WHERE Title='${TITLE}'`);
  if (!aid) {
    rec('published article is readable on the public CMS page', false, 'article was not created');
  } else {
    // the public CMS renders a category page; the article body is shown inline there
    await p.goto(`${B}/article/article.asp?classid=${cid}`, { waitUntil: 'domcontentloaded' }).catch(()=>{});
    const body = await p.locator('body').innerText();
    rec('published article is readable on the public CMS page',
        body.includes(TITLE) && body.includes(stamp), `article ${aid} in class ${cid}`);
  }
}

await br.close();
process.exit(summary('09-cms') ? 0 : 1);
