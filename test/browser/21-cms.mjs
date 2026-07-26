// 21 — the CMS admin verbs the 09-cms suite never reached, and the data endpoints its forms
// load: 管理文章 / 编辑其它信息 / 设置栏目内容 / 更新缓存.
//
// setchannel is also the regression guard for §35 (a dimensioned array declared as a Class
// member is mis-sized, which made the page 500) and §36 (LF-only data files collapse under
// Split(..., VbCrLf), which made the CMS home page bounce to the forum instead of rendering).
//
// Verbs driven end to end: newsmanage, editfile, setchannel, updatecache.
import { B, rec, summary, browser, adminPage, db, dbNum, dbOne, dbRows,
         httpGet, goTo } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin session ready', adminOk);
const stamp = Date.now().toString().slice(-6);
const C = `${B}/article/center.asp`;

// ------------------------------------------------ action=newsmanage
{
  await goTo(p, `${C}?action=newsmanage`);
  const rows = await p.locator('a[href*="action=newsarticle&form_modifyid="]').count();
  const arts = await dbNum(p, 'SELECT count(*) FROM article_newsarticle');
  const classes = await dbNum(p, 'SELECT count(*) FROM article_newsclass');
  const tabs = await p.locator('a[href*="action=newsmanage&classid="]').count();
  rec('action=newsmanage lists the articles that exist',
      rows > 0 && rows <= arts * 2, `${rows} edit links for ${arts} articles`);
  rec('and offers one filter per article category', tabs >= classes - 1,
      `${tabs} category tabs for ${classes} categories`);

  // filtering by a real category must narrow the list to that category's articles
  const cls = await dbRows(p,
    'SELECT ID,(SELECT count(*) FROM article_newsarticle A WHERE A.ClassID=C.ID) FROM article_newsclass C ORDER BY ID DESC LIMIT 1');
  if (cls.length) {
    const [cid, n] = cls[0];
    await goTo(p, `${C}?action=newsmanage&classid=${cid}`);
    const shown = await p.locator('a[href*="form_modifyid="]').count();
    rec('filtering by category shows that category\'s articles', shown <= Math.max(2, +n * 2),
        `category ${cid} has ${n} article(s), page offers ${shown} link(s)`);
  }
}

// ------------------------------------------------ action=editfile
{
  await goTo(p, `${C}?action=editfile`);
  const targets = await p.locator('a[href*="action=editfile&form_fileid="]').count();
  rec('action=editfile offers every editable site fragment', targets >= 4, `${targets} targets`);

  // form_fileid=1 is 自定义网站底部信息, written to article/inc/sitebottom_info.asp
  await goTo(p, `${C}?action=editfile&form_fileid=1`);
  const ta = p.locator('textarea').first();
  rec('the site-bottom editor renders its content box', (await ta.count()) > 0);
  const original = await ta.inputValue();
  const marker = `CMSBOTTOM-${stamp}`;
  await ta.fill(`${original}<span id="cmsb">${marker}</span>`);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[name="submit2"], input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1500);
  const f = await httpGet(p, '/test/browser/helpers/f.asp?path=article/inc/sitebottom_info.asp');
  rec('action=editfile writes the fragment to disk',
      f.status === 200 && f.body.includes(marker), `${f.body.length} bytes`);
  // it also keeps a copy in leadbbs_setup so a replaced file can be restored
  const kept = await dbNum(p,
    `SELECT count(*) FROM leadbbs_setup WHERE RID=1051 AND saveData LIKE '%${marker}%'`);
  rec('and keeps a restorable copy in leadbbs_setup', kept > 0, `${kept} row(s)`);

  // put it back
  await goTo(p, `${C}?action=editfile&form_fileid=1`);
  await p.locator('textarea').first().fill(original || ' ');
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[name="submit2"], input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const f2 = await httpGet(p, '/test/browser/helpers/f.asp?path=article/inc/sitebottom_info.asp');
  rec('the site-bottom fragment is restored', !f2.body.includes(marker));
}

