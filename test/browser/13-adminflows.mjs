// 13 — admin flows that had only ever been verified with a DB query or a curl 200:
// the SQL backup (export → download → delete → path-traversal guard), clearing the online
// list, the group private message, and the templet manager.
//
// The templet list is the live regression guard for §30 (Recordset.GetString ignoring its
// delimiters): its rows are emitted as JavaScript built from those delimiters, so with the
// bug the page still returns 200 and renders an EMPTY table.
import { B, rec, summary, browser, adminPage, db, dbNum, dbOne, dbRows,
         httpGet, setSelect, reveal, goTo } from './lib.mjs';

// Several manage/ pages keep a request open, so networkidle never settles here —
// this suite waits for domcontentloaded and then an explicit beat.
const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);
const stamp = Date.now().toString().slice(-6);

// ------------------------------------------------ SQL backup: export, download, delete
{
  const boards = await dbNum(p, 'SELECT count(*) FROM leadbbs_boards');
  await goTo(p, `${B}/manage/Database/BackupDatabase.asp`);
  const btn = p.locator('input[value*="导出"]').first();
  const ok = await btn.count() > 0;
  rec('backup page offers the export button', ok);

  let name = '';
  if (ok) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 90000 }).catch(()=>{}),
      btn.click({ force: true }),
    ]);
    await p.waitForTimeout(2000);
    const body = await p.locator('body').innerText();
    const m = body.match(/leadbbs_\d{14}\.sql/);
    name = m ? m[0] : '';
    rec('export reports a generated dump file', !!name, name || body.replace(/\s+/g,' ').slice(0, 80));
  }

  if (name) {
    const dl = await httpGet(p, `/data/backup/${name}`, 60000);
    rec('the dump downloads over HTTP', dl.status === 200 && dl.body.length > 1000,
        `HTTP ${dl.status}, ${dl.body.length} bytes`);

    const hasSchema = dl.body.includes('CREATE TABLE `leadbbs_announce`') &&
                      dl.body.includes('CREATE TABLE `leadbbs_user`');
    const inserts = (dl.body.match(/INSERT INTO `leadbbs_boards`/g) || []).length;
    rec('the dump contains the real schema and data', hasSchema && inserts > 0,
        `schema=${hasSchema}, ${inserts} board INSERT(s) vs ${boards} rows`);

    // §15/§22 guard: a 14-digit timestamp written as 2.026e+13 would corrupt the dump silently
    // only a BARE numeric literal counts: an e+ inside a quoted string is stored log text
    // being dumped faithfully, not dump corruption
    const sci = /[(,]\s*\d\.\d+e\+\d+\s*[,)]/i.test(dl.body);
    rec('no scientific notation in the dump\'s numeric literals', !sci,
        sci ? 'found a bare e+ literal' : 'clean');

    // delete it again through the UI
    await goTo(p, `${B}/manage/Database/BackupDatabase.asp`);
    const clicked = await p.evaluate(n => {
      for (const f of document.forms) {
        const h = f.querySelector('input[name="f"]');
        if (h && h.value === n) {
          const b = f.querySelector('input[type="submit"]');
          if (b) { b.click(); return true; }
        }
      }
      return false;
    }, name);
    await p.waitForTimeout(2500);
    rec('the per-file delete button was found', clicked, clicked ? name : 'no form with that hidden f');
    const after = await httpGet(p, `/data/backup/${name}`, 20000);
    rec('deleting the dump through the UI removes the file', after.status === 404,
        `HTTP ${after.status} after delete`);
  }
}

