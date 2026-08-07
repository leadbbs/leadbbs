# AxonASP construct-compatibility matrix (LeadBBS 9.2)

A static census of the VBScript / Classic-ASP constructs LeadBBS 9.2 actually uses, cross-referenced
with how each behaves on **AxonASP 2.3.5 on Linux**. Goal: know which language features and COM
components the forum depends on, and which ones needed a workaround — so feature coverage is a
deliberate map, not a guess.

- **Corpus:** 271 real source files (`.asp`/`.asa`/`.inc`), excluding the case-compat symlink farm
  and throwaway scratch pages dropped into the web root for a single probe and deleted after
  (the surviving, gated helpers live in `test/browser/helpers/`).
- **Counts** are raw regex occurrences (`uses`) and the number of distinct files touched (`files`).
- **Status legend:**
  - ✅ **Works** — supported by AxonASP, exercised by the running site.
  - ⚠️ **Works, needed a fix** — supported, but a LeadBBS usage tripped an AxonASP divergence that
    was worked around; see the referenced README section.
  - 🚫 **Unavailable on Linux** — Windows-only COM; not provided. All such uses are non-essential
    (external update check, native accelerator, email), so the core forum is unaffected.

Evidence: construct probes run against the live server, a status sweep of all **170 servable entry
pages** (161 × 200, 3 × 302, 6 × 500 — all six dead third-party tech), the **link crawl** of 182
emitted URLs (`test/browser/07-links.mjs`), the **eleven headless-Chromium suites** in
`test/browser/` (92 checks), and the fixes in the top-level `README.md` (§1–§32).

> **Counts are from the original static census** and are not re-derived on every edit; treat them as
> orders of magnitude. Statuses and notes below ARE kept current — several rows that read ✅ in the
> first pass were demoted once browser-driven testing proved them broken (§19 onward). The lesson
> that produced most of those demotions: a construct that works in a probe can still be broken in
> the way the application actually uses it.

## Language & control flow

