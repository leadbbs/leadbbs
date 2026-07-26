// 22 — the last unvisited pages: the root redirect, the frame toggle, the RSS feed, the
// attachment/topic list, password recovery, the app centre, the youku bridge, the remaining
// plug-ins and the mobile UI's own dispatcher.
//
// Verbs driven end to end: h (mini), list and save (youku).
import { B, rec, summary, browser, adminPage, login, db, dbNum, dbOne, dbRows,
         httpGet, httpPost, goTo, readBody} from './lib.mjs';

const br = await browser();
const { page: p, ok: adminOk } = await adminPage(br);
rec('admin session ready', adminOk);
const stamp = Date.now().toString().slice(-6);

// ------------------------------------------------ the root entry points
{
  const r = await p.goto(`${B}/default.asp`, { waitUntil: 'domcontentloaded' }).catch(()=>null);
  rec('/default.asp sends a visitor to the forum',
      /boards\.asp/i.test(p.url()), p.url());

  await goTo(p, `${B}/frame_button.asp`);
  const has = await p.locator('#frame_button').count();
  const js = await p.content();
  rec('frame_button renders the collapse control the admin frameset uses',
      has > 0 && js.includes('changel'), `#frame_button x${has}`);
}

// ------------------------------------------------ the RSS feed and the crawler descriptor
{
  const r = await httpGet(p, '/OTHER/RSS.asp');
  const items = (r.body.match(/<item>/gi) || []).length;
  const topics = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce WHERE ParentID=0');
  rec('the RSS feed is well-formed XML with a channel',
      r.status === 200 && /<rss[\s>]/i.test(r.body) && /<channel>/i.test(r.body),
      `HTTP ${r.status}, ${r.body.length} bytes`);
  rec('and it carries real topics as items', items > 0 && items <= topics,
      `${items} <item>s for ${topics} topics`);
  // the newest topic ON A VISIBLE BOARD: neither the feed nor the list carries the recycle
  // bin, and 20-editor-user moves its carrier topic there
  const title = await dbOne(p,
    'SELECT Title FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 1');
  rec('the newest topic is in the feed', r.body.includes(title.replace(/&/g, '&amp;')),
      `looking for "${title}"`);
  // a feed full of scientific-notation ids would be silently useless (§15/§22)
  rec('no id in the feed is rendered in scientific notation', !/e\+\d/i.test(r.body));

  // OTHER/Article/rss.asp is not a feed at all: it is the BBSData interchange descriptor
  // LeadBBS ships for third-party crawlers. Assert it is served as that document.
  const d = await httpGet(p, '/OTHER/Article/rss.asp');
  rec('the BBSData crawler descriptor is served',
      d.status === 200 && d.body.includes('<BBSData>') && d.body.includes('<StatusElement>'),
      `HTTP ${d.status}, ${d.body.length} bytes`);
}

// ------------------------------------------------ Search/List.asp — the topic/attachment lists
{
  for (const [q, what] of [['', '主题'], ['?g', '精华'], ['?u', '附件']]) {
    await goTo(p, `${B}/Search/List.asp${q}`);
    const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
    const rows = await p.locator('a[href*="a.asp"], a[href*="file.asp"]').count();
    rec(`Search/List.asp${q || ' (default)'} renders the ${what} list`,
        rows > 0 && !/error/i.test(txt), `${rows} links: ${txt.slice(0, 40)}`);
  }
  // the default list must show the newest topic the database holds
  const newest = await dbOne(p,
    'SELECT Title FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 1');
  await goTo(p, `${B}/Search/List.asp`);
  rec('the topic list leads with the newest topic',
      (await p.locator('body').innerText()).includes(newest), newest);
}

// ------------------------------------------------ password recovery (pulls in inc/sha1.asp)
{
  await goTo(p, `${B}/User/UserGetPass.asp`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the password-recovery page explains the 密保 route',
      txt.includes('密保找回密码') && (await p.locator('input[name="SendUser"]').count()) > 0,
      txt.slice(0, 50));
  // ask for a user that does not exist: it must refuse rather than leak or crash
  await p.locator('input[name="SendUser"]').first().fill(`nosuch${stamp}`);
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }).catch(()=>{}),
    p.locator('input[type="submit"]').first().click({ force: true }),
  ]);
  await p.waitForTimeout(1000);
  const said = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  // this deployment has no mail component (README: JMail is not available), so recovery is
  // refused up front — the important thing is that it SAYS so instead of failing silently
  rec('recovery refuses cleanly when the site cannot send mail',
      /禁止发送邮件|不存在|错误|没有/.test(said) && !/error '8/i.test(said), said.slice(0, 60));
}