// ------------------------------------------------ action=setchannel  (§35 + §36 guard)
{
  await goTo(p, `${C}?action=setchannel`);
  const selects = await p.locator('select[name^="form_type"], input[name^="form_type"]').count();
  const titles = await p.locator('input[name^="form_title"]').count();
  rec('action=setchannel renders all 16 channel slots',
      titles === 16 && selects >= 16, `${titles} titles, ${selects} type pickers`);
  // §36 guard: with the LF-only data file mis-split, every slot but the first came back blank
  const filled = await p.evaluate(() => Array.from(document.querySelectorAll('input[name^="form_title"]'))
    .filter(i => i.value.trim() !== '').length);
  rec('and each slot is loaded with its own stored title, not one merged record',
      filled >= 5, `${filled} of 16 slots carry a title`);

  // configure slot 0 as "latest topics" with a marker title, and save
  const want = `Chan${stamp}`;
  // easyui replaces these inputs with its own widgets and leaves the real elements
  // unfocusable, so Playwright's fill() times out — set the values the way the widget does
  await p.evaluate(t => {
    const set = (name, v) => {
      const e = document.querySelector(`[name="${name}"]`);
      if (e) { e.value = v; e.dispatchEvent(new Event('change', { bubbles: true })); }
    };
    set('form_title0', t);
    set('form_listnum0', '6');
    set('form_type0', '0');
  }, want);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1500);
  const said = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('action=setchannel reports the channel list was saved',
      said.includes('成功编辑首页栏目信息'), said.slice(0, 50));

  const data = await httpGet(p, '/test/browser/helpers/f.asp?path=article/inc/cache/home_channellist_0.asp');
  const lines = data.body.split(/\r?\n/).filter(Boolean);
  rec('the channel data file keeps one record per slot',
      lines.length === 16 && data.body.includes(want),
      `${lines.length} records, marker present=${data.body.includes(want)}`);
  rec('and slot 0 now says "list the newest topics"',
      lines[0] && lines[0].startsWith('0#~#^#' + want), (lines[0] || '').slice(0, 40));

  // the editor must read its own file back correctly on the next load (the §36 round trip)
  await goTo(p, `${C}?action=setchannel`);
  rec('reloading the editor shows the saved title in slot 0',
      (await p.evaluate(() => document.querySelector('[name="form_title0"]').value)) === want);
}

// ------------------------------------------------ action=updatecache
{
  await goTo(p, `${C}?action=updatecache`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  const url = p.url();
  // README §31: the generated cache file is #included, so THIS process still runs the version
  // that existed when it started. If that one was built from an unconfigured channel list it
  // carries the "go to the forum" fallback and bounces us there; the next server sees the file
  // this call just wrote. Either landing is correct — what must be true is the file it wrote.
  rec('action=updatecache runs and either completes or bounces to the forum (§31)',
      txt.includes('缓存更新完成') || /boards\.asp/i.test(url),
      txt.includes('缓存更新完成') ? txt.slice(0, 60) : `bounced to ${url}`);

  // the regenerated home-content cache must now carry the configured channel, not the
  // "nothing configured" redirect this used to fall back to (§36)
  const cache = await httpGet(p, '/test/browser/helpers/f.asp?path=article/inc/cache/CACHE_CMS_HOMECONTENT.asp');
  rec('the regenerated CMS home cache holds the configured channel',
      cache.body.includes(`Chan${stamp}`) && !cache.body.includes('Rw_boards(0)'),
      `${cache.body.length} bytes`);
  rec('and it is a real Sub the home page can include',
      cache.body.includes('Sub CMS_HOMECONTENT_View') && cache.body.includes('End Sub'));
}

// ------------------------------------------------ the per-category channel editors
{
  const ids = (await dbRows(p, 'SELECT ID FROM article_newsclass ORDER BY ID LIMIT 3')).map(r => r[0]);
  for (const id of ids) {
    await goTo(p, `${C}?action=setchannel&form_fileid=${id}`);
    const n = await p.locator('input[name^="form_title"]').count();
    const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    rec(`setchannel for category ${id} renders its own 16 slots`,
        n === 16 && !/error/i.test(txt), `${n} slots`);
  }
}

// ------------------------------------------------ the data endpoints its comboboxes load
{
  // These are generated caches of the *visible* board / 专区 tree, not a dump of the tables,
  // so assert they parse, are non-empty, and carry the entry the rest of the suite uses.
  const feeds = [
    ['/inc/IncHtm/data_boardlist.asp?1', 'boards', '"id":100'],
    ['/inc/IncHtm/data_goodassort.asp', 'topic areas', '"id":'],
    ['/article/inc/cache/data_blank.asp', 'the empty placeholder', null],
  ];
  for (const [url, what, must] of feeds) {
    const r = await httpGet(p, url);
    let ok = r.status === 200 && /^\s*\[/.test(r.body) && /\]\s*$/.test(r.body.trim());
    const items = (r.body.match(/"id"\s*:/g) || []).length;
    let detail = `HTTP ${r.status}, ${r.body.length} bytes, ${items} entries`;
    if (must) ok = ok && r.body.includes(must) && items > 0;
    try { JSON.parse(r.body.trim()); } catch { ok = false; detail += ', NOT valid JSON'; }
    rec(`the combobox feed for ${what} returns usable JSON`, ok, detail);
  }
}

await br.close();
process.exit(summary('21-cms') ? 0 : 1);
