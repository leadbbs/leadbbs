# The test suite

Real flows driven through **headless Chromium (Playwright)**, clicking the actual forms and
links, with a read-only SQL oracle asserting the row each action was supposed to write.

Playwright is the only evidence this project accepts. A `curl` POST takes a different code path
from a browser's multipart form, and that difference hid a real bug (§20) for weeks. Likewise,
every check asserts something a person could see or a row that must exist — never merely that a
request returned 200, because AxonASP serves runtime errors with HTTP 200.

## Running

```sh
bunx playwright install chromium
bash test/browser/run-all.sh              # all suites, ~40 min
bun test/browser/06-member.mjs            # one suite
```

`run-all.sh` restarts AxonASP between suites. That is not tidiness: a script timeout leaks a
VM-pool slot (§32), so a long run in one process degrades and eventually wedges.

Environment:

| variable | default | meaning |
|---|---|---|
| `LEADBBS_URL` | `http://localhost:9596` | site under test |
| `LEADBBS_ADMIN_USER` | `admin` | admin account |
| `LEADBBS_ADMIN_PASS` | *(install default)* | admin password |
| `LEADBBS_ADMIN_ANSWER` | *(install default)* | security-question answer, needed for `manage/` |

Requires: a running site with MariaDB, board `BoardID=100`, and the admin account above.

## Layout

- `browser/NN-*.mjs` — the suites. Each prints `PASS`/`FAIL` per check and one
  `=== NN-name: X/Y passed ===` line; `run-all.sh` exits non-zero if any suite fails.
- `browser/lib.mjs` — shared harness: `login`, `adminPage`, `ajaxCommand`, `setSelect`,
  `loadCaptcha`, `dbRows`/`dbOne`, plus the verb recorder.
- `browser/helpers/*.asp` — **server-side scaffolding, loopback-gated, dev-only**. Their
  `#include` paths are relative to this directory, so they only work from here: a read-only
  SQL oracle (`q.asp`), a file reader for asserting what the app regenerated (`f.asp`), a
  captcha pin (`setcaptcha.asp`) and a session-code reader (`rndnum.asp`).
- `coverage/` — the census tooling behind the numbers in `docs/coverage-gaps.md`.

> ⚠️ **Delete `test/` on any real deployment.** The helpers refuse non-loopback clients, but
> behind a reverse proxy `REMOTE_ADDR` is the proxy's address and that gate opens. The release
> zip excludes this directory.

## Suites

| suite | covers |
|---|---|
| `01-core` | login, board list, post a topic, reply |
| `02-user` | profile edit, private messages, who's-online |
| `03-features` | search, attachment upload, favourites |
| `04-admin` | two-factor admin login, management pages, board creation, post deletion |
| `05-moderation` | 提升 / 固顶 / 评帖 / 锁定 / 转移 / 镜像 / 修复 / batch delete |
| `06-member` | registration, first login, posting as a member, logout, polls (create + vote), favourites, friends |
| `07-links` | crawls every emitted `href`/`src`/`action` and checks it resolves |
| `08-adminops` | IP block + unblock, backend user create + edit, board category, forum log |
| `09-cms` | create a CMS category, publish an article, read it back publicly |
| `10-mobile-misc` | mini/mobile browse + post, avatar upload, skin switch |
| `11-editing` | edit your own post, delete a private message |
| `12-plugins` | flash_gold on Ruffle (player, canvas, score → row → leaderboard), bbschat send + cross-session poll, HomePageStar, LeadCard |
| `13-adminflows` | SQL backup export → download → delete, clear online users, templet manager CRUD |
| `14-plugins-destructive` | LeadCard make + redeem + double-spend, group private message, SiteReset, DelUserAllAnnounce |
| `15-adminsite` | 站点管理: site stats, 扩展服务, sidebar config, ad slots, SiteMap, friend links, disk usage, close + re-open the forum |
| `16-adminsetup` | extended skins (create/edit/delete, §35 + §37 guards), on-line file editors, UBB/upload/emoticon setup, RepairSite, site-wide stickies |
| `17-adminblock` | the batch repair/delete jobs (recount posts, rebuild topics, SiteMap, purge users/attachments), TableInfo, the MSSQL-only tools, the upgrade guard |
| `18-adminuser` | badges (grant + revoke), registration params, special users, avatar gallery, expiry cleanup, user create → repair → delete, board create → rename → move → purge → delete, forum categories |
| `19-boardmaster` | the 版主 control panel: access gating, ClearTopAnc, moderation queues, 屏蔽发言 + release, 清理用户资料, the IP-block guard |
| `20-editor-user` | the editor's insert dialogs, the emoticon picker, the fetch proxy, UBB help, 隐身, 查找用户, extended skins, 个性昵称, 绑定帐号, unfriend, delete-attachment |
| `21-cms` | the CMS admin verbs: 管理文章, 编辑其它信息, 设置栏目内容 (§35 + §36 guard), 更新缓存, and the combobox data feeds |
| `22-misc` | root redirect, frame toggle, RSS + the BBSData descriptor, topic/attachment lists, password recovery, app centre, music box, youku bridge, chinesecode, bbschat endpoints, the mobile dispatcher |
| `23-reader-view` | what a **non-admin** gets: register, post as that member, and assert every topic link six list pages offer a guest resolves to a real post (§27) and that posting shows no error banner (§43) |
| `24-attachment` | attachments judged by what a reader sees: a member's image rendered at full size in a guest's browser, and an over-cap file refused **visibly** (§45) both before and after submit |
| `25-guest-crawl` | the 07 crawl repeated as a **logged-out visitor**, reading the page body as well as the status line — an AxonASP runtime error is served with HTTP 200 (§43), so a status-only crawl calls it working |

## Coverage

```sh
bash test/coverage/browser_census.sh      # instruments every .asp, runs all suites, reports
bash test/coverage/verb_census.sh         # which action= verbs the suites actually send
```

The census inserts an `Application(...)` probe into each file, drives the suites, and merges
what it observes; `instrument.py` is idempotent and reverts only the files it touched. Results
and their caveats live in [../docs/coverage-gaps.md](../docs/coverage-gaps.md).