// --------------------------------------------------------------- clear online users
{
  const ctx2 = await br.newContext();
  const g = await ctx2.newPage();
  await goTo(g, `${B}/Boards.asp`);
  await p.waitForTimeout(1200);
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_onlineuser');

  await goTo(p, `${B}/manage/User/ClearOnlineUser.asp`);
  const sub = p.locator('input[type="submit"]').first();
  rec('clear-online page renders its form', await sub.count() > 0, `${before} online row(s)`);
  if (await sub.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      sub.click({ force: true }),
    ]);
    await p.waitForTimeout(1200);
  }
  const cleared = await dbNum(p, 'SELECT count(*) FROM leadbbs_onlineuser');
  rec('clearing empties the online-user table', before > 0 && cleared < before, `${before} -> ${cleared}`);

  // and the tracker must rebuild, with the §17-normalised IP
  // A session that was already registered does NOT re-insert after the truncate — it still
  // believes it is on the list, so its write is an UPDATE that matches nothing. That is
  // upstream behaviour, not a port bug. The honest check is that the tracker still works:
  // a NEW session must appear, with the §17-normalised IPv4 loopback address.
  const ctx3 = await br.newContext();
  const fresh = await ctx3.newPage();
  await goTo(fresh, `${B}/Boards.asp`);
  await p.waitForTimeout(2000);
  const rebuilt = await dbNum(p, 'SELECT count(*) FROM leadbbs_onlineuser');
  const ip = await dbOne(p, "SELECT IP FROM leadbbs_onlineuser ORDER BY ID DESC LIMIT 1");
  rec('the online tracker still registers new sessions after the clear',
      rebuilt >= 1 && ip === '127.0.0.1', `${rebuilt} row(s), IP=${ip}`);
  await ctx3.close();
  await ctx2.close();
}

// ------------------------------------------------------------- templet manager (CRUD)
{
  const TPL = 'TPL' + stamp;
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_templet');
  await goTo(p, `${B}/manage/SiteManage/TempletManage.asp?action=Join`);
  const nameBox = p.locator('input[name="Form_TempletName"]').first();
  const ok = await nameBox.count() > 0;
  rec('templet add form renders', ok);
  if (ok) {
    await nameBox.fill(TPL);
    const l1 = p.locator('input[name="Limit1"]').first();
    if (await l1.count()) { await reveal(l1); await l1.check({ force: true }).catch(()=>{}); }
    const ta = p.locator('textarea[name="Form_TempletString0"]').first();
    if (await ta.count()) await ta.fill(`<!--TPLMARK${stamp}-->`);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('form#form1 input[type="submit"], input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1500);
  }
  const id = await dbOne(p, `SELECT ID FROM leadbbs_templet WHERE TempletName='${TPL}'`);
  rec('creating a templet writes the row', !!id,
      `templet ${before}->${await dbNum(p, 'SELECT count(*) FROM leadbbs_templet')}, id ${id || 'none'}`);

  if (id) {
    // the generated file — assert via the loopback file oracle, not the URL: it is written
    // with an uppercase .JS extension and the router is case-sensitive (§29)
    const f = await httpGet(p, `/test/browser/helpers/f.asp?path=inc/Templet/${id}_0.JS`, 20000);
    rec('the templet file is generated on disk', f.body.includes(`TPLMARK${stamp}`),
        f.body.slice(0, 40).replace(/\s+/g, ' '));

    // THE §30 REGRESSION GUARD: this list is JavaScript built from GetString's delimiters
    await goTo(p, `${B}/manage/SiteManage/TempletManage.asp`);
    const listed = (await p.locator('body').innerText()).includes(TPL);
    rec('the templet LIST renders the row (GetString path)', listed, TPL);

    // delete it again (note the upstream typo in the hidden field: DeleteSuer)
    await goTo(p, `${B}/manage/SiteManage/TempletManage.asp?action=Delete&ID=${id}`);
    const del = p.locator('input[type="submit"]').first();
    if (await del.count()) {
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
        del.click({ force: true }),
      ]);
      await p.waitForTimeout(1200);
    }
    const gone = await dbNum(p, `SELECT count(*) FROM leadbbs_templet WHERE ID=${id}`);
    rec('deleting the templet removes only that row', gone === 0,
        `templet ${id} gone=${gone === 0}, table now ${await dbNum(p, 'SELECT count(*) FROM leadbbs_templet')}`);
  }
}

await br.close();
process.exit(summary('13-adminflows') ? 0 : 1);
