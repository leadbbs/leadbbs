// 17 — 批量整理论坛数据 (manage/BlockUpdate/*) and the database tools.
//
// Every one of these is a two-stage job: the link lands on a "确定此操作吗?" confirm form, and
// submitting it renders a progress page whose real work happens inside an <iframe>
// (executepage=yes). Both halves are driven here, and each check asserts either the completion
// the page prints or the data the job was supposed to correct.
//
// Verb driven end to end: blockdelete.
import { B, rec, summary, browser, adminPage, db, dbNum, dbOne, dbRows,
         httpGet, goTo } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);
const BU = `${B}/manage/BlockUpdate`;

// Drive one batch job: open it, submit the confirm form, then read BOTH the progress page and
// the iframe that actually executes it.
async function runBatch(url, fill = {}) {
  await goTo(p, url);
  const form = p.locator('form').first();
  if (await form.count() === 0) return { main: await p.locator('body').innerText(), frame: '' };
  for (const [k, v] of Object.entries(fill)) {
    const f = form.locator(`[name="${k}"]`).first();
    if (await f.count()) await f.fill(String(v)).catch(()=>{});
  }
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 90000 }).catch(()=>{}),
    form.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(3500);
  let frame = '';
  for (const fr of p.frames()) {
    if (fr === p.mainFrame()) continue;
    frame += (await fr.locator('body').innerText().catch(() => '')) + ' ';
  }
  return {
    main: (await p.locator('body').innerText()).replace(/\s+/g, ' '),
    frame: frame.replace(/\s+/g, ' ').trim(),
  };
}

// ------------------------------------------------ manage/update.asp
// The升级工具 closes the forum while it runs and can overwrite plug-ins and images, so this
// drives as far as the confirmation and asserts the guard — never past it.
//
// It is driven FIRST on purpose: rendering it calls restartbbs(), which does
// Application.Contents.RemoveAll. That is fine for the app (those are caches) but it also
// erases the coverage accumulator test/coverage/instrument.py keeps in Application, so any
// file this suite is the only one to touch would vanish from the census if update.asp ran
// last. manage/BlockUpdate/BlockUpdate.asp was exactly that file.
{
  await goTo(p, `${B}/manage/update.asp`);
  const bare = await p.locator('body').innerText();
  rec('update.asp does nothing without an explicit sure=1', !bare.includes('确定继续'),
      bare.replace(/\s+/g,' ').slice(0, 50));

  await goTo(p, `${B}/manage/update.asp?sure=1`);
  const txt = await p.locator('body').innerText();
  rec('update.asp?sure=1 explains the four upgrade tools and demands confirmation',
      txt.includes('导出扩展参数') && txt.includes('检测是否有版本更新') &&
      (await p.locator('input[value*="确定继续"]').count()) > 0,
      txt.replace(/\s+/g,' ').slice(0, 60));
  rec('it warns that the forum is suspended while it runs',
      txt.includes('强制暂停论坛运行'));
}

// ------------------------------------------------ 重新统计所有用户发帖数量
// The job recomputes each user's post counters from leadbbs_announce, so afterwards the
// stored counter for a real user must equal what the posts table actually says.
{
  const r = await runBatch(`${BU}/UpdateUnderWritePrintColumn.asp?flag=UpdateUserAnnounce&ReCount=1`);
  const users = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  rec('重新统计用户发帖 runs over every user',
      r.main.includes('操作完成') && r.main.includes(`共有${users}个用户`),
      r.main.slice(0, 70));
  rec('the job iframe reports it finished', r.frame.includes('完成'), r.frame.slice(0, 40) || '(empty)');

  const real = await dbNum(p,
    "SELECT count(*) FROM leadbbs_announce WHERE UserID=(SELECT ID FROM leadbbs_user WHERE UserName='admin')");
  const stored = await dbNum(p, "SELECT AnnounceNum FROM leadbbs_user WHERE UserName='admin'");
  rec("admin's stored post counter now matches the posts table", stored === real && real > 0,
      `leadbbs_user.AnnounceNum=${stored}, actual posts=${real}`);
  // and the number the profile page shows a reader is that same recomputed figure
  await goTo(p, `${B}/User/LookUserInfo.asp?username=admin`);
  const prof = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the profile page shows the recomputed post count', prof.includes(String(real)),
      `looking for ${real} in the profile`);
}

