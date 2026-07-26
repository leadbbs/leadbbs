# AxonASP runtime coverage census (LeadBBS 9.2)

A runtime, trace-instrumented census of **which source files actually execute** when the forum is
exercised end-to-end on AxonASP + MariaDB. This complements the static
[construct matrix](axonasp-construct-matrix.md): the matrix says *which language features are used*,
this says *how much of the code we actually made run and verify*.

## Method

1. **Instrument** — prepend a one-statement probe to every real (non-symlink) `.asp`/`.asa`/`.inc`
   file: `<%Application("cov::<relpath>")=1%>`, inserted after any leading `<%@…%>` directive so it
   never breaks page parsing. A single unlocked `Application` write; it does not touch page error
   state, output, or the response. (Script: `test/coverage/instrument.py`.)
2. **Exercise** — against one server instance (`test/coverage/exercise.sh`):
   - **Guest pass:** GET every one of the 257 served `.asp` files.
   - **Admin pass:** log in as `admin`, complete the two-factor admin-panel login, then GET all 257
     again (so auth-gated branches and every `manage/*` page run).
   - **Write flow:** post a topic (exercises the `a/a2.asp` insert path and its includes).
3. **Collect** — `Application.Contents` is dumped (`test/coverage/covdump.asp`) and de-duplicated.
4. **Revert** — `git checkout -- .` restores the pristine files; the probes never ship.

> Note: AxonASP treats `Application` keys case-insensitively (as Classic ASP does) and enumerates
> them lowercased, so covered/total are compared case-insensitively.

**Granularity:** file-level — a file counts as *covered* if its code began executing in some
request. Sub-level coverage of the critical auth/post paths was separately confirmed by the
`AxTrace` instrumentation used to fix the login bug and by the `test/` E2E suite.

## Result: 256 / 259 files executed — **98.8%**

Re-measured 2026-07-25, after the browser suites and the plug-in work. The previous run scored
250/258 (96.9%); six of the eight files it could not reach now execute.

Only three files are left, and one of them is the census's own scaffolding:

| File | Why it didn't run |
|------|-------------------|
| `_covdump.asp` | The dump page this very census copies into the web root to read `Application` back. An artefact of the measurement, not source. |
| `data/global.asa` | Empty — no `Application_OnStart`/`Session_OnStart` handlers, so there is nothing to execute. |
| `User/alipay/alipayto/Alipay_Notify.asp` | Alipay payment-gateway callback; fires only from Alipay's servers on a real transaction. The endpoint is defunct — an agreed gap. |

Excluding the census's own page that is **256 / 258 = 99.2%**, with two files uncovered and
both explained.

### What changed since the 96.9% run

| File | Was uncovered because | Now |
|---|---|---|
| `a/file.asp` | needed a real uploaded attachment | the attachment upload suite posts one (§20 fixed the multipart parser) |
| `manage/Database/BackupDatabase.asp` | "only offered when `DEF_UsedDataBase = 1` (Access)" | rewritten as a MariaDB SQL dump and driven by `13-adminflows.mjs` |
| `manage/SiteManage/SiteReset.asp` | deliberately not triggered | reached by the admin crawl (it does not touch the database — see the flow spec) |
| `User/inc/canvas.asp`, `User/inc/Canvassafecode.asp` | canvas captcha not on the default path | reached once §18 (the `&` hex suffix) was fixed |
| `plug-ins/flash_gold/gold.asp` | non-essential Flash plug-in | the plug-in is revived (Ruffle + MariaDB); the stray `Sub` that had never compiled is gone |

## Interpretation

Combined with the [construct matrix](axonasp-construct-matrix.md) and the thirteen browser suites
in `test/browser/`, this gives high confidence that LeadBBS 9.2 runs *broadly*, not just on its
landing pages:
**98.8% of the source executes under a normal guest + admin + posting workload**, and the small
uncovered remainder is entirely optional or external functionality. The reproducible tooling lives
in `test/coverage/` so the census can be re-run after future changes.

Two caveats worth keeping in mind when reading this number. It is **file-level**: a file counts as
covered once its code begins executing, which says nothing about branch coverage — that is what the
browser suites are for, and they are the stronger evidence. And a census run is exactly the
whole-site crawl that §32 warns about, so **restart AxonASP afterwards**.
