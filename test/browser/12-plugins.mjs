// 12 — the plug-ins, which until now had only ever been checked with curl ("the page
// returns 200"). Chat state lives in Application rather than the database, so the honest
// equivalent of a row assertion is the plug-in's own dump page plus a SECOND logged-in
// session actually receiving the message — which is exactly what a curl check cannot do.
import { B, rec, summary, browser, login, adminPage, db, dbNum, dbOne,
         httpGet, httpPost, reveal } from './lib.mjs';

const br = await browser();
const p = await login(br);
const stamp = Date.now().toString().slice(-6);

// ------------------------------------------------- flash_gold (revived, README §4/§9)
{
  await p.goto(`${B}/plug-ins/flash_gold/default.asp`, { waitUntil: 'domcontentloaded' });
  // Ruffle fetches ~14 MB of uncompressed wasm before it can paint; wait for the canvas
  // it creates rather than guessing a timeout.
  await p.waitForSelector('canvas', { timeout: 60000 }).catch(() => {});

  const rp = await p.evaluate(() => ({
    global: typeof window.RufflePlayer,
    players: document.querySelectorAll('ruffle-player, ruffle-embed, ruffle-object').length,
    movie: (document.querySelector('ruffle-embed, ruffle-object, ruffle-player') || {})
             .getAttribute?.('src') || '',
  }));
  rec('Ruffle replaces the Flash object and starts a player', rp.global === 'object' && rp.players > 0,
      `RufflePlayer=${rp.global}, ${rp.players} player(s)`);
  const canvases = await p.locator('canvas').count();   // locators pierce the shadow root
  rec('the game canvas renders', canvases > 0, `${canvases} canvas`);
  rec('the SWF keeps its username flashvar', /a\.swf\?username=admin/.test(rp.movie), rp.movie || '(none)');

  // the score path: exactly the POST the SWF's LoadVars.sendAndLoad makes
  const before = await dbNum(p, 'SELECT count(*) FROM plug_flash_gold');
  const score = 1000 + (Number(stamp) % 8000);
  const r = await httpPost(p, '/plug-ins/flash_gold/default.asp?rand=0.5',
    `userid=admin&username=admin&score=${score}&gamename=single`);
  const stored = await dbOne(p, "SELECT points FROM plug_flash_gold WHERE username='admin'");
  rec('submitting a score writes the MariaDB row', r.status === 200 && Number(stored) > 0,
      `HTTP ${r.status}, rows ${before}->${await dbNum(p, 'SELECT count(*) FROM plug_flash_gold')}, points=${stored}`);

  const ts = await dbOne(p, "SELECT recordtime FROM plug_flash_gold WHERE username='admin'");
  rec('the timestamp is a plain 14-digit value, not scientific notation', /^\d{14}$/.test(ts || ''), ts);

  await p.goto(`${B}/plug-ins/flash_gold/default.asp`, { waitUntil: 'domcontentloaded' });
  const body = (await p.locator('body').innerText()).replace(/\s+/g, ' ');
  rec('the leaderboard renders the stored score', body.includes(String(stored)) && body.includes('分数排名'),
      `points ${stored} listed`);
}