| Construct | uses | files | Status | Notes |
|-----------|-----:|------:|--------|-------|
| `Response.Write` | 2787 | 185 | ✅ Works | |
| `CInt/CLng/CDbl/CCur/CStr/CBool` | 1741 | 159 | ⚠️ Works, needed a fix | `CStr` of a MySQL BIGINT (returned as a Double) yields scientific notation `2.026e+13`; broke 14-digit timestamp slicing. Fixed in `RestoreTime` (README §15). |
| `Replace` | 1410 | 139 | ✅ Works | |
| `Mid/Left/Right` | 1311 | 160 | ✅ Works | |
| `Call` statement | 999 | 128 | ⚠️ Works, needed a fix | Parenthesis-less forward `sub arg` calls were dropped, and class→module calls failed; rewritten to `Call name(args)` (README §6, §8, §9). |
| `Function` def | 960 | 177 | ✅ Works | |
| `multi-dim array (r,c)` | 929 | 46 | ✅ Works | `ReDim a(m,n)` + `UBound(a,2)` verified. |
| `isNumeric/isDate/isNull/isArray/isObject/isEmpty` | 864 | 140 | ⚠️ Works, needed a fix | Two divergences: `IsNumeric` on a scientific-notation *string* returns false (the subtlety behind §15), and **`IsNumeric(Empty)` is `False`** where VBScript says `True` (§25) — an uninitialised global used as a form default therefore failed validation, which made board creation impossible from the admin UI. |
| `InStr/InStrRev` | 785 | 108 | ✅ Works | |
| `Sub` def | 657 | 157 | ✅ Works | |
| `LBound/UBound` | 430 | 127 | ✅ Works | |
| `Select Case` | 288 | 101 | ✅ Works | |
| `Const` | 281 | 60 | ⚠️ Works, needed a fix | Not hoisted — consts used before their line (or before an include) were undefined; moved earlier. Illegal `Const` re-assignment also flagged (README §5, §12). |
| `Chr/Asc/ChrW/AscW` | 259 | 49 | ⚠️ Works, needed a fix | **No coercion of a numeric *string***: `ChrW("97")` returns `Chr(0)`, not `"a"` (§23). `DecodeCookie` rebuilds the auth cookie from string parts, so the decoded user name came back as NULs and every "remember me" login logged straight back out. Fixed with `ChrW(CLng(...))`. |
| `DateDiff/DateAdd/DatePart` | 121 | 49 | ⚠️ Works, needed a fix | `DateDiff` on a slash-date or an empty/garbage string overflows to `9223372036` (§15). Separately, **`DateAdd` argument order is not forgiving**: `DateAdd("d", <date>, <n>)` is tolerated by IIS but computes a date in 1683 here, so the auth cookie was written already-expired (§24, 8 sites). |
| `Do While/Until … Loop` | 81 | 41 | ✅ Works | |
| `Array()` | 77 | 32 | ✅ Works | |
| `ByRef/ByVal` params | 74 | 8 | ✅ Works | Made `RestoreTime` `ByVal` defensively (§15); no ByRef binding bug observed. |
| `Split()` | 162 | 62 | ✅ Works | |
| `FormatNumber/FormatDateTime/…` | 38 | 22 | ⚠️ Works, needed a fix | Same class as §23: **no coercion of a numeric *string***. `FormatNumber("20260725002844", 0)` returns `"0"` (§26). This was a landmine inside the `LngStr` helper introduced for §22 — now used at ~380 sites — so it is `FormatNumber(CDbl(v), 0)` there. |
| `For Each` | 32 | 18 | ✅ Works | |
| `VBScript RegExp` (`New RegExp`) | 29 | 15 | ✅ Works | `.Test`, `.Execute`, `.Replace`, `.Global` all verified. |
| `ReDim` | 27 | 15 | ⚠️ Works, needed a fix | `ReDim <global>(n)` **inside a conditional block hoists as a function-scope re-declaration** and clobbers a session-sourced global to non-array even when the branch is skipped — the root of the login-drop bug. Rebuild into a local and assign (README §16). |
| `With … End With` | 19 | 11 | ✅ Works | |
| `Eval/Execute/ExecuteGlobal` | 55 | 20 | ✅ Works | Dynamic evaluation verified. |
| `While … Wend` | 7 | 3 | ✅ Works | |
| `Dim x(n)` (fixed array) | 5 | 5 | ✅ Works | The fix for §16 relies on this. |
| `ReDim Preserve` | 2 | 1 | ✅ Works | |
| `Option Explicit` | 8 | 8 | ✅ Works | Active in `BBSSetup.asp`; forces `Dim` before use. |
| **call to an undefined routine** | — | — | ⚠️ Silently ignored | `NoSuchSub("x")` does nothing and raises nothing; in an expression it yields `Empty` (§28). IIS raises *Type mismatch* / *Object required* and stops the page. Forgiving, but it is what lets a missing include or a typo'd name fail invisibly — the root shape of most "the button does nothing" bugs in this port. `test/deadcalls.py` hunts them by include-closure. |
| hex literal with `&` type suffix | 3 | 1 | ⚠️ Works, needed a fix | `&HFF0000&` (the trailing Long suffix) is rejected; dropping the suffix works (§18). It broke the canvas captcha renderer with a 500. |
| bare Sub call inside a `Class` body | — | — | ⚠️ Works, needed a fix | A module-level `Sub` invoked as a bare statement from inside a class raises `800A01B6`; it needs `Call` (§9). Module *Functions* used in expressions are fine. Swept 20 call sites in 7 files — until then every `mini/` (mobile) board URL returned 500. |
| `GetRef` | 0* | — | ✅ Works | *Not in corpus but probed OK. |
| `Join / Filter / StrReverse` | — | — | ✅ Works | Probed OK (LeadBBS uses hand-rolled equivalents). |

## OOP (classes)

| Construct | uses | files | Status | Notes |
|-----------|-----:|------:|--------|-------|
| `Class` definition | 45 | 36 | ✅ Works | |
| `Set x = New` | 92 | 49 | ✅ Works | |
| `Class_Initialize/Terminate` | 33 | 25 | ✅ Works | |
| `Property Get/Let/Set` | 11 | 3 | ✅ Works | |
| `Me` keyword | 1 | 1 | ✅ Works | |
| class method → module Sub | — | — | ⚠️ Works, needed a fix | A class method calling an unqualified module Sub, or *writing* a module-level array element, fails (`Object doesn't support this property or method`); route through `Call`/a helper Sub (README §9, §12). |

