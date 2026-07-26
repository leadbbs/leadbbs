// 15 — 站点管理 (manage/SiteManage): the half of the admin panel no suite had ever opened.
//
// Every check here drives the real form and then asserts what a HUMAN would see afterwards:
// the value that comes back when the page is reloaded, and — where the setting is supposed to
// change the public site — the forum page that is supposed to change.
//
// Verbs driven end to end: SiteInfo's action=MoreSV / Side / admanage / SiteMap.
import { B, rec, summary, browser, adminPage, db, dbNum, dbOne,
         httpGet, goTo, reveal } from './lib.mjs';
import { writeFileSync, statSync } from 'fs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin backend unlocked', adminOk);
const stamp = Date.now().toString().slice(-6);
const SI = `${B}/manage/SiteManage/SiteInfo.asp`;

// ------------------------------------------------ 论坛信息一览: the numbers must be real
{
  await goTo(p, SI);
  const txt = await p.locator('body').innerText();
  const users = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  const m = txt.match(/网站用户:\s*(\d+)\s*人/);
  rec('SiteInfo reports the real registered-user count',
      !!m && parseInt(m[1], 10) === users, `page=${m ? m[1] : 'none'} db=${users}`);
  rec('SiteInfo renders its repair links',
      (await p.locator('a[href="RepairSite.asp"]').count()) > 0 &&
      (await p.locator('a[href="DeleteAllTopAnnounce.asp"]').count()) > 0);
}

// ------------------------------------------------ action=info  (the panel the frameset opens)
{
  await goTo(p, `${B}/manage/Default.asp?action=info`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  const users = await dbNum(p, 'SELECT count(*) FROM leadbbs_user');
  rec('action=info renders the 论坛信息一览 panel',
      txt.includes('论坛信息一览') && txt.includes('服务端软件'), txt.slice(0, 60));
  rec('and it reports the running engine, address and server, not blanks',
      /解释引擎：\S/.test(txt) && /您的IP地址：\d/.test(txt) && txt.includes('AxonASP'),
      (txt.match(/解释引擎：[^ ]*/) || [''])[0]);
  // the component report behind 点击查看组件安装情况
  await goTo(p, `${B}/manage/Default.asp?need=1773`);
  const comp = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the component report says what this deployment actually has',
      comp.includes('FSO文本读写') && comp.includes('数据库使用') && comp.includes('Jmail'),
      comp.slice(0, 70));
}

// ------------------------------------------------ action=upload  (replace a site image)
// The style-preview thumbnail is the safest target: nothing depends on its content. The
// original bytes are downloaded first and put back at the end, so the site is unchanged.
{
  const target = 'images/style/preview/style0.jpg';
  const orig = await fetch(`${B}/${target}`).then(r => r.ok ? r.arrayBuffer() : null).catch(()=>null);
  rec('the image about to be replaced is downloadable first', !!orig && orig.byteLength > 0,
      orig ? `${orig.byteLength} bytes` : 'not fetched');
  if (orig) {
    writeFileSync('/tmp/style0_orig.jpg', Buffer.from(orig));
    // a 1x1 JPEG that is unmistakably not the original
    writeFileSync('/tmp/style0_probe.jpg', Buffer.from(
      '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0a' +
      'HBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA/8QAFAABAAAAAAAA' +
      'AAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AKp//2Q==', 'base64'));

    const url = `${B}/manage/SiteManage/SiteInfo.asp?action=upload` +
                `&p_filepath=images/style/preview/&p_filename=style0.jpg&p_fileinfo=probe`;
    await goTo(p, url);
    rec('action=upload renders the replace-this-file form',
        (await p.locator('input[type="file"]').count()) > 0 &&
        (await p.locator('input[name="p_filename"]').count()) > 0);
    await p.setInputFiles('input[type="file"]', '/tmp/style0_probe.jpg').catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1800);
    const now = await fetch(`${B}/${target}?x=${stamp}`).then(r => r.arrayBuffer()).catch(()=>null);
    // compare against the probe's own size, not merely "different from before": if a previous
    // run had failed to restore, "before" would already be the probe and != would pass wrongly
    const probeLen = statSync('/tmp/style0_probe.jpg').size;
    rec('action=upload really replaces the file a visitor downloads',
        !!now && now.byteLength === probeLen,
        `${orig.byteLength} bytes -> ${now ? now.byteLength : '?'} bytes (probe is ${probeLen})`);

    // put the original back through the same form
    await goTo(p, url);
    await p.setInputFiles('input[type="file"]', '/tmp/style0_orig.jpg').catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 60000 }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(1800);
    const back = await fetch(`${B}/${target}?y=${stamp}`).then(r => r.arrayBuffer()).catch(()=>null);
    rec('and the original image is restored byte-for-byte',
        !!back && back.byteLength === orig.byteLength,
        `${back ? back.byteLength : '?'} vs ${orig.byteLength} bytes`);
  }
}

