// 05 — post moderation driven entirely through the real topic-page UI.
//
// Every action here is a two-step AJAX flow: the menu link calls a_command(), which
// fetches a CONFIRM FORM from Processor.asp into a floating layer; only submitting that
// form performs the action. Each check asserts the row the action was supposed to change.
import { B, rec, summary, browser, login, db, dbNum, dbOne, dbRows, ajaxCommand, reveal,
         pinCaptcha, setEditorContent } from './lib.mjs';

const br = await browser();
const p = await login(br);

// distinct topics so the actions can't mask each other
const me = await dbOne(p, "SELECT ID FROM leadbbs_user WHERE UserName='admin'");
const tops = (await dbRows(p, 'SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 ORDER BY ID DESC LIMIT 8')).map(r => r[0]);
const [tTop, tPin, tLock, tMove, tMirror, tRepair] = tops;
// LeadBBS refuses 评帖 on your own post ("不能评价自己发表的帖子"), so rate someone else's
// ...and one nobody has rated yet: the rating is aggregated into leadbbs_announce.Opinion and
// LeadBBS refuses a second one from the same user, so a post that already carries an Opinion
// cannot prove that rating it changes anything.
const tGood = await dbOne(p, `SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100
    AND UserID<>${me} AND ifnull(Opinion,'')='' ORDER BY ID DESC LIMIT 1`);
const open = async id => p.goto(`${B}/a/a.asp?B=100&ID=${id}`, { waitUntil: 'domcontentloaded' });

// --- 提升主题 (Top): the topic jumps to the head of the board order ---
{
  const maxRoot = await dbNum(p, 'SELECT max(RootID) FROM leadbbs_announce WHERE BoardID=100 AND ParentID=0 AND RootID<99999999');
  await open(tTop);
  const r = await ajaxCommand(p, `a[onclick*="'Top&b=100&ID=${tTop}"]`);
  const after = await dbNum(p, `SELECT RootID FROM leadbbs_announce WHERE ID=${tTop}`);
  rec('提升 (Top) moves the topic to the head of the board', after > maxRoot, `${r}: RootID ${after} > previous max ${maxRoot}`);
}

// --- 版面固顶 (TopAnc): RootID moves into the sticky range ---
{
  // 固顶 is a TOGGLE, so read the state first: a topic left pinned by an interrupted run
  // would otherwise make this assert the two halves in the wrong order.
  const PIN = 99999999;
  const start = await dbNum(p, `SELECT RootID FROM leadbbs_announce WHERE ID=${tPin}`);
  await open(tPin);
  const r = await ajaxCommand(p, `a[onclick*="'TopAnc&b=100&ID=${tPin}"]`);
  const after = await dbNum(p, `SELECT RootID FROM leadbbs_announce WHERE ID=${tPin}`);
  rec("版面固顶 (TopAnc) flips the topic's pinned state", (start > PIN) !== (after > PIN),
      `${r}: RootID ${start} -> ${after} (pinned ${start > PIN} -> ${after > PIN})`);
  // and back again through the same link
  await open(tPin);
  await ajaxCommand(p, `a[onclick*="'TopAnc&b=100&ID=${tPin}"]`);
  const back = await dbNum(p, `SELECT RootID FROM leadbbs_announce WHERE ID=${tPin}`);
  rec('版面固顶 toggles back to where it started', (back > PIN) === (start > PIN),
      `RootID=${back} (pinned ${back > PIN}, started ${start > PIN})`);
}

// --- 评帖 (MakeGood): mark as 精华 / record an opinion ---
if (!tGood) {
  rec('评帖 (MakeGood) records the rating on the post', false, 'no post by another user to rate');
} else {
  const before = await dbOne(p, `SELECT concat(GoodFlag,'/',ifnull(Opinion,'')) FROM leadbbs_announce WHERE ID=${tGood}`);
  await open(tGood);
  // the confirm form refuses with "评价必须选择评分" unless a score is chosen, and both of its
  // selects default to 0
  const r = await ajaxCommand(p, `a[onclick*="'MakeGood&b=100&ID=${tGood}"]`,
    { Form_GoodType: 2, Form_OpinionWhys: 'browser test',
      Form_OpinionNum: 1, Form_AddPoints: 1 });
  const after = await dbOne(p, `SELECT concat(GoodFlag,'/',ifnull(Opinion,'')) FROM leadbbs_announce WHERE ID=${tGood}`);
  rec('评帖 (MakeGood) records the rating on the post', after !== before, `${r}: [${before}] -> [${after}]`);
}