## ASP intrinsic objects

| Construct | uses | files | Status | Notes |
|-----------|-----:|------:|--------|-------|
| `Request.Form` | 576 | 109 | ✅ Works | Drives login, registration, posting (verified E2E). |
| `Application()` | 555 | 72 | ⚠️ Works, needed a fix | An array containing `Null` stored in `Application` reads back with `Null` → the string `"Null"`; caused a type-mismatch in `GetStyleInfo`. Stop the NULL at the query with `IFNULL(...)` (README §11). |
| `Request.QueryString` | 273 | 80 | ✅ Works | |
| `Application.Lock/UnLock` | 280 | 43 | ✅ Works | |
| `Session()` | 167 | 19 | ⚠️ Works, with an open issue | Arrays (incl. `Null` elements) persist across requests; this is what login relies on (§16/§17). **Open: §32** — under a sustained artificial load the server reaches a state where a page depending on session-derived identity renders as a guest while another page in the same session does not. Cleared by a restart; not root-caused. |
| `Server.CreateObject` | 152 | 57 | ✅ Works | See COM table for which classes resolve. |
| `Server.HTMLEncode/URLEncode` | 145 | 32 | ✅ Works | |
| `Server.MapPath` | 132 | 36 | ✅ Works | Case-insensitive for `MapPath`/`#include` (but **not** for served URLs, and that applies to **directories** as well as file names — §29). A relative path resolves against the *calling page's* directory, which matters when a routine is shared between pages at different depths. |
| `Recordset.GetRows` / `Rs(n)` | 150 | 80 | ⚠️ Works, needed a fix | **Widest-blast-radius divergence found (§27): fields resolve by NAME, so two columns sharing a name collapse and every ordinal returns the LAST one.** LeadBBS selects both `T1.ID` and `T2.ID` in one 57-column join and reads it positionally, so column 0 — the post id — silently became the author's user id on every post-list page, and post moderation targeted rows that did not exist. Fixed by aliasing later duplicates in 41 SELECTs across 23 files. Also the `Null`→`"Null"` issue (§11) when such an array is cached in `Application`. |
| `Recordset.GetString` | 6 | 6 | ⚠️ Works, needed a fix | **Only ADO's defaults are implemented — the ColumnDelimiter / RowDelimiter / NullExpr arguments are accepted and discarded** (§30). LeadBBS builds JavaScript row callbacks out of those delimiters, so five admin lists (forum log, template manager, style parameters, board categories, mail list) rendered **zero rows** with data present. Replaced by `RsGetString()` in `inc/Str_Fun.asp`. |
| `Request.ServerVariables` | 84 | 30 | ⚠️ Works, needed a fix | `REMOTE_ADDR` is the IPv6 loopback `::1` on Linux; LeadBBS is IPv4-only and mangled it, dropping sessions. Normalized in `GetIPAddress` (README §17). |
| `Response.End/Clear/Flush` | 82 | 33 | ✅ Works | |
| `Response.Cookies` | 69 | 8 | ⚠️ Works, needed a fix | Cookies themselves work, but the "remember me" auth cookie was broken twice over: `ChrW` of a numeric string (§23) and swapped `DateAdd` arguments (§24) — together they made every persistent login log straight back out. Its `expires` sub-value also rendered in scientific notation until wrapped in `LngStr` (§22). |
| `Response.AddHeader/Charset/ContentType/Buffer/Expires` | 67 | 28 | ✅ Works | |
| `Server.ScriptTimeout` | 32 | 31 | ✅ Works | |
| `Request.Cookies` | 24 | 8 | ✅ Works | |
| `Response.BinaryWrite` | 14 | 6 | ✅ Works | Used by captcha/image output. |
| `Server.Transfer/Execute` | 2 | 1 | ✅ Works | |
| `Request.BinaryRead` | 2 | 1 | ✅ Works | Used by the no-component uploader — but the `ADODB.Stream` it feeds needed §20 (see the COM table). |

