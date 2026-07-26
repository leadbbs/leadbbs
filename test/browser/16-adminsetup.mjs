// 16 — 风格 / 参数 / 修复: the extended-skin manager, the four setup pages, the on-line file
// editors and the two site-repair tools.
//
// The skin manager is also the regression guard for README §35 (a dimensioned array declared
// as a Class member is mis-sized by AxonASP): its whole dispatcher lives in a class whose
// `DT(5,4)` field made every one of these four verbs raise "Subscript out of range".
//
// Verbs driven end to end: extentskin_add / extentskin_modify / extentskin_delete /
// extentskin_manage (skins) and AllTopAnc (site-wide sticky, then cleared from the admin).
import { B, rec, summary, browser, adminPage, db, dbNum, dbOne, dbRows,
         httpGet, goTo, ajaxCommand } from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);
const stamp = Date.now().toString().slice(-6);
const DSP = `${B}/manage/SiteManage/DefineStyleParameter.asp`;
const skins = () => dbNum(p, 'SELECT count(*) FROM leadbbs_skin WHERE StyleID>=1000');

// ------------------------------------------------ action=extentskin_manage (the list)
{
  const before = await skins();
  await goTo(p, `${DSP}?action=extentskin_manage`);
  const txt = await p.locator('body').innerText();
  const links = await p.locator('a[href*="extentskin_modify"]').count();
  rec('extentskin_manage lists every extended skin', links === before && before > 0,
      `page offers ${links} edit links, DB has ${before} skins`);
  rec('extentskin_manage offers the create link',
      (await p.locator('a[href*="extentskin_add"]').count()) > 0);
}

// ------------------------------------------------ action=extentskin_add
let newId = 0;
{
  const name = `SK${stamp}`;
  await goTo(p, `${DSP}?action=extentskin_add`);
  const form = p.locator('input[name="StyleName"]').first();
  rec('extentskin_add renders the create form', (await form.count()) > 0);
  await form.fill(name);
  await p.locator('input[name="DisplayTopicLength"]').first().fill('54');
  await p.locator('textarea[name="CssContent"]').first().fill(`/* ${name} */\nbody{color:#123456}`);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(900);
  const done = await p.locator('body').innerText();
  rec('extentskin_add reports the skin was created', done.includes('成功创建风格'),
      done.replace(/\s+/g, ' ').slice(0, 60));

  newId = parseInt(await dbOne(p,
    `SELECT StyleID FROM leadbbs_skin WHERE ScreenWidth='${name}'`), 10) || 0;
  rec('the new skin is a real leadbbs_skin row with an allocated id', newId >= 1000,
      `StyleID=${newId}`);

  await goTo(p, `${DSP}?action=extentskin_manage`);
  rec('the new skin shows in the manage list',
      (await p.locator('body').innerText()).includes(name));
  // the CSS a visitor would load must really be the content that was typed
  const pad = ('00000' + newId).slice(-5);
  const css = await httpGet(p, `/test/browser/helpers/f.asp?path=inc/css/${pad}.css`);
  rec('the skin writes a real stylesheet', css.status === 200 && css.body.includes('#123456'),
      `inc/css/${pad}.css: HTTP ${css.status}, ${css.body.length} bytes`);
}

// ------------------------------------------------ action=extentskin_modify
{
  const renamed = `SK${stamp}b`;
  await goTo(p, `${DSP}?action=extentskin_modify&StyleID=${newId}`);
  const f = p.locator('input[name="StyleName"]').first();
  const prefill = (await f.count()) ? await f.inputValue() : '';
  rec('extentskin_modify pre-fills the skin being edited', prefill === `SK${stamp}`,
      `form shows "${prefill}"`);
  // §37 regression guard: the CSS body is only loaded when `If DT(0,4) > 0` is true, and that
  // comparison — String vs number in condition position — is always False under AxonASP.
  const cssBack = await p.locator('textarea[name="CssContent"]').first().inputValue().catch(()=>'');
  rec('extentskin_modify loads the existing stylesheet into the form',
      cssBack.includes('#123456'), cssBack.replace(/\s+/g,' ').slice(0, 40) || '(empty)');
  await f.fill(renamed);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(900);
  const now = await dbOne(p, `SELECT ScreenWidth FROM leadbbs_skin WHERE StyleID=${newId}`);
  rec('extentskin_modify renames the skin', now === renamed, `DB says "${now}"`);
}