// --- 管理/TypeSet with DoingFlag=1: lock the topic (NotReplay) ---
{
  const before = await dbNum(p, `SELECT NotReplay FROM leadbbs_announce WHERE ID=${tLock}`);
  await open(tLock);
  const r = await ajaxCommand(p, `a[onclick*="'TypeSet&b=100&ID=${tLock}"]`, { DoingFlag: 1 });
  const after = await dbNum(p, `SELECT NotReplay FROM leadbbs_announce WHERE ID=${tLock}`);
  rec('管理 (TypeSet) locks the topic against replies', after !== before, `${r}: NotReplay ${before} -> ${after}`);
}

// --- 转移主题 (Move) to the recycle board 444 ---
{
  await open(tMove);
  const r = await ajaxCommand(p, `a[onclick*="'Move&b=100&ID=${tMove}"]`, { BoardID2: '444' });
  const after = await dbNum(p, `SELECT BoardID FROM leadbbs_announce WHERE ID=${tMove}`);
  rec('转移 (Move) moves the topic to another board', after === 444, `${r}: BoardID -> ${after}`);
}

// --- 镜像主题 (mirror): copy into another board, original stays ---
{
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce WHERE BoardID=444');
  await open(tMirror);
  const r = await ajaxCommand(p, `a[onclick*="'mirror&b=100&ID=${tMirror}"]`, { BoardID2: '444' });
  const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce WHERE BoardID=444');
  const orig = await dbNum(p, `SELECT BoardID FROM leadbbs_announce WHERE ID=${tMirror}`);
  rec('镜像 (mirror) copies the topic and keeps the original', after > before && orig === 100,
      `${r}: board444 ${before}->${after}, original still on ${orig}`);
}

// --- 修复 (Repair): recompute the topic's cached child counters ---
{
  await open(tRepair);
  const r = await ajaxCommand(p, `a[onclick*="'Repair&b=100&ID=${tRepair}"]`);
  const stored = await dbNum(p, `SELECT ChildNum FROM leadbbs_announce WHERE ID=${tRepair}`);
  const real = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE ParentID=${tRepair}`);
  rec('修复 (Repair) leaves the cached reply counter consistent', stored === real, `${r}: ChildNum=${stored}, actual replies=${real}`);
}

// --- batch delete: tick a post checkbox, then use the 批量删除 link ---
{
  // Bring our own reply. 01-core creates exactly one per run and 04-admin deletes it again,
  // and this suite's own batch delete removes it too — so it cannot assume one is lying
  // around. It used to work only because years of old test replies had piled up, and it
  // started failing the moment those were cleaned out.
  if ((await dbNum(p, 'SELECT count(*) FROM leadbbs_announce WHERE ParentID>0')) === 0) {
    // not a poll (the ballot replaces the reply furniture) and not one locked against replies
    const host = await dbOne(p,
      'SELECT ID FROM leadbbs_announce WHERE ParentID=0 AND BoardID=100 AND PollNum=0 ' +
      'AND NotReplay=0 AND TopicType=0 ORDER BY ID DESC LIMIT 1');
    await pinCaptcha(p);
    await p.goto(`${B}/a/a2.asp?B=100&ID=${host}`, { waitUntil: 'domcontentloaded' });
    await p.fill('input[name="Form_Title"]', 'Re batch fixture').catch(()=>{});
    await setEditorContent(p, 'reply created so the batch-select check has a post to tick');
    await p.fill('input[name="ForumNumber"]', '1234').catch(()=>{});
    await Promise.all([
      p.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(()=>{}),
      p.locator('input[type="submit"]').first().click({ force: true }).catch(()=>{}),
    ]);
    await p.waitForTimeout(2500);
  }
  const rid = await dbOne(p, 'SELECT ID FROM leadbbs_announce WHERE ParentID>0 ORDER BY ID ASC LIMIT 1');
  rec('a reply exists to batch-select', !!rid, rid ? `reply ${rid}` : 'the fixture reply was not created');
  const pid = await dbOne(p, `SELECT ParentID FROM leadbbs_announce WHERE ID=${rid}`);
  const before = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
  await open(pid);
  const cb = p.locator(`input[name="ids"][value="${rid}"]`).first();
  const have = await p.locator(`input[name="ids"][value="${rid}"]`).count() > 0;
  rec('per-post batch-select checkbox carries the post id', have, `ids=${rid}`);
  if (have) {
    await reveal(cb);
    await cb.check({force:true});                       // delbody_view() opens the batch layer
    await p.waitForTimeout(1200);
    const r = await ajaxCommand(p, 'a[onclick*="p_getselected()"]');
    const after = await dbNum(p, 'SELECT count(*) FROM leadbbs_announce');
    const gone = await dbNum(p, `SELECT count(*) FROM leadbbs_announce WHERE ID=${rid}`);
    rec('批量删除 (batch delete) removes the selected post', after < before && gone === 0,
        `${r}: announce ${before}->${after}, row ${rid} gone=${gone === 0}`);
  }
}

await br.close();
process.exit(summary('05-moderation') ? 0 : 1);
