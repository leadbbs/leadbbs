// 11 — editing and deleting your own content through the real UI: edit a post, and
// delete a private message from the message view.
import { B, rec, summary, browser, login, dbNum, dbOne, currentCaptcha, setEditorContent, reveal } from './lib.mjs';

const br = await browser();
const p = await login(br);
const stamp = Date.now().toString().slice(-6);

// ------------------------------------------------------------- edit a post (UI)
{
  const me = await dbOne(p, "SELECT ID FROM leadbbs_user WHERE UserName='admin'");
  const tid = await dbOne(p, `SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 AND UserID=${me} ORDER BY ID DESC LIMIT 1`);
  const newTitle = 'Edited ' + stamp;
  rec('found an own topic to edit', !!tid, `topic ${tid}`);
  if (tid) {
    // the 编辑 link on the post; then the real edit form
    await p.goto(`${B}/a/a.asp?B=100&ID=${tid}`, { waitUntil: 'domcontentloaded' });
    const link = p.locator(`a[href*="Editannounce.asp"][href*="ID=${tid}"], a[href*="EditAnnounce.asp"][href*="ID=${tid}"]`).first();
    const haveLink = await p.locator(`a[href*="ditannounce.asp"][href*="ID=${tid}"], a[href*="ditAnnounce.asp"][href*="ID=${tid}"]`).count() > 0;
    rec('edit link is present on your own post', haveLink, `ID=${tid}`);
    if (haveLink) {
      await reveal(link);
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
        link.click({ force: true }),
      ]);
    } else {
      await p.goto(`${B}/a/EditAnnounce.asp?b=100&ID=${tid}`, { waitUntil: 'domcontentloaded' });
    }
    const haveForm = await p.locator('input[name="Form_Title"]').count() > 0;
    rec('edit form loads with the post in it', haveForm, p.url().replace(B, ''));
    if (haveForm) {
      await p.fill('input[name="Form_Title"]', newTitle);
      await setEditorContent(p, 'Body rewritten through the browser at ' + stamp);
      const cap = p.locator('input[name="ForumNumber"]');
      if (await cap.count()) await cap.fill(await currentCaptcha(p));
      await Promise.all([
        p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
        p.locator('input[type="submit"], input[type="image"]').first().click({ force: true }),
      ]);
      await p.waitForTimeout(1800);
    }
    const title = await dbOne(p, `SELECT Title FROM leadbbs_announce WHERE ID=${tid}`);
    rec('editing a post rewrites the row', title === newTitle, `title now "${title}"`);

    await p.goto(`${B}/a/a.asp?B=100&ID=${tid}`, { waitUntil: 'domcontentloaded' });
    const shown = (await p.locator('body').innerText()).includes(newTitle);
    rec('edited post shows the new text in the forum UI', shown);
  }
}

// ------------------------------------------------- delete a private message (UI)
{
  // have the other test account send us one, so the suite is self-contained
  const title = 'PMdel ' + stamp;
  const br2 = await browser();
  const p2 = await login(br2, 'testuser001', 'Test123456');
  await p2.goto(`${B}/User/SendMessage.asp?user=admin`, { waitUntil: 'domcontentloaded' });
  await p2.fill('input[name="SdM_ToUser"]', 'admin').catch(()=>{});
  await p2.fill('input[name="SdM_Title"]', title).catch(()=>{});
  await p2.evaluate(t => { const f = document.forms[0];
    if (f.elements['SdM_Content']) f.elements['SdM_Content'].value = 'Message to be deleted, ' + t; }, stamp);
  await Promise.all([
    p2.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
    p2.locator('input[type="submit"]').first().click({ force: true }).catch(()=>{}),
  ]);
  await p2.waitForTimeout(1500);
  await br2.close();

  const mid = await dbOne(p, `SELECT ID FROM leadbbs_infobox WHERE ToUser='admin' AND Title='${title}'`);
  const before = await dbNum(p, "SELECT count(*) FROM leadbbs_infobox WHERE ToUser='admin'");
  rec('a private message arrives in our inbox', !!mid, `message ${mid || 'none'}, ${before} in box`);
  if (mid) {
    await p.goto(`${B}/User/LookMessage.asp?MessageID=${mid}`, { waitUntil: 'domcontentloaded' });
    // 删除短消息 is <a href="javascript:kill(id)"> firing an AJAX delete
    const del = p.locator('a[href^="javascript:kill("]').first();
    const have = await p.locator('a[href^="javascript:kill("]').count() > 0;
    rec('message view offers a delete link', have);
    if (have) {
      await reveal(del);
      await del.click({ force: true });
      await p.waitForTimeout(2500);
    }
    const gone = await dbNum(p, `SELECT count(*) FROM leadbbs_infobox WHERE ID=${mid}`);
    const after = await dbNum(p, "SELECT count(*) FROM leadbbs_infobox WHERE ToUser='admin'");
    rec('deleting a private message removes it', gone === 0 && after < before, `infobox ${before}->${after}`);
  }
}

await br.close();
process.exit(summary('11-editing') ? 0 : 1);