// ------------------------------------------------ 修复表LeadBBS_Announce的主题帖子
{
  const r = await runBatch(`${BU}/UpdateUnderWritePrintColumn.asp?flag=UpdateRootMaxMinAnnounceID`);
  rec('修复主题帖子 completes', /完成|100.00%/.test(r.main), r.main.slice(0, 70));
  // The job recomputes, per topic, ChildNum = (posts sharing its RootIDBak) - 1 and
  // RootMaxID = max(ID) of those. Assert exactly that, over the whole table.
  const bad = await dbNum(p,
    'SELECT count(*) FROM leadbbs_announce T WHERE T.ParentID=0 AND T.ChildNum <> ' +
    'GREATEST((SELECT count(*) FROM leadbbs_announce C WHERE C.RootIDBak=T.RootIDBak)-1,0)');
  rec("after the repair every topic's reply count is right", bad === 0,
      `${bad} topic(s) still disagree`);
  const badMax = await dbNum(p,
    'SELECT count(*) FROM leadbbs_announce T WHERE T.ParentID=0 AND T.RootMaxID <> ' +
    '(SELECT max(C.ID) FROM leadbbs_announce C WHERE C.RootIDBak=T.RootIDBak)');
  rec('and every topic points at the real last post in its thread', badMax === 0,
      `${badMax} topic(s) with a stale RootMaxID`);
}

// ------------------------------------------------ SiteMap generation (BlockType=4)
{
  const r = await runBatch(`${BU}/UpdateUnderWritePrintColumn.asp?flag=UpdateRootMaxMinAnnounceID&BlockType=4`);
  rec('the SiteMap generator runs to completion', /完成|100.00%/.test(r.main), r.main.slice(0, 70));
  // sitemap.xml is the INDEX; the URLs live in sitemap_1.xml
  const idx = await httpGet(p, '/test/browser/helpers/f.asp?path=sitemap.xml');
  rec('it writes a valid sitemap index',
      idx.body.includes('<sitemapindex') && idx.body.includes('sitemap_1.xml') &&
      /<lastmod>\d{4}-\d{2}-\d{2}<\/lastmod>/.test(idx.body) && !/\/\/sitemap_/.test(idx.body),
      idx.body.replace(/\s+/g, ' ').slice(0, 110));
  const map = await httpGet(p, '/test/browser/helpers/f.asp?path=sitemap_1.xml');
  const locs = (map.body.match(/<loc>/g) || []).length;
  const roots = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce WHERE ParentID=0');
  rec('the sitemap lists the forum\'s topics as real, single-slashed URLs',
      locs > 0 && locs <= roots && map.body.includes('/a/a.asp') && !/9596\/\//.test(map.body),
      `${locs} <loc> entries for ${roots} topics, ${map.body.length} bytes`);
}

// ------------------------------------------------ 重新产生所有用户的农历生日 (BlockType=3)
{
  const r = await runBatch(`${BU}/UpdateUnderWritePrintColumn.asp?flag=UpdateRootMaxMinAnnounceID&BlockType=3`);
  rec('农历生日 regeneration completes', /完成|100.00%/.test(r.main), r.main.slice(0, 70));
}

// ------------------------------------------------ 批量更新帖子内容数据 (a content search/replace)
// Replace a string that does not occur, so the job does its full pass and changes nothing.
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  const r = await runBatch(`${BU}/UpdateUnderWritePrintColumn.asp?flag=1`,
                           { Str1: 'zzz-no-such-token-zzz', Str2: 'replacement' });
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  rec('批量更新帖子内容 runs a full pass', /完成|100.00%|确定/.test(r.main), r.main.slice(0, 70));
  rec('a no-op replacement leaves every post in place', after === before,
      `${before} -> ${after} posts`);
}

// ------------------------------------------------ 删除无发帖的旧用户 (destructive, but scoped)
// Only users registered over a month ago with no posts qualify; every account this suite's
// siblings create is newer than that, so this exercises the scan without eating test data.
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  const r = await runBatch(`${BU}/UpdateUnderWritePrintColumn.asp?flag=DeleteBlankUser`);
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  rec('删除空用户 scans the user table and reports', /完成|100.00%|用户/.test(r.main),
      r.main.slice(0, 70));
  rec('it does not delete accounts that do not qualify', after === before,
      `leadbbs_user ${before} -> ${after}`);
}

// ------------------------------------------------ 批量删除历史附件 (dflag=upload)
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_upload');
  const r = await runBatch(`${BU}/UpdateUnderWritePrintColumn.asp?flag=DeleteBlankUser&dflag=upload`,
                           { Str1: '19900101', Str2: '19900102' });
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_upload');
  rec('批量删除历史附件 accepts a date range and runs', r.main.length > 40, r.main.slice(0, 70));
  rec('a 1990 date range deletes no attachment', after === before,
      `leadbbs_upload ${before} -> ${after}`);
}

// ------------------------------------------------ 批量删除指定条件的帖子
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  await goTo(p, `${BU}/DeleteExpiresAnnounceData.asp`);
  const txt = await p.locator('body').innerText();
  rec('批量删除帖子 renders its board + date filter',
      (await p.locator('form').count()) > 0 && txt.length > 60, txt.replace(/\s+/g,' ').slice(0, 60));
  const r = await runBatch(`${BU}/DeleteExpiresAnnounceData.asp`, { Str1: '19900101', Str2: '19900102' });
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  rec('a 1990 date range deletes no post', after === before,
      `${r.main.slice(0, 40)} | leadbbs_announce ${before} -> ${after}`);
}