## Includes, directives, encoding

| Construct | uses | files | Status | Notes |
|-----------|-----:|------:|--------|-------|
| `#include file=` | 614 | 161 | ⚠️ Works, needed a fix | Non-standard/loose include syntax was normalized to `<!--#include file="…"-->` (README §2). |
| `<%@ LANGUAGE/CodePage` | 27 | 17 | ⚠️ Works, needed a fix | Source was GBK/`CodePage=936`; converted whole tree to UTF-8 / `65001`, `charset=gb2312`→`utf-8` (README §1). Also `%>` inside `'`/`rem` comments didn't close the block (README §3). |
| JScript `runat=server` block | 1 | 1 | ⚠️ Works, needed a fix | A `<script runat=server language=javascript>` block broke `On Error Resume Next`; the one occurrence (`getJVer`) was ported to VBScript (README §, JScript). VBScript is the supported server language. |

## Error handling

| Construct | uses | files | Status | Notes |
|-----------|-----:|------:|--------|-------|
| `On Error Resume Next` | 98 | 47 | ✅ Works | Pervasive; works except when a JScript server block is in scope (above). |
| `Err.Number/Description/Clear/Raise` | 174 | 37 | ✅ Works | |
| `On Error GoTo 0` | 1 | 1 | ✅ Works | |

## COM components (`Server.CreateObject`)

Probed live with a throwaway page in the web root, since this can only be answered by asking a
running server. AxonASP ships shims for the common ASP components; the Windows-only
ones LeadBBS touches are all in non-essential paths.

| ProgID | Status | Used for | Essential? |
|--------|--------|----------|-----------|
| `ADODB.Connection` / `.Recordset` | ✅ Works | all DB access (via MySQL ODBC) | **yes** — core |
| `ADODB.Stream` | ⚠️ Works, needed a fix | no-component file upload/read, UTF-8 decode | yes (uploads) — **a bare `.Read` returns `Empty`; it needs `.Read(-1)` (§20)**. Classic ASP treats bare `Read` as `adReadAll`. Every field of every multipart form came back blank with no error, which silently broke profile edit, all uploads, and posting from a real browser. |
| `Scripting.FileSystemObject` | ✅ Works | template/cache file I/O | **yes** — core |
| `Scripting.Dictionary` | ✅ Works | no-component upload parsing | yes (uploads) |
| `MSXML2.DOMDocument` | ✅ Works | XML parsing | no |
| `Persits.Jpeg` (AspJpeg) | ✅ Works (shim) | avatar crop/thumbnail | no — but now **exercised for real**: `test/browser/10-mobile-misc.mjs` drives the two-step avatar upload, and the shim's `Open`/`Crop`/`Save` produce an image that renders on posts. |
| `Persits.Upload` (AspUpload) | ✅ Works (shim) | component upload | no (FSO path used) |
| `Msxml2.ServerXMLHTTP.3.0` | 🚫 Unavailable | outbound HTTP for the LeadBBS **update check** | no |
| `leadbbs.bbsCode` | 🚫 Unavailable | native BBS-code render accelerator | no (VBScript fallback) |
| `JMail.SMTPMail` | 🚫 Unavailable | sending email (activation, mail-list) | no |

## Bottom line

AxonASP's VBScript/ASP surface is **broad and faithful** — every core-forum construct LeadBBS 9.2
uses is supported, including the ones people assume are missing from re-implementations (`RegExp`,
`Eval`/`Execute`, `Scripting.Dictionary`, `With`, multi-dimensional arrays, updatable Recordsets).
The 17 incompatibilities that had to be worked around are narrow edge-cases (compiler hoisting order
for `Const`/`ReDim`, class↔module name resolution, `Null` marshalling through `Application`,
`CStr`-of-BIGINT formatting, comment/encoding parsing) rather than missing features. The only genuine
**gaps** are three Windows-only COM objects — outbound HTTP (`ServerXMLHTTP`), the native `bbsCode`
accelerator, and `JMail` — all in optional paths, so the forum runs without them.