// ------------------------------------------------ action=extentskin_delete
{
  const before = await skins();
  await goTo(p, `${DSP}?action=extentskin_delete&StyleID=${newId}`);
  await p.waitForTimeout(700);
  const txt = await p.locator('body').innerText();
  rec('extentskin_delete reports the deletion', txt.includes('删除操作完成'),
      txt.replace(/\s+/g, ' ').slice(0, 50));
  const left = await dbNum(p, `SELECT count(*) FROM leadbbs_skin WHERE StyleID=${newId}`);
  rec('the deleted skin is gone from the database', left === 0 && (await skins()) === before - 1,
      `rows for ${newId}: ${left}`);
  await goTo(p, `${DSP}?action=extentskin_manage`);
  rec('the deleted skin is gone from the manage list',
      !(await p.locator('body').innerText()).includes(`SK${stamp}`));
}

// ------------------------------------------------ 在线编辑 (SiteEditFile / SiteEditFileContent)
{
  await goTo(p, `${B}/manage/SiteManage/SiteEditFile.asp`);
  const editors = await p.locator('a[href*="SiteEditFileContent.asp"]').count();
  rec('SiteEditFile lists the editable files', editors >= 3, `${editors} editor links`);

  // file=-1 is the registration agreement a new user has to read
  const url = `${B}/manage/SiteManage/SiteEditFileContent.asp?file=-1`;
  await goTo(p, url);
  const ta = p.locator('textarea[name="fileContent"]').first();
  const original = await ta.inputValue();
  const marker = `<p id="regmk">AGREE-${stamp}</p>`;
  await ta.fill(original + marker);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[name="save"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(900);
  const said = await p.locator('body').innerText();
  rec('SiteEditFileContent reports the file was written', said.includes('成功更新文件内容'),
      said.replace(/\s+/g, ' ').slice(0, 50));
  // User/inc/User_Reg.asp is #included by the registration page, so the rendered page only
  // picks it up after a restart (README §31) — assert the file that was actually written.
  const f = await httpGet(p, '/test/browser/helpers/f.asp?path=User/inc/User_Reg.asp');
  rec('the registration agreement file really contains the new text',
      f.status === 200 && f.body.includes(`AGREE-${stamp}`), `HTTP ${f.status}`);

  await goTo(p, url);
  await p.locator('textarea[name="fileContent"]').first().fill(original);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[name="save"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(700);
  const f2 = await httpGet(p, '/test/browser/helpers/f.asp?path=User/inc/User_Reg.asp');
  rec('the registration agreement is restored', !f2.body.includes(`AGREE-${stamp}`));
}

// ------------------------------------------------ the three setup pages
// Each writes a generated include under inc/; assert the reload AND the generated file,
// then put the value back.
const setups = [
  // UbbcodeSetup's value comes back to the form from the COMPILED const in the generated
  // include, so it cannot change in this process (§31) — the file is the only honest check.
  { name: 'UbbcodeSetup', field: 'Form_DEF_MaxUBBNumber', reloads: false,
    file: 'inc/Ubbcode_Setup.asp', konst: 'DEF_MaxUBBNumber' },
  { name: 'UploadSetup', field: 'Form_DEF_UploadOneDayMaxNum', reloads: true,
    file: 'inc/Upload_Setup.asp', konst: 'DEF_UploadOneDayMaxNum' },
];
for (const s of setups) {
  const url = `${B}/manage/SiteManage/${s.name}.asp`;
  await goTo(p, url);
  const f = p.locator(`input[name="${s.field}"]`).first();
  if (await f.count() === 0) { rec(`${s.name} renders ${s.field}`, false, 'field missing'); continue; }
  const original = await f.inputValue();
  // the probe must differ from whatever the setting happens to be, or "restored" proves nothing
  s.probe = String(((parseInt(original, 10) || 10) % 90) + 5);
  s.token = `${s.konst} = ${s.probe}`;
  await f.fill(s.probe);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(900);
  const said = await p.locator('body').innerText();
  rec(`${s.name} accepts the change`, said.includes('成功完成设置'),
      said.replace(/\s+/g, ' ').slice(-40));
  const gen = await httpGet(p, `/test/browser/helpers/f.asp?path=${s.file}`);
  rec(`${s.name} writes ${s.token} into ${s.file}`,
      gen.status === 200 && gen.body.includes(s.token),
      `HTTP ${gen.status}, ${gen.body.length} bytes`);
  if (s.reloads) {
    await goTo(p, url);
    const back = await p.locator(`input[name="${s.field}"]`).first().inputValue();
    rec(`${s.name} shows ${s.field} as ${s.probe} on reload`, back === s.probe, `"${back}"`);
  }
  await goTo(p, url);
  await p.locator(`input[name="${s.field}"]`).first().fill(original);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(700);
  const gen2 = await httpGet(p, `/test/browser/helpers/f.asp?path=${s.file}`);
  rec(`${s.name} restores ${s.field}`, !gen2.body.includes(s.token));
}

// ------------------------------------------------ 表情注释 (UBBiconSetup)
{
  const url = `${B}/manage/SiteManage/UBBiconSetup.asp`;
  await goTo(p, url);
  const f = p.locator('input[name="Form_DEF_UBBiconNote0"]').first();
  const original = await f.inputValue();
  const want = `笑${stamp}`;
  rec('UBBiconSetup renders all 99 emoticon notes',
      (await p.locator('input[name^="Form_DEF_UBBiconNote"]').count()) >= 99,
      `${await p.locator('input[name^="Form_DEF_UBBiconNote"]').count()} fields`);
  await f.fill(want);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(900);
  await goTo(p, url);
  rec('UBBiconSetup saves an emoticon note',
      (await p.locator('input[name="Form_DEF_UBBiconNote0"]').first().inputValue()) === want);
  const gen = await httpGet(p, '/test/browser/helpers/f.asp?path=inc/UBBicon_Setup.ASP');
  rec('UBBiconSetup rewrites inc/UBBicon_Setup.ASP',
      gen.status === 200 && gen.body.includes(want), `HTTP ${gen.status}`);
  await goTo(p, url);
  await p.locator('input[name="Form_DEF_UBBiconNote0"]').first().fill(original);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(700);
  await goTo(p, url);
  rec('the emoticon note is restored',
      (await p.locator('input[name="Form_DEF_UBBiconNote0"]').first().inputValue()) === original);
}

// ------------------------------------------------ 重新统计 (RepairSite)
{
  await goTo(p, `${B}/manage/SiteManage/RepairSite.asp`);
  await p.locator('input[name="repairFlag"]').first().check({ force: true }).catch(()=>{});
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
    p.locator('form').first().locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1500);
  const txt = await p.locator('body').innerText();
  rec('RepairSite runs and reports what it recounted', /完成|修复|统计/.test(txt),
      txt.replace(/\s+/g, ' ').slice(0, 70));
  // the whole point: leadbbs_siteinfo's cached counters now agree with the tables
  const users = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  const stored = await dbNum(p, 'SELECT UserCount FROM leadbbs_siteinfo');
  rec('RepairSite writes the true user count into leadbbs_siteinfo', stored === users,
      `siteinfo=${stored} users=${users}`);
}

// ------------------------------------------------ 总固顶 (action=AllTopAnc) then clear it
{
  const topic = await dbOne(p,
    'SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 1');
  await goTo(p, `${B}/a/a.asp?B=100&ID=${topic}`);
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_topannounce');
  const r = await ajaxCommand(p, `a[onclick*="'AllTopAnc&b=100&ID=${topic}'"]`);
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_topannounce');
  rec('action=AllTopAnc makes the topic a site-wide sticky', after === before + 1,
      `${r}: leadbbs_topannounce ${before} -> ${after}`);

  // and 区固顶 — the same verb with part=1. Re-open the topic first: the layer the previous
  // command opened is still in the DOM, and a_command() re-uses it, so clicking the second
  // link without a fresh page can match the stale one and never see a new confirm form.
  await goTo(p, `${B}/a/a.asp?B=100&ID=${topic}`);
  const r2 = await ajaxCommand(p, `a[onclick*="'AllTopAnc&b=100&ID=${topic}&part=1'"]`);
  const after2 = await dbNum(p, 'SELECT count(*) FROM leadbbs_topannounce');
  rec('action=AllTopAnc&part=1 adds the section sticky too', after2 > after,
      `${r2}: ${after} -> ${after2}`);

  // clear them all from the admin panel
  await goTo(p, `${B}/manage/SiteManage/DeleteAllTopAnnounce.asp`);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('form').first().locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1200);
  const cleared = await dbNum(p, 'SELECT count(*) FROM leadbbs_topannounce');
  rec('DeleteAllTopAnnounce clears every site-wide sticky', cleared === 0,
      `leadbbs_topannounce now has ${cleared} rows`);

  // the second form only re-reads the (now empty) data — it must not error
  await goTo(p, `${B}/manage/SiteManage/DeleteAllTopAnnounce.asp`);
  const forms = p.locator('form');
  if (await forms.count() > 1) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      forms.nth(1).locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(900);
  }
  const txt = await p.locator('body').innerText();
  rec('the "reload sticky data" button re-reads the (now empty) sticky list',
      txt.includes('总固顶信息完成更新') && !/error/i.test(txt),
      txt.replace(/\s+/g,' ').slice(0, 60));
}

await br.close();
process.exit(summary('16-adminsetup') ? 0 : 1);