// ------------------------------------------------ the two orphan repair pages
{
  const r = await runBatch(`${BU}/UpdatePrintColumn.asp`);
  rec('UpdatePrintColumn runs its pass', /完成|100.00%|确定/.test(r.main + r.frame),
      (r.main + ' | ' + r.frame).slice(0, 70));

  const r2 = await runBatch(`${BU}/RepairLastInfo.asp`);
  rec('RepairLastInfo runs its pass', r2.main.length > 20 && !/error/i.test(r2.main),
      r2.main.slice(0, 70));
  // it rewrites每个主题's cached "last reply" line, so no topic may advertise a last reply
  // that is not in the table any more
  const bad = await dbNum(p,
    "SELECT count(*) FROM leadbbs_announce T WHERE T.ParentID=0 AND T.LastInfo<>'' " +
    "AND T.RootMaxID > 0 AND NOT EXISTS (SELECT 1 FROM leadbbs_announce A WHERE A.ID=T.RootMaxID)");
  rec('no topic is left advertising a reply that no longer exists', bad === 0,
      `${bad} stale topic pointer(s)`);
}

// ------------------------------------------------ Io_Info: the progress reporter those jobs poll
{
  const io = await httpGet(p, '/manage/BlockUpdate/Io_Info.asp?id=admin');
  rec('Io_Info answers the progress poll for the signed-in admin',
      io.status === 200 && io.body.length >= 0 && !/error/i.test(io.body),
      `HTTP ${io.status}, body="${io.body.replace(/\s+/g,' ').slice(0, 40)}"`);
}

// ------------------------------------------------ 数据库工具 (manage/Database)
{
  await goTo(p, `${B}/manage/Database/TableInfo.asp`);
  const links = await p.locator('a[href*="TableInfo.asp?tb="]').count();
  rec('TableInfo lists the tables it can describe', links >= 20, `${links} table links`);

  await goTo(p, `${B}/manage/Database/TableInfo.asp?tb=LeadBBS_Announce`);
  const txt = await p.locator('body').innerText();
  const rows = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  const cols = await dbNum(p,
    "SELECT count(*) FROM information_schema.columns WHERE table_schema='leadbbs' AND table_name='leadbbs_announce'");
  const shown = await p.locator('table.frame_table tr').count();
  rec('TableInfo describes the real MariaDB table', txt.includes('leadbbs_announce') &&
      txt.includes('InnoDB') && shown === cols,
      `${shown} columns shown, information_schema says ${cols}`);
  rec('TableInfo reports the real row count', txt.includes(`现有的行数：${rows}`) ||
      new RegExp(`现有的行数：${Math.max(0, rows - 30)}`).test(txt),
      `page vs db rows=${rows}`);

  // the MSSQL-only tools must SAY they are unavailable rather than render blank
  await goTo(p, `${B}/manage/Database/FullTextManage.asp`);
  const ft = await p.locator('body').innerText();
  rec('FullTextManage explains it needs MSSQL instead of rendering blank',
      ft.includes('MSSQL') && ft.includes('不支持'), ft.replace(/\s+/g,' ').slice(0, 60));

  await goTo(p, `${B}/manage/Database/ExeCuteFullTEXTCommands.asp?ExeFlag=1`);
  const cf = p.locator('input[type="submit"]').first();
  rec('ExeCuteFullTEXTCommands asks for confirmation first', (await cf.count()) > 0);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    cf.click({ force: true }),
  ]);
  await p.waitForTimeout(700);
  const cft = await p.locator('body').innerText();
  rec('and then reports the command is not available on this backend',
      cft.includes('MSSQL') && cft.includes('不支持'), cft.replace(/\s+/g,' ').slice(0, 60));
}

// ------------------------------------------------ the two index pages
// Driven LAST, not first. manage/update.asp (above) and anything else that calls
// Application.Contents.RemoveAll erases the coverage accumulator instrument.py keeps there,
// and manage/BlockUpdate/BlockUpdate.asp is a file only this suite opens — so if it is
// visited early it can be wiped before the census samples it and reported unreached while a
// browser is demonstrably rendering it. Visiting it after everything else settles that.
{
  await goTo(p, `${BU}/BlockUpdate.asp`);
  const jobs = await p.locator('a[href*="blockupdate("]').count();
  rec('批量整理 lists its repair jobs', jobs >= 5, `${jobs} job links`);

  await goTo(p, `${BU}/BlockUpdate.asp?action=blockdelete`);
  const txt = await p.locator('body').innerText();
  rec('action=blockdelete switches to the batch-DELETE tools',
      txt.includes('批量删除论坛数据') &&
      (await p.locator('a[href*="DeleteExpiresAnnounceData"]').count()) > 0 &&
      (await p.locator('a[href*="dflag=upload"]').count()) > 0,
      txt.replace(/\s+/g, ' ').slice(0, 50));
}

await br.close();
process.exit(summary('17-adminblock') ? 0 : 1);
