# Coverage gaps — measured, not estimated

Two different questions get two different numbers, and they must not be conflated:

| measurement | tool | result |
|---|---|---|
| which files *can* execute (curl crawl) | `test/coverage/run_census.sh` | **256/259 = 98.8%** |
| which files the *Playwright suites* execute | `test/coverage/browser_census.sh` | **217/232 = 93.5%** |
| which `action=` verbs the suites put on the wire | `test/coverage/verb_census.sh` | **54/54 = 100%** |

The second and third are the ones that matter for confidence. Both are produced by one run of
`browser_census.sh`, which drives all 22 suites against a freshly restarted server each and
merges what it observes. Previous measurement: **155/259 files (59.8%) and 27/54 verbs**.

## How the denominator is defined

`232`, not `259`. Three corrections, all in the direction of measuring what the number claims
to measure:

- **A `.asp` with no server code in it is data, not source.** LeadBBS ships content fragments
  with an `.asp` extension — the registration agreement, the CMS contact blocks, the
  channel-list records, the picture-slideshow snippets — that are read with `ADODB_LoadFile`
  and never executed, plus `data/global.asa`, which is the original *binary Access database*.
  They can only ever sit in the denominator as permanently unreachable. `instrument.py` skips
  them for a second reason: probing them corrupts them, because the on-line file editor
  refuses content containing `<%`.
- **`runat=` counts as source**, so `inc/sha1.asp` (server-side JScript, no `<%` anywhere) is
  still measured.
- **`_covdump.asp` is the census's own probe**, not part of the application.

## The 15 files no browser suite reaches

**Agreed permanent exclusions (12).** Dead third-party technology or a component this
deployment does not have:

| file | why |
|---|---|
| `app/qqlogin/login.asp` | QQ social login; Tencent retired the API. Kept only so it does not crash the pages that include it (§12). |
| `user/alipay/*` (8 files) | Alipay payment gateway; the endpoints are gone. |
| `manage/user/sendmaillist.asp` | Needs the JMail COM component, which AxonASP does not provide. |
| `install/default.asp`, `install/scripts/install_fun.asp` | The installer. The forum is installed; re-running it would destroy the deployment. |

**Unreachable in this configuration (2).**

| file | why |
|---|---|
| `inc/sha1.asp` | Included by `User/inc/Mail_fun.asp` *inside* `if len(DEF_SMS_UID)>15 and len(DEF_SMS_KEY)=32`. It exists only for the China Telecom SMS sender, which has no credentials configured — SMS is out of scope with mail. The include compiles; the branch never runs. |
| `search/inc/list_fun.asp` | Dead code. Nothing in the tree includes it and nothing links it: `Search/List.asp` only redirects to `b/b.asp?action=list&type=N`. Its functions are superseded by `b/inc/Board_fun.asp`. |

**Driven, but not countable (1).**

| file | why |
|---|---|
| `manage/update.asp` | Rendering it calls `restartbbs()`, which does `Application.Contents.RemoveAll` — that erases the coverage accumulator `instrument.py` keeps in `Application`, **in the same request that sets its own probe**. Suite 17 asserts three things about it: that it does nothing without `sure=1`, that it explains its four tools and demands confirmation, and that it warns the forum will be suspended. The same hazard used to hide `manage/BlockUpdate/BlockUpdate.asp`, the one other file only suite 17 opens; suite 17 now drives that page as its **last** action, after everything that clears `Application`, and it counts again. |

## The census's own limitations, written down

- **`Application.Contents.RemoveAll` erases the accumulator.** The census samples
  `_covdump.asp` every three seconds while a suite runs and merges every sample, so a wipe
  costs at most that window — but a page that wipes in the same request that sets its probe
  can never count itself.
- **The application regenerates its own sources.** `inc/IncHtm/*`,
  `article/inc/cache/CACHE_*` and `inc/*_Setup.asp` are rewritten at runtime, and every
  rewrite drops the probe. `instrument.py` is idempotent and the census re-probes after each
  suite so a later suite's use still counts.

## Depth: 54/54 `action=` verbs

The verb list is extracted mechanically from the source — every distinct value the application
emits in a URL as `?action=V` / `&action=V` — and the driven set is measured **at the
browser**: `lib.mjs` records the `action=` of every request a Playwright context issues, URL
or POST body, including the multipart bodies only a real form produces (§20). A verb counts
only if a real browser really sent it.

Two are driven to a **refusal** rather than a success, because the service behind them no
longer exists, and the suite asserts the refusal and that no row was written:

- `save` (`app/tools/youku/default.asp`) — posts to the Youku Open API, discontinued; the site
  has no api key and the page must say so rather than pretend.
- `fobip` (`User/BoardMaster/User/LimitUserManage.asp`) — this deployment ships
  `DEF_EnableForbidIP = 0`, and the page must tell the moderator that instead of offering a
  form whose row `inc/Board_Popfun.asp` never enforces (it did, until §19's guard typo was
  fixed).

## What 'covered' does not mean

A file counting as covered says only that its code began executing. `User/register.asp` sat
inside the old 59.8%, yet the captcha image a user actually has to read had no assertion at
all until it was challenged. Every check added in this pass asserts a rendered artefact or a
database row: an image must decode (`naturalWidth > 0`), a saved setting must come back from
the page *or* from the file the page regenerated, a deletion must remove the row and the thing
a reader sees, and a control that reports success must have written something.

**And a covered file can be covered from only one direction.** Both numbers above were already
green when a user reported that the board's topic list handed out dead links and that posting a
topic showed an error page. `b/inc/Board_fun.asp` and `a/a2.asp` were in the covered set the
whole time, and suite 06 had been posting as an ordinary member and passing — on
`announce count went up`, which was true even while the poster got a 800A1399 banner. What no
suite did was **read the forum as somebody other than `admin`**: the broken board list is
served only on the uncached path a guest or a new member gets, so 22 suites and 436 checks
never once requested it. `23-reader-view.mjs` exists to hold that direction open — it registers
an account, posts through the browser as that account, and then checks, as a logged-out reader,
that every topic link six list pages offer resolves to a real post. Run against the code as it
was, it fails 11 checks.

**A fixture can make an assertion untestable.** The same report turned up a second gap of a
different kind: `03-features` had asserted "an attachment row was created" since the start, and
the fixture it uploaded was a **1×1 transparent GIF**. A forum that rendered the attachment
perfectly and one that dropped it produced identical pixels, so the check could not fail for the
reason anybody cared about — and did not, while a user's 2.2 MB photo was being discarded in
silence (§45). Both were fixed: the fixture is now 64×32 and `03-features` asserts its rendered
width in the browser, and `24-attachment.mjs` covers the refusal paths end to end. When a check
cannot distinguish the bug from the fix, it is not evidence, whatever colour it prints.