// ------------------------------------------------ action=MoreSV  (论坛扩展服务)
{
  await goTo(p, `${SI}?action=MoreSV`);
  const txt = await p.locator('body').innerText();
  rec('action=MoreSV renders the extended-service panel',
      txt.includes('论坛扩展服务') && txt.includes('状态'),
      txt.replace(/\s+/g, ' ').slice(0, 60));
  rec('action=MoreSV offers the activation link',
      (await p.locator('a[href*="SV=counter"]').count()) > 0);
}

// ------------------------------------------------ action=Side  (首页边栏设置)
// The sidebar config is a 16-row form; rename row 0 and prove the rename survives a reload.
{
  await goTo(p, `${SI}?action=Side`);
  const title0 = p.locator('input[name="Title0"]').first();
  const had = (await title0.count()) > 0;
  rec('action=Side renders the sidebar configuration form', had);
  if (had) {
    const original = await title0.inputValue();
    // Side_UpdateFormData only saves a row whose Side_Select checkbox is ticked — an
    // unticked row means "do not show this column", so filling the title alone is a no-op.
    const chk = p.locator('input[name="Side_Select0"]').first();
    const wasChecked = await chk.isChecked().catch(() => false);
    const want = `Side${stamp}`;
    await chk.check({ force: true }).catch(()=>{});
    await title0.fill(want);
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      p.locator('form[action*="action=Side"] input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(800);
    await goTo(p, `${SI}?action=Side`);
    const now = await p.locator('input[name="Title0"]').first().inputValue();
    rec('action=Side saves the sidebar title', now === want, `reloaded as "${now}"`);

    // The sidebar the forum home renders comes from a generated include chain
    // (Side_UpdateFileData writes inc/IncHtm/Boards_Side_Setup.asp, which Boards.asp includes
    // to build inc/IncHtm/Boards_Side.asp). README §31 — the bytecode cache never notices a
    // changed include — so the rendered page cannot show it until a restart. Assert on the row
    // the save wrote and on the include it regenerated, which is the whole of what it controls.
    const row = await dbOne(p,
      `SELECT ValueStr FROM leadbbs_setup WHERE RID=1000 AND ValueStr LIKE '1|%'`);
    rec('action=Side stores the column in leadbbs_setup', row.includes(want), row || '(no row)');
    const side = await httpGet(p, '/test/browser/helpers/f.asp?path=inc/IncHtm/Boards_Side_Setup.asp');
    rec('the renamed column is written into the generated home-sidebar include',
        side.status === 200 && side.body.includes(want),
        `HTTP ${side.status}, ${side.body.length} bytes`);

    // put it back so the site reads normally for anyone looking at it later
    await goTo(p, `${SI}?action=Side`);
    await p.locator('input[name="Title0"]').first().fill(original);
    const chk2 = p.locator('input[name="Side_Select0"]').first();
    if (wasChecked) await chk2.check({ force: true }).catch(()=>{});
    else await chk2.uncheck({ force: true }).catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      p.locator('form[action*="action=Side"] input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(600);
    await goTo(p, `${SI}?action=Side`);
    rec('the sidebar title is restored',
        (await p.locator('input[name="Title0"]').first().inputValue()) === original);
  }
}

// ------------------------------------------------ action=admanage  (综合广告栏管理)
// SaveData0 is the 首页-顶部 ad slot: whatever HTML goes in must come out on the forum home.
{
  await goTo(p, `${SI}?action=admanage`);
  const box = p.locator('textarea[name="SaveData0"]').first();
  const had = (await box.count()) > 0;
  rec('action=admanage renders the six ad slots',
      had && (await p.locator('textarea[name^="SaveData"]').count()) === 6,
      `${await p.locator('textarea[name^="SaveData"]').count()} slots`);
  if (had) {
    const marker = `<b id="admk">AD-${stamp}</b>`;
    await box.fill(marker);
    await p.locator('input[name="Side_Select0"]').first().check({ force: true }).catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      p.locator('form[action*="admanage"] input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(900);
    await goTo(p, `${SI}?action=admanage`);
    const back = await p.locator('textarea[name="SaveData0"]').first().inputValue();
    rec('action=admanage stores the ad code', back.includes(`AD-${stamp}`), back.slice(0, 40));

    // the point of an ad slot is that it renders — check the element is really in the home page
    await goTo(p, `${B}/Boards.asp`);
    const shown = await p.locator('#admk').count() > 0
      ? await p.locator('#admk').first().innerText() : '';
    rec('the ad code renders on the forum home page', shown.includes(`AD-${stamp}`),
        shown || 'not found in Boards.asp');

    // clear it again
    await goTo(p, `${SI}?action=admanage`);
    await p.locator('textarea[name="SaveData0"]').first().fill('');
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      p.locator('form[action*="admanage"] input[type="submit"]').first().click({ force: true }),
    ]);
    await p.waitForTimeout(600);
    await goTo(p, `${B}/Boards.asp`);
    rec('the ad slot is empty again', (await p.locator('#admk').count()) === 0);
  }
}

// ------------------------------------------------ action=SiteMap
{
  await goTo(p, `${SI}?action=SiteMap`);
  const txt = await p.locator('body').innerText();
  const m = txt.match(/约有(\d+)帖子记录/);
  const roots = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce WHERE ParentID=0');
  rec('action=SiteMap counts the topics it would emit',
      !!m && parseInt(m[1], 10) === roots, `page=${m ? m[1] : 'none'} db(root posts)=${roots}`);
  rec('action=SiteMap links to the generator',
      (await p.locator('a[href*="UpdateUnderWritePrintColumn.asp"]').count()) > 0);
}

// ------------------------------------------------ 友情链接 (SiteLink) + 广告 (SiteLink_Flag=10)
{
  const url = `${B}/manage/SiteManage/SiteLink.asp`;
  await goTo(p, url);
  const name = `LK${stamp}`;
  await p.locator('input[name="SiteName1"]').first().fill(name);
  await p.locator('input[name="SiteUrl1"]').first().fill('http://example.com/');
  await p.locator('input[name="OrderID1"]').first().fill('1');
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(900);
  await goTo(p, url);
  const back = await p.locator('input[name="SiteName1"]').first().inputValue();
  rec('SiteLink saves a friend link', back === name, `reloaded as "${back}"`);
  const row = await dbOne(p, `SELECT count(*) FROM leadbbs_link WHERE SiteName='${name}'`);
  rec('the friend link is a real leadbbs_link row', row === '1', `count=${row}`);

  // SiteLink's real output is a generated ASP include the public pages pull in. Fetching it
  // over HTTP would EXECUTE it (and it emits nothing), so read its source through the
  // loopback file helper — that is the artefact a reader of the site ends up seeing.
  const gen = await httpGet(p, '/test/browser/helpers/f.asp?path=inc/IncHtm/BoardLink.asp');
  rec('the link is written into the generated BoardLink include',
      gen.status === 200 && gen.body.includes(name),
      `HTTP ${gen.status}, ${gen.body.length} bytes`);

  // remove it again (blank name = delete, per the page's own instructions)
  await goTo(p, url);
  await p.locator('input[name="SiteName1"]').first().fill('');
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(700);
  const gone = await dbOne(p, `SELECT count(*) FROM leadbbs_link WHERE SiteName='${name}'`);
  rec('blanking the name deletes the friend link', gone === '0', `count=${gone}`);

  await goTo(p, `${url}?SiteLink_Flag=10`);
  const txt = await p.locator('body').innerText();
  rec('SiteLink_Flag=10 switches the same page to the advert list',
      txt.includes('修改广告') && (await p.locator('input[name="SiteName1"]').count()) > 0,
      txt.replace(/\s+/g,' ').slice(0, 40));
}

// ------------------------------------------------ 论坛空间占用情况 (Space)
{
  await goTo(p, `${B}/manage/SiteManage/Space.asp`);
  const txt = await p.locator('body').innerText();
  const listed = (txt.match(/占用空间/g) || []).length;
  const tables = await dbNum(p,
    "SELECT count(*) FROM information_schema.tables WHERE table_schema='leadbbs'");
  rec('Space lists every table in the database', listed >= tables && txt.includes('leadbbs_announce'),
      `page listed ${listed}, information_schema says ${tables}`);
}

// ------------------------------------------------ 关闭/开启论坛 (SiteOpenClose)
// The most destructive switch on the page: it takes the whole forum offline for guests.
{
  const url = `${B}/manage/SiteManage/SiteOpenClose.asp`;
  await goTo(p, `${url}?Flag=close`);
  await p.waitForTimeout(400);
  const form = p.locator('input[type="submit"]').first();
  if (await form.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      form.click({ force: true }),
    ]);
    await p.waitForTimeout(900);
  }
  // a logged-OUT visitor must now be told the forum is closed
  const guest = await br.newContext();
  const gp = await guest.newPage();
  await gp.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' }).catch(()=>{});
  await gp.waitForTimeout(500);
  const gtxt = await gp.locator('body').innerText().catch(()=>'');
  const closed = /关闭|维护|暂停/.test(gtxt);
  rec('closing the forum shows guests the closed notice', closed,
      gtxt.replace(/\s+/g, ' ').slice(0, 70));

  await goTo(p, `${url}?Flag=open`);
  await p.waitForTimeout(400);
  const f2 = p.locator('input[type="submit"]').first();
  if (await f2.count()) {
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
      f2.click({ force: true }),
    ]);
    await p.waitForTimeout(900);
  }
  await gp.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' }).catch(()=>{});
  await gp.waitForTimeout(500);
  const gtxt2 = await gp.locator('body').innerText().catch(()=>'');
  rec('re-opening the forum restores the board list for guests',
      !/关闭|维护|暂停/.test(gtxt2) && gtxt2.length > 200,
      gtxt2.replace(/\s+/g, ' ').slice(0, 70));
  await guest.close();
}

await br.close();
process.exit(summary('15-adminsite') ? 0 : 1);