// ------------------------------------------------------------------ bbschat
{
  // Navigate away from flash_gold first: Ruffle keeps a wasm VM running, and on a small
  // box that starves the chat polls enough to trip their timeout.
  await p.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });

  // the chat page starts polling at once, so networkidle never fires here
  await p.goto(`${B}/plug-ins/bbschat/Default.asp`, { waitUntil: 'domcontentloaded' });
  await p.waitForTimeout(2000);
  const chatUI = await p.locator('#mesForm, #input').count() > 0;
  rec('chat page gives a logged-in user the compose form', chatUI);

  if (chatUI) {
    const MARK = 'CHATMARK' + stamp;

    // Register the RECEIVER first. The world ring hands each session a cursor at the point
    // it joined, so a session that arrives after the send legitimately sees nothing.
    const p2 = await login(br, 'testuser001', 'Test123456');
    await p2.goto(`${B}/plug-ins/bbschat/Default.asp`, { waitUntil: 'domcontentloaded' });
    await p2.waitForTimeout(2000);
    // The chat client polls on the page's own JS thread; leaving that page open makes our
    // evaluate()-based polls queue behind it. The session keeps its chat registration, so
    // move to a quiet page and poll from there.
    await p2.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
    await httpPost(p2, '/plug-ins/bbschat/Chat_IO.asp', 'user=' + encodeURIComponent('testuser001'));

    await p.fill('#input', MARK);
    const sendBtn = p.locator('input[type="button"][value="发送"], #mesForm input[type="button"]').first();
    if (await sendBtn.count()) { await reveal(sendBtn); await sendBtn.click({ force: true }); }
    await p.waitForTimeout(2500);

    // Delivery is asserted below, through the real poll endpoint, from the OTHER session --
    // which is the only observation that proves the message reached the shared world ring.
    // (This used to read plug-ins/bbschat/test_list.asp, an upstream scratch page that dumped
    // the entire server-global chat ring to any anonymous visitor. It is deleted from this
    // distribution; 22-misc asserts it is gone.)
    // the second session must now receive it through the real poll endpoint
    // the real client polls on a timer, so poll a few times before concluding
    let poll = { status: 0, body: '' };
    for (let i = 0; i < 6 && !poll.body.includes(MARK); i++) {
      await p2.waitForTimeout(2000);
      const r = await httpPost(p2, '/plug-ins/bbschat/Chat_IO.asp', 'user=' + encodeURIComponent('testuser001'));
      if (r.body.trim()) poll = r;
    }
    rec('a second session receives the message through the poll', poll.body.includes(MARK),
        `poll ${poll.status}, ${poll.body.replace(/\s+/g, ' ').slice(0, 60) || '(empty)'}`);

    const again = await httpPost(p2, '/plug-ins/bbschat/Chat_IO.asp', 'user=' + encodeURIComponent('testuser001'));
    rec('the poll cursor advances (no duplicate delivery)', !again.body.includes(MARK),
        `second poll: ${again.body.trim().slice(0, 30) || '(empty)'}`);

  // a guest must NOT get it. Chat_IO.asp is a long-poll — never NAVIGATE to it (the page
    // would block); post to it from a page that already has this origin.
    const gctx = await br.newContext();
    const gp = await gctx.newPage();
    await gp.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
    const gr = await httpPost(gp, '/plug-ins/bbschat/Chat_IO.asp', 'user=admin').catch(() => ({ body: '' }));
    // refused either as "9 guest" (no session at all) or "9 stop" (session/user mismatch)
    rec('the chat poll refuses a guest', /guest|stop/.test(gr.body), (gr.body || '').trim().slice(0, 20) || '(empty)');
    await gctx.close();

    // wrong-session poll must be rejected
    const wrong = await httpPost(p, '/plug-ins/bbschat/Chat_IO.asp', 'user=' + encodeURIComponent('testuser001'));
    rec('polling another user’s channel is rejected', /stop|guest/.test(wrong.body),
        wrong.body.trim().slice(0, 20));
    await p2.context().close();
  }
}

// --------------------------------------------------------------- HomePageStar
{
  // HomePageStar.asp is an #include that defines LeadBBSHomePageStar(); Boards.asp:201 calls
  // it. Fetching the include directly returns 0 bytes — assert the box it actually draws.
  await p.goto(`${B}/Boards.asp`, { waitUntil: 'domcontentloaded' });
  const html = await p.content();
  rec('HomePageStar draws its box on the board index',
      html.includes('bstar') && /明星|之星/.test(html), 'bstar block present');
}

// ------------------------------------------------------------------- LeadCard
{
  // unlock on a throwaway tab: the manage frameset wedges whichever tab submits it
  const { page: ap } = await adminPage(br);
  await ap.goto(`${B}/plug-ins/LeadCard/default.asp?act=1`, { waitUntil: 'domcontentloaded' }).catch(()=>{});
  const hasForm = await ap.locator('form input[type="submit"], form input[type="text"]').count() > 0;
  rec('LeadCard admin page renders a form', hasForm, ap.url().replace(B, ''));
}

await br.close();
process.exit(summary('12-plugins') ? 0 : 1);