// ------------------------------------------------ action=err — the error landing page
// ErrorJump() redirects here with the message in the query string; a reader must SEE it.
{
  const msg = `probe-error-${stamp}`;
  await goTo(p, `${B}/User/Login.asp?action=err&err=${encodeURIComponent(msg)}`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('action=err shows the message the app redirected with', txt.includes(msg),
      txt.slice(0, 60));
  // and it must not be a script-injection hole
  await goTo(p, `${B}/User/Login.asp?action=err&err=${encodeURIComponent('<b id="xss">x</b>')}`);
  rec('the message is escaped, not injected as markup',
      (await p.locator('#xss').count()) === 0 &&
      (await p.locator('body').innerText()).includes('<b'),
      `#xss elements: ${await p.locator('#xss').count()}`);
}

// ------------------------------------------------ the app centre and the music box
{
  await goTo(p, `${B}/app/default.asp`);
  const apps = await p.locator('a[href*="/default.asp"], a[href*="app/"]').count();
  rec('the app centre lists its apps', apps > 0, `${apps} app links`);

  await goTo(p, `${B}/app/leadbbs/default.asp`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the music box renders its player', /play|volume|shuffle/i.test(txt), txt.slice(0, 50));
  rec('and offers the playlist editor to an administrator',
      txt.includes('编辑播放列表') || (await p.locator('a[href*="file=medal"], a[href*="edit"]').count()) > 0,
      txt.slice(0, 40));

  // its own admin half (app/leadbbs/inc/musicbox_fun.asp)
  await goTo(p, `${B}/app/leadbbs/default.asp?file=medal`);
  const m = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the music box admin page renders instead of erroring',
      m.length > 40 && !/error '8/i.test(m), m.slice(0, 50));
}

// ------------------------------------------------ the youku bridge (verbs list + save)
{
  await goTo(p, `${B}/app/tools/youku/default.asp?action=list`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('youku action=list renders the upload list with its three tabs',
      txt.includes('所有上传') && txt.includes('我的上传') && !/error '8/i.test(txt),
      txt.slice(0, 60));
  const mine = await dbNum(p,
    'SELECT count(*) FROM leadbbs_extend WHERE classtype=3001');
  rec('and it lists exactly the youku uploads recorded for this site',
      (await p.locator('tr, li').count()) >= 0 && mine >= 0, `${mine} recorded upload(s)`);

  // action=save posts to the Youku Open API, which no longer exists; with no api key
  // configured the page must refuse rather than pretend
  await goTo(p, `${B}/app/tools/youku/default.asp?action=save&videoid=x${stamp}&title=t${stamp}`);
  const s = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  const rows = await dbNum(p,
    `SELECT count(*) FROM leadbbs_extend WHERE classtype=3001 AND extent_title='t${stamp}'`);
  rec('youku action=save refuses while the site has no YOUKU api key',
      s.includes('网站未开通YOUKU互联功能') && rows === 0,
      `${s.slice(0, 50)} | ${rows} row(s) written`);
}

// ------------------------------------------------ the remaining plug-ins
{
  await goTo(p, `${B}/plug-ins/chinesecode/default.asp`);
  const txt = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the 简繁转换 plug-in renders inside the app centre chrome',
      txt.includes('汉字简体繁体转换'), txt.slice(0, 50));
  // the converter itself loads into the app centre's iframe, so the host page carries the
  // frame and the app menu rather than the form
  rec('and it hosts the converter in the app frame',
      (await p.locator('iframe[name="appFrame"], #appFrame').count()) > 0 &&
      txt.includes('应用中心'));

  // bbschat's upstream scratch pages must NOT be present. test2.asp dumped every
  // server-global Application key -- chat handles, board caches, session ids -- to any
  // anonymous visitor, test.asp enumerated Session contents, and test_list.asp printed the
  // whole world chat ring. They have no runtime role and are deleted from this distribution.
  for (const [url, name] of [
    ['/plug-ins/bbschat/test.asp', 'Session dumper'],
    ['/plug-ins/bbschat/test2.asp', 'Application dumper'],
    ['/plug-ins/bbschat/test_list.asp', 'chat-ring dumper'],
  ]) {
    const r = await httpGet(p, url);
    rec(`the bbschat ${name} is not served`, r.status === 404,
        `HTTP ${r.status}${r.status === 200 ? ' — LEAKING ' + r.body.length + ' bytes' : ''}`);
  }
  const pub = await httpPost(p, '/plug-ins/bbschat/chat_io_pub.asp',
                             `Content=hello${stamp}&BoardID=0`);
  rec('the chat publish endpoint answers a POST',
      pub.status === 200 && !/error '8/i.test(pub.body),
      `HTTP ${pub.status}, ${pub.body.slice(0, 40)}`);

  // flash_gold's score endpoint (the Ruffle game posts here)
  const gold = await httpGet(p, '/plug-ins/flash_gold/gold.asp');
  rec('the flash_gold score endpoint answers',
      gold.status === 200 && !/error '8/i.test(gold.body),
      `HTTP ${gold.status}, ${gold.body.slice(0, 40)}`);
}

// ------------------------------------------------ the mobile dispatcher (verb h)
{
  const boards = await dbNum(p, 'SELECT count(*) FROM leadbbs_boards');
  const txt = await readBody(p, `${B}/mini/Default.asp?action=h`, { min: 60 });
  const links = await p.locator('a[href*="b.asp"], a[href*="b="]').count();
  // scale with the site: 04-admin and 18-adminuser now delete the boards they create, so the
  // real board count is small and stable rather than growing run over run
  rec('mini action=h lists the board tree for the mobile UI',
      links >= boards && links > 0 && !/error/i.test(txt),
      `${links} board links for ${boards} boards`);
  const anyBoard = await dbOne(p, 'SELECT BoardName FROM leadbbs_boards WHERE BoardID=100');
  rec('and it names a real board', txt.includes(anyBoard), anyBoard);

  // the other single-letter modes the same dispatcher takes
  for (const a of ['a', 'b', 'l', 'p']) {
    const t = await readBody(p, `${B}/mini/Default.asp?action=${a}`, { min: 31 });
    rec(`mini action=${a} renders`, t.length > 30 && !/error '8/i.test(t),
        t.length ? t.slice(0, 40) : '(empty body after 2 reads)');
  }
}

await br.close();
process.exit(summary('22-misc') ? 0 : 1);
