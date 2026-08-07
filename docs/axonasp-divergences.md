# AxonASP vs. VBScript/ADO: 52 behavioural differences found porting LeadBBS 9.2

Every entry here cost real debugging time on a real application. They are written as
*divergences from the semantics Classic ASP code is written against* — IIS + VBScript 5.x +
ADO — because that is what breaks when you move an existing application to AxonASP. Most come
with a minimal repro you can paste into a `.asp` file and run.

Found against **AxonASP 2.3.5** on Linux. Several have been reported upstream; some may already
be fixed in a later release, so check before assuming. Numbering is historical (the order they
were found), not by severity — §27, §32 and §20 were the expensive ones.

A few entries are marked as **upstream LeadBBS defects rather than AxonASP differences**; they
are kept here because they were found the same way and because they bite anyone running this
code, whatever engine it is on.

---

### 1. Source encoding: GBK → UTF-8

The upstream files are GBK-encoded and declare `charset=gb2312` / `CodePage=936`. AxonASP
always serves UTF-8 and does not honour `CodePage=936` for decoding source, so unconverted
files render as mojibake. All text sources were converted to UTF-8 and their charset
declarations rewritten (`gb2312` → `utf-8`, `CodePage=936` → `65001`).

A handful of files are intentionally left untouched: `data/global.asa` (the binary Access
database, unused here), `images/vlink/LOGO.TXT` (a mislabelled GIF), and a few plugin assets
with pre-existing byte corruption in the original zip.


### 2. Normalize `#include` directives

LeadBBS uses the IIS-lenient server-side-include form with a space after `<!--` and an
unquoted path:

```
<!-- #include file=inc/BBSSetup.asp -->
```

AxonASP's parser only recognizes the strict form, and silently passes anything else through
as a literal HTML comment (so the page renders as a stub with no code executed). All 614
directives across 161 files were normalized to:

```
<!--#include file="inc/BBSSetup.asp"-->
```

Note on **case sensitivity**: many includes reference paths whose case does not match the
file on disk (e.g. `inc/BBSsetup.asp` vs `inc/BBSSetup.asp`). AxonASP ships a
case-insensitive path resolver that handles these transparently, so the wrong-case includes
still resolve on Linux without renaming files.


### 3. `%>` inside VBScript comments

Classic IIS ASP closes the `<% %>` code block when it hits `%>` *lexically*, even inside a
`'` comment. LeadBBS relies on this deliberately, e.g.:

```asp
href="...article/inc/default<%
'If GBL_Board_BoardStyle > 0 Then Response.Write GBL_Board_BoardStyle%>.css" ... />
```

The commented-out `Response.Write` is skipped and `%>` closes the block so `.css"` resumes as
HTML. AxonASP instead treats `%>` inside a comment (or a string) as literal text, so the block
never closes and the following HTML is parsed as VBScript → *Invalid character*. (Its string
handling is actually safer than IIS — the classic `"%" & ">"` concatenation trick still works.)

A state-aware pass inserts a newline before any `%>` that sits inside a comment, terminating
the comment so the block closes. The newline lives inside `<% %>`, so emitted HTML is
unchanged. This fixed 30 block-closers across 15 files.


### 4. Database: MariaDB instead of Access

AxonASP's ADODB cannot open an Access `.mdb` on Linux — the `Microsoft.Jet.OLEDB.4.0`
provider is Windows-only COM and AxonASP rejects the connection string outright. AxonASP's
ADODB speaks SQLite, MySQL, PostgreSQL and MSSQL. LeadBBS's installer has a native MySQL code
path, so **MariaDB** (MySQL wire-compatible, installs from Ubuntu's default repos) is the
least-invasive backend.

Provision it once:

```sh
sudo apt-get install -y mariadb-server
sudo mysql <<'SQL'
CREATE DATABASE leadbbs CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'leadbbs'@'localhost' IDENTIFIED BY 'leadbbs';
GRANT ALL PRIVILEGES ON leadbbs.* TO 'leadbbs'@'localhost';
FLUSH PRIVILEGES;
SQL
```

Two source changes make the DDL and connection UTF-8-consistent (the sources are now UTF-8,
so `gbk` on the wire would double-encode):

- `install/database/mysql.sql`: table DDL `DEFAULT CHARSET=gbk` → `utf8` (utf8mb3, full
  Chinese BMP coverage; safe under `ROW_FORMAT=COMPACT`'s 767-byte index-prefix limit, which
  utf8mb4 would exceed).
- `install/scripts/install_fun.asp`: the generated connection string's `charset=gbk` →
  `charset=utf8`.

The installer accepts the ODBC-style string
`Driver={Mysql ODBC 5.2 ANSI Driver};SERVER=localhost;DATABASE=leadbbs;UID=<user>;PWD=<password>;charset=utf8;`
— AxonASP maps it to its native MySQL driver.


### 5. AxonASP `Const` is not hoisted

Classic VBScript hoists all `Const`/`Dim`/`Sub`/`Function` declarations, so a function may use
a `Const` defined later in the file. AxonASP resolves `Const` at compile time by source
position: a `Const` used before its textual definition resolves to **empty** (no error).
`Dim` variables and `Sub`/`Function` definitions *do* hoist.

This made the installer falsely report "installation locked": `install/default.asp` declared
`const DEF_BBS_HomeUrl = "../"` *after* including `install_fun.asp`, so the included
`checkInstalled()` saw it empty, read the wrong path, and misdetected the state. Fixed by
moving the consts above the include.


### 6. AxonASP drops parenthesis-less calls to forward-declared Subs

A parenthesis-less call to a `Sub` defined *later* in the compilation unit is silently
compiled to a **no-op** — the sub never runs and no error is raised. AxonASP binds a bare
identifier statement at compile time; if the sub isn't defined yet it is dropped. Adding
parentheses forces a real runtime call:

| Call form | Forward-declared sub | Result |
|-----------|---------------------|--------|
| `MySub` / `Call MySub` / `MySub arg` | yes | **dropped** |
| `MySub()` / `Call MySub()` / `MySub(arg)` / `Call MySub(a, b)` | yes | works |
| any form | no (defined earlier) | works |

The installer's `install_step3form` called `install_step4form` (defined later) which silently
did nothing → blank admin form. Fixed by parenthesizing the inter-step calls
(`install_step4form()`, `install_step5form()`). Expect this pattern elsewhere during the page
sweep.


### §6 again: a bare forward call on the same line as its `Case`

The tree-wide pass in §8 matched a *line* that is just an identifier, so it never saw
`Case "n":DisplayUserAnc` — the call shares the line with the `Case`. Eight such sites
survived, and every one of them was a dropped call:

- `User/LookUserInfo.asp` — 我的帖子 / 我的附件 / 我的好友 / 收藏夹 / 关联帐号. All five
  profile tabs rendered the page chrome and **nothing else**.
- `User/UserTop.asp` — 查找用户 and 版面发帖排行.

Parenthesised. `test/deadcalls.py`-style scanning for this shape is worth keeping in mind:
the dangerous form is a bare identifier in *statement position*, wherever it sits.


### 7. Run the installer

With the database provisioned, drive the wizard (or use a browser at
`http://localhost:8801/install/default.asp`). The installer loads `mysql.sql`, creates the
39 tables, inserts the admin account, and rewrites `inc/BBSSetup.asp` with the connection
string and `DEF_UsedDataBase = 2`, removing the redirect-to-installer guard.

Both AxonASP bugs above (§5, §6) are worth reporting upstream to the AxonASP project.


### 8. Parenthesize bare sub-call statements (forward-call bug, site-wide)

The forward-call bug (§6) is pervasive at runtime: every page's `Sub Main` dispatches to render
subs (`Main_login`, `SiteBottom`, `Boards_Body_Bottom`, …) defined later in the same file, and
LeadBBS calls them parenthesis-less. Under AxonASP those calls silently vanish, so pages render
blank or partial (e.g. `User/Login.asp` returned an empty body).

A mechanical pass parenthesized every bare no-argument sub/function call statement — a line that
is just an identifier (optionally `Call`-prefixed) matching a known `Sub`/`Function` name — turning
`Main_login` into `Main_login()`. This is safe: adding `()` to a no-arg call is always valid, and
only whitelisted names are touched. 1242 call sites across 170 files. (Top-level `Main` calls were
never broken — the bug only affects calls *inside* a sub — but they were parenthesized too for
consistency.)

Multi-argument parenthesis-less calls (`BBS_SiteHead x, 0, "Error"`) can still hit the same bug and
are fixed case-by-case as they surface.


### 9. Class methods can't call unqualified module-level Subs

Inside a VBScript `Class`, an unqualified statement-call to a *module-level* Sub — e.g.
`CMS_NAVIGATECLASS_View()` from a method of `cms_cache_Class` — fails in AxonASP with
*Object doesn't support this property or method*: AxonASP binds the bare name as a class member
and does not fall back to global scope. Classic VBScript falls back. `Call X()` resolves
correctly (and works for class members too), and calling module-level **functions in an
expression** (`x = Func()`) also works — only the bare statement-call is broken.

A pass rewrites statement-calls to non-member (module-level) subs inside every `Class … End Class`
block to `Call X()`. 54 calls across 17 files. After this the CMS homepage stops erroring.


### 10. MySQL table-name case sensitivity (`lower_case_table_names=1`)

LeadBBS queries its tables in ~5 different cases (`LeadBBS_Boards`, `LeadBBS_boards`,
`leadbbs_boards`, …) because Windows MySQL is case-insensitive about table names. MariaDB on
Linux defaults to **case-sensitive** (`lower_case_table_names=0`), so most queries hit
"table doesn't exist" and silently returned empty — which masked a cascade of downstream
bugs. Fix: set `lower_case_table_names=1` in the MariaDB server config so names are stored
and compared lowercase, then rename the one mixed-case table the DDL creates and restart:

```sh
sudo mysql -e "RENAME TABLE leadbbs.LeadBBS_extend TO leadbbs.leadbbs_extend;"

### 11. AxonASP turns `Null` array elements into the string `"Null"` via Application

Once the queries actually returned rows, every page 500'd with a type mismatch in
`GetStyleInfo`. Root cause: AxonASP stores a VBScript array containing `Null` in an
`Application` variable and reads it back with the `Null` elements converted to the **string
`"Null"`** (classic ASP preserves `Null`). LeadBBS caches a `GetRows` result whose `LEFT JOIN`
column (`T2.TempletFlag`) is SQL NULL; after the Application round-trip it becomes `"Null"`, so
`cCur("0" & Temp(10,0))` computes `cCur("0Null")` → type mismatch. Since `GetStyleInfo` runs on
every page via `SiteHead`, this took down the whole site.

Fix: stop the NULL at the source — `IFNULL(T2.TempletFlag,0)` in the skin/templet query so the
cached array never holds `Null`. Other cached `GetRows`-with-nullable-column arrays could hit
the same bug and are handled as they surface.


### 12. QQ/social-login plugin: module array write inside a class

`User/Login.asp` and `User/register.asp` both include the QQ social-login plugin
(`app/qqlogin/oauth.asp`), whose class `Class_Initialize` assigns to a *module-level array*
element (`connect_allow(i) = …`). AxonASP can't resolve a module-array element *write* from
inside a class (`Object doesn't support this property or method`) — reads work, writes don't.
The plugin is defunct (Tencent no longer offers this API) but its crash blocked login and
registration. Routed the writes through a module-level helper Sub called via `Call`, which
works. (The plugin still needn't function — it just must not crash on include.)


### 13. Updatable Recordset insert fails with a `LIMIT` in the source query

User registration (and admin add/edit user) insert via an updatable ADODB Recordset:
`Rs.Open sql_select("Select * from LeadBBS_User",1), con, 2, 2` → `Rs.AddNew` → `Rs.Update`.
`sql_select` appends `limit 1` for MySQL, and AxonASP's `Recordset.Update` derives the target
table from the source query **without stripping `LIMIT`**, so it inserts into a table literally
named `leadbbs_user limit 1` → *Error 1146 … doesn't exist*. A `WHERE` clause is handled
correctly. Fixed the 3 insert/edit sites (`User/register.asp`, `manage/User/UserJoin.asp`,
`manage/User/UserModify.asp`) to use `Where 1=0` (empty insert cursor) or a real `WHERE` instead
of the `LIMIT` wrapper.

With this, **registration works end to end**: a new account is written to `leadbbs_user` and can
log in (verified — the forum shows the user authenticated on subsequent pages).


### 14. Base URL: `DEF_InstallDir`

The installer set `Const DEF_InstallDir = "/leadbbs/"` in `inc/BBSSetup.asp` (derived from the
folder name), but the app is served at the web root `/`. Every generated absolute link, redirect,
and form action was therefore prefixed with `/leadbbs/` and 404'd in a browser (curl bypassed this
by hitting exact paths). Corrected to `"/"`.


### 15. BIGINT → scientific notation breaks timestamp parsing

AxonASP's ADODB returns MySQL `BIGINT` columns as floating-point Doubles, so `CStr()` yields
scientific notation (`2.026e+13`). LeadBBS stores timestamps as 14-digit `YYYYMMDDHHMMSS` bigints
and does string slicing on them (`RestoreTime`). The catch: once the Double is `CStr()`'d to
`"2.026e+13"`, `IsNumeric()` on that *string* returns false, so a string-based guard never fires.
Fix in `inc/Str_Fun.asp`: test `IsNumeric` on the **original** value (a Double is numeric) and, if
so, `FormatNumber(…,0)` it to a plain integer string before the slice. `RestoreTime` was also made
`ByVal` so it never risks writing back through its argument.


### 16. `ReDim` of a session-sourced global inside a conditional clobbers it (the login-drop bug)

**Symptom:** login authenticated for exactly one request, then every following page dropped to
guest — blocking posting *and* all admin actions. **Root cause (AxonASP compiler bug):** in
`CheckPass` (`inc/Board_Popfun.asp`) the periodic re-validation branch rebuilds the user array with
`ReDim GBL_UDT(20)` inside an `If SQL >= 240 Then … End If` block. AxonASP hoists that `ReDim` as a
function-scope re-declaration of `GBL_UDT`, so on a normal page (where the branch is **skipped**,
`SQL < 240`) the global — which was loaded from `Session("leadbbsUDT")` at init — is silently reset
to a non-array. The password re-check then reads `GBL_UDT(9)` as empty, decides the session failed,
and wipes it. Minimal repro: a global assigned from `Session`, passed through a function whose
skipped `If` block contains `ReDim thatGlobal(n)`, comes back `isArray = False`.

Fix: build the rebuilt record into a **local** fixed array `UDT_tmp(20)` and do a single plain
`GBL_UDT = UDT_tmp` assignment — never `ReDim` the global. With no `ReDim GBL_UDT` anywhere in the
function, the global stays bound to the session array across the whole request.


### 17. IPv6 loopback (`::1`) trips the repeat-login check

With §16 fixed the session survived to a *second* check: LeadBBS is IPv4-only, and on Linux the
server reports the IPv6 loopback `::1` as `REMOTE_ADDR`. `CheckUserOnline` treats any non-IPv4
address as illegal and rewrites it to the `1.1.1.1` sentinel — but only on some requests, so the
"same user, different IP" repeat-login guard in `CheckPass` saw the address change (`::1` at login
→ `1.1.1.1` next page) and cleared the session. Fix in `GetIPAddress`: normalize IPv6 loopback and
IPv4-mapped IPv6 to `127.0.0.1` so every request sees one stable, valid address. (Direct remote
IPv6 clients remain unsupported — a pre-existing LeadBBS limitation, out of scope.) After changing
the IP format, clear stale `leadbbs_onlineuser` rows once (admin panel → 清理在线用户, or
`DELETE FROM leadbbs_onlineuser`) so old `::1`/`1.1.1.1` records don't mismatch.


### 18. AxonASP rejects the `&` (Long) type-suffix on hex literals

The verification-code image `User/number.asp` (a pure-VBScript GIF generator in
`User/inc/canvas.asp`) 500'd with a *compilation* error, so no human could read the captcha and
therefore couldn't register or post. AxonASP parses the trailing `&` on a hex literal like
`&HFF0000&` (the VBScript Long type-declaration suffix) as the start of a string-concatenation
operator, then hits the line end → "Unexpected token". Isolated repro: `x = &HFF0000&` fails,
`x = &HFF0000` works. Fix: drop the `&` suffix from the six hex literals in `WebSafePalette()`
(values unchanged). Swept the whole tree — no other file uses the pattern.


### 19. Forward-referenced parameterless Function silently returns Empty

AxonASP does not call a `Function` that is **defined later in the file** when it is
referenced **by bare name from inside another function**; the reference evaluates to
`Empty` and the function body never runs. Isolated repro — only this one form breaks:

| form | called? |
|------|---------|
| forward + parameterless + **bare name** (`If Check = 1`) | **no — evaluates Empty** |
| forward + parameterless + `()` (`If Check() = 1`) | yes |
| forward + takes an argument (`f(x)`) | yes |
| backward (defined earlier) | yes |

This is the *expression* cousin of §6 (which covered parenthesis-less **statement**
calls), so the earlier "add parens" pass never touched these. Symptom is the worst
kind: the page renders, the request returns 200, no error appears — the action just
silently does nothing.

It broke 加入收藏 (add favourite) and 提升 (promote topic) in `a/Processor.asp`, whose
dispatcher did `If CheckIsCanCollSure = 1 Then DisplayCollectAnnounce` — *both* halves
failed (the gate was a forward Function, the handler a forward Sub). Fixed by moving
`CheckSure`/`CheckTopSure`/`CheckIsCanCollSure` above the dispatcher and wrapping the
two in-file handlers in `Call`. A tree-wide ASP-aware sweep then appended `()` to 44
more such references in 22 files (incl. `CheckPass`, `CheckRndNumber` (captcha),
`SaveFormData`, `NewMessageForm`). Adding `()` is semantically identical in VBScript,
so it is a no-op where the call already worked.


### 20. `ADODB.Stream.Read` needs an explicit count — all multipart forms were broken

LeadBBS parses `multipart/form-data` itself (`a/inc/upload1_fun.asp`, `Class upload_Class`):
it streams `Request.BinaryRead` into an `ADODB.Stream`, then reads the buffer back. Under
AxonASP a bare `Stream.Read` returns **`Empty`** instead of the bytes:

    Request.BinaryRead(n)      -> String, LenB = 160    OK
    stream.Write blk           -> stream.Size = 160     OK
    stream.Read                -> Empty, LenB = 0       BROKEN
    stream.Read(-1) / Read(Size) -> String, LenB = 160  OK

Classic ASP treats a bare `Read` as `Read(adReadAll = -1)`. The result: every field of
every multipart form came back empty, with no error raised — profile edit reported
"旧的密码错误" with the correct password, and **posting from a real browser silently did
nothing**, because the `a2.asp` post form is `enctype="multipart/form-data"`. (The
earlier urlencoded curl/fetch tests took a different code path, which is why this hid
for so long.) Fixed the three bare binary reads: the multipart parser, the attachment
download stream in `a/file.asp`, and the canvas image bytes in `User/inc/canvas.asp`.
Every browser suite now posts through the real form, so the multipart path is exercised on
each run rather than by a single dedicated check — `01-core` posts a topic and a reply that
way, and `24-attachment` carries a real image through it.


### 21. Windows path separators in application-built paths

Paths that LeadBBS assembles itself (rather than getting from `Server.MapPath`) use `\`:
`GBL_UploadDir & "\" & FileName`. On Linux that is a legal *filename character*, so the
upload row was written to the database and the "file" landed as a single name containing
backslashes — attachments and avatars appeared to upload but nothing was ever readable
back. Fixed 10 separators in `a/inc/Editor_Fun.asp` and `User/UserModify.asp`.


### 22. Numeric timestamps render in scientific notation (extension of §15)

`GetTimeValue(DEF_Now)` yields a 14-digit number. Concatenated into a string, AxonASP
renders it `2.0260725002634e+13`, and LeadBBS slices it with `Left(...,14)` / `Mid(...,9,2)`
to build filenames and parse dates. 34 such sites now go through a `LngStr()` helper
(`inc/Str_Fun.asp`) that forces a plain integer string.


### 23. `ChrW`/`Chr` do not coerce a numeric *string* argument

`Chrw("97")` returns `Chr(0)` instead of `"a"`. `DecodeCookie()` rebuilds the auth cookie
from string parts, so the decoded username came back as NULs, `GetUserNamePassword`
concluded the session belonged to someone else and destroyed it — i.e. every "remember me"
login logged you straight back out. Fixed with `Chrw(CLng(...))`.


### 24. `DateAdd` argument order is not forgiving

`DateAdd("d", DEF_Now, 7)` (number and date swapped) is tolerated by IIS but computes a
date in 1683 here, so the auth cookie was written already-expired. Corrected at 8 sites.


### 25. `IsNumeric(Empty)` is `False` (VBScript says `True`)

An uninitialised global used as a form default therefore failed validation. This made
**board creation impossible** from the admin UI: `ForumBoardJoin` has no OrderID field, so
`GBL_OrderID` was `Empty` and every submission was rejected. Fixed by initialising it to 0.


### 26. `FormatNumber` does not coerce a numeric *string*

`FormatNumber("20260725002844", 0)` returns `"0"`. The same class of bug as §23, and it was
a landmine inside the `LngStr` helper added for §22 — which is now used at ~380 sites and
would have silently rendered `"0"` for any string input. `LngStr`/`RestoreTime` now do
`FormatNumber(CDbl(v), 0)`.


### 27. Duplicate column names in a `SELECT` collapse — *ordinal* access returns the wrong field

The largest-blast-radius bug found so far. AxonASP resolves `Rs(n)` and `GetRows()` columns
**by name**, so when a query returns two columns with the same name, both ordinals yield the
**last** one:

    select 11 as ID, 22 as ID, 33 as Other
    IIS/ADO   ->  Rs(0)=11  Rs(1)=22  Rs(2)=33
    AxonASP   ->  Rs(0)=22  Rs(1)=22  Rs(2)=33      (Fields.Count is correct: 3)

LeadBBS joins `LeadBBS_Announce as T1` to `LeadBBS_User as T2` and selects **both** `T1.ID`
and `T2.ID` (and `T1.UserName` / `T2.UserName`) in one 57-column list, then reads everything
positionally. So column 0 — the post id — silently became the *author's user id* on every
post-list page. Symptom: the per-post 编辑 / 管理 / 删除 links and the batch-select checkboxes
all carried `ID=<userid>`, so post moderation from the topic page targeted a nonexistent row
and did nothing. Fixed tree-wide by aliasing the later duplicate (`T2.ID as id_dup2`), which
keeps every ordinal in place and makes name lookups resolve to the first field, as ADO does:
**23 files, 41 SELECTs**. `test/browser/04-admin.mjs` now asserts the link carries the post id.

**The sweep missed two files, and it took a user report to find out.** The original pass
grepped for `select … from`, but LeadBBS also builds a query out of a *column-list variable*:

    b/inc/Board_fun.asp:237   class_selcolumn = "T1.id,…,T1.UserName,T1.UserID,…,T2.UserName,T2.ID,…"
    b/inc/SmallList.asp:32    class_selcolumn = "T1.id,…,T1.UserID,T1.TitleStyle,T2.UserName,T2.ID,…"

There is no `select` keyword on either line, so neither matched. These two feed **the board's
topic list** — the most-used page on the forum — and every topic link on it carried the
author's user id instead of the post id, so clicking any of them said
*指定的帖子不存在或已被删除。* It survived a 22-suite, 436-check pass because **the suites run
as `admin`**, and the admin path serves that list from `b/inc/cache_fun.asp`, whose copy of the
same query *had* been aliased. Only a logged-out reader or a new member ever saw it.

Re-swept with a scanner that parses the column list before `FROM` in both forms — string
literals *and* `class_selcolumn`-style variables — and the tree is now clean (the only
remaining name repeats are `ORDER BY` mentions, which are harmless). `23-reader-view.mjs`
asserts, as a guest and as a fresh member, that every `a.asp?…&id=` link the forum offers on
six different list pages resolves to a real `LeadBBS_Announce` row and to no `LeadBBS_User`
row; with the aliases removed it fails 11 checks.


### 28. Calling an **undefined** Sub/Function silently does nothing

    NoSuchSub("x")            IIS: "Type mismatch" / "Object required", page stops
                              AxonASP: no error, no output, execution continues
    v = NoSuchFn("y")         AxonASP: v is Empty

This one is *forgiving*, but it is the enabler for the whole family of "the button does
nothing" bugs in this port: a missing include, a typo'd routine name, or a helper defined
in a file the page doesn't pull in all fail invisibly instead of announcing themselves.

To find the rest, `test/deadcalls.py` resolves every `#include` recursively to build each
page's closure, collects the routines defined in it, and flags statement-position calls to
names that aren't there. Real hits found and fixed: `mini/Default.asp` called
`GetBoardIDValue()` (a typo for `Borad_GetBoardIDValue`). Two remaining hits are upstream
defects that break harder on IIS than here, so they are documented rather than changed:

- `Boars_Side_Box` is defined in `Boards.asp` but called from `inc/Board_Popfun.asp`. It
  is unreachable unless the board sidebar setting is on; with it on, `b/b.asp` would 500
  on IIS and merely lose the box here.
- `DisplayUserNavigate` is defined only in `manage/inc/bbsmanage_fun.asp` but called from
  7 `User/` pages, which don't include it. Those pages lose a heading here; on IIS they
  would fail outright.

Related, and the reason a bare statement call is the dangerous form: §9 — a module-level
Sub called as a bare statement **from inside a Class body** raises 800A01B6 and needs
`Call`. That broke every `mini/` (mobile) board URL with a 500 until the class bodies were
swept tree-wide.


### 29. Case-sensitive routing applies to **directories**, not just file names

`make-compat-symlinks.sh` originally aliased only file names, so a URL whose *directory*
component was spelled differently still 404'd. mini/'s registration form posts to
`../user/Register.asp` while the directory is `User` — signing up from the mobile UI was
impossible. The script now aliases directories in both cases too (121 aliases). Both the
file and directory aliases are committed, so a fresh clone serves every internal link;
re-run the script after adding files.

`test/browser/07-links.mjs` guards this: it loads the real pages, harvests every
same-origin `href`/`src`/`action` the application emits, and fetches each one.


### 30. `Recordset.GetString` ignores its delimiter arguments

    rs.GetString(,, "|", "#", "")      IIS/ADO : 1|2#3|4#
                                       AxonASP : 1<TAB>2<LF>3<TAB>4<LF>

Only the ADO *defaults* are implemented; ColumnDelimiter, RowDelimiter and NullExpr are
accepted and discarded (the omitted-argument and explicit-argument forms behave the same).
LeadBBS uses those delimiters to emit JavaScript row callbacks —
`s("a","b",…);` per record — so with the delimiters dropped the whole result set collapsed
into one malformed call and the list rendered **nothing**. That silently emptied five
admin pages: the forum log, template manager, style-parameter editor, board-category
manager and the mail list. `inc/Str_Fun.asp` now provides `RsGetString(Rs, ColDelim,
RowDelim, NullExpr)`, which loops the recordset and honours the delimiters (appending the
row delimiter after every row, including the last, as ADO does); the five call sites use
it. The forum log went from 0 rendered rows to 282.


### 31. A changed `#include` may keep serving the old code — and it is not the bytecode cache

Editing an `#include`d file can leave pages that include it running the **old** code, so a fix
appears to have no effect and you go chasing a bug you have already fixed. It bites hardest
right after installing (the installer rewrites `inc/BBSSetup.asp`) and whenever the admin panel
regenerates `inc/*_Setup.asp`.

**It is more specific than "includes are never noticed", and the obvious remedies do not work.**
Measured on 2.3.5, with a minimal probe page and a one-line include:

| | |
|---|---|
| page includes the file **directly** | edit **is** picked up on the next request |
| page includes it **through a symlink** | edit is **not** picked up until restart |
| `bytecode_caching_enabled = "disabled"` | does not help — so this is not the bytecode cache |
| clearing `<axonasp>/temp/cache` while running | no effect; the live cache is in memory |
| `touch`ing the including page | no effect; mtime alone does not invalidate |

The symlink result matters here because `make-compat-symlinks.sh` creates a lowercase alias
beside every mixed-case file, and LeadBBS includes several of them by their aliased spelling —
`Boards.asp` includes `inc/BBSsetup.asp`, which is an alias for `inc/BBSSetup.asp`. Deleting
that alias did **not** restore live reloading for this file, though, so the symlink is not the
whole story and the exact rule is not established. What is reproducible is the table above and
the practical consequence:

**Restart the server after anything rewrites an include** — after installing, and after changing
settings in `manage/`. It takes about two seconds and touches no data:

```sh
systemctl restart leadbbs        # or: kill the process and re-run ./start-server.sh
```

`clean_cache_on_startup = true` (the shipped default) makes the restart sufficient.

### 32. VM-pool deadlock: the server stops executing scripts (root-caused)

Symptom, after a long run: `a/a.asp` renders as a **guest** while `Boards.asp` in the same
session is still logged in; the avatar upload POST returns 200 with an **empty body**;
eventually every ASP request times out although the process is alive and `/debug/pprof/` still
answers. `SIGTERM` will not stop it — it needs `SIGKILL`.

`/opt/axonasp/temp/error.log` (which survives restarts, unlike the console log) has the cause:

```
[4011] Script timeout reached and execution goroutine was detached (60s)   Boards.asp   x10
```

Ten detachments, at the exact minute the reproduction hung, against `vm_pool_size = 10`. **A
detached goroutine keeps its VM pool slot** — the goroutine dump shows all ten still parked in
`asp.(*Application).WaitForServer`, with 14 more queued in `acquireVMPoolSlot`, 12 of those
inside `GlobalASA.ExecuteSessionOnStart`. Once every slot is burnt the pool is empty for good,
and a client with no session needs a slot *before its page starts*, which is why a fresh
browser context made it worse. Each leaked slot makes the next request likelier to time out, so
a slow minute becomes a permanent hang.

What made requests slow enough to time out is a genuine leak: AxonASP retains **~5 MB of
permanently-live heap per distinct page path** ever served (measured: 25 new paths = +131 MB;
the same 25 again = +11 KB), and `golang_memory_limit_mb` was 256 with the process pinned at
253 MB — permanent GC pressure, the failure AxonASP's own manual describes. Ordinary browsing
touches a few dozen paths and is flat; it is **whole-site crawls** (the 170-page sweep,
`07-links.mjs`, the coverage census) that multiply breadth until the ceiling is hit — and each
of the 309 case-alias symlinks (§29) is a separate cache key.

Mitigated by `golang_memory_limit_mb` 256 → 1024 → **3072** and `vm_pool_size` 10 → 24. The
ceiling scales with the number of *distinct paths* a run touches, so it had to be raised again
once the suites grew: at 1024 the link crawler reached the deadlock outright (111 detached
goroutines in `error.log`) and wedged the server. Load matters as much as the limit —
`07-links` also had to drop from two concurrent fetchers to one, which took it from ~45 of
~200 URLs answering 5xx by the end of the crawl to zero. Raising
`default_script_timeout` instead is worse: a hung request then blocks for that long and the
navigations time out. It recurred twice
more and each time confirmed the mechanism: once the detachment count rose by **exactly 24**, a
poolful; the second time it happened at only 320 MB, showing that heap pressure is merely one
route to a slow request, not the mechanism. Since there is no in-process recovery,
`test/browser/run-all.sh` now gives **every suite a freshly started server**, and verifies the
restart really happened — a deadlocked AxonASP ignores SIGTERM, so the replacement can fail to
bind while the old wedged process keeps answering, which looks like success and poisons the
rest of the run. With that, a full run is clean (now 22 suites, **435 checks, 0 failures**). **This is a
mitigation, not a repair** — the retention and the slot leak are both upstream, and the
deadlock is a race, so a clean run does not prove absence. Operationally: **restart after any
full-site crawl**.

**It then happened in production, at thirty-one requests.** Everything above was measured under
whole-site crawls, which made "restart after a full-site crawl" sound like sufficient advice. It
is not. On 2026-08-01 the public demo — an idle forum behind a TLS proxy — stopped serving. The
process was alive and still holding port 9596, so `Restart=always` never fired and the site
returned 502 until a human noticed. `axonasp.log` held **exactly 24** detachments against
`vm_pool_size = 24`.

Because every request reaches that deployment through the reverse proxy, its access log is the
*complete* traffic record, and it lines up request-for-request with the AxonASP log — each
`Script timeout` fires exactly 60s after its request began:

| burst | requests | timeouts | pool consumed |
|---|---|---|---|
| 21:51 | 8 | 8 | 8 |
| 22:12 | 12 | 12 | 20 |
| 22:17 | 10 | 4 | **24 — empty** |

Thirty-one requests over twenty-six minutes, roughly one every fifty seconds, from a scraper on a
dozen OVH addresses hitting six ordinary URLs (`User/help/help.asp`, `Search/Search.asp`,
`mini/default.asp`…). The third burst yielded only four timeouts because by then there was no
slot left to time out in. Meanwhile `sar` recorded **93% idle CPU and 38% memory** for the
outage window, and MariaDB had a 4.5-day uptime with `Aborted_clients = 0`. Nothing was starved:
the machine sat idle while the server served nothing.

**The trigger is not known**, and the following are ruled out by measurement rather than
argument, so nobody repeats them:

- *Client disconnects.* The proxy logged 30 of the 31 requests as `499`, but that is the
  consequence — the client gave up at 10s while the script ran on to 60s. Five sequential and
  forty concurrent deliberately-aborted requests produced **zero** detachments.
- *Concurrency.* Fifty simultaneous requests to those same URLs: all `200`.
- *Cold compiles racing on the case-alias symlinks (§29).* Twelve never-compiled pages fired at
  once against a freshly started server: all served, ~1.2s each.
- *A connection leak.* AxonASP holds no persistent MySQL connections at all — `Threads_connected`
  never moved off 1 across sixty requests.
- *Replaying the outage.* The recorded burst, replayed through the real proxy path with the same
  cadence and the same 10s client give-up, against a freshly started server: all `200`, no
  detachments.

That last one is the useful negative: the same traffic that killed a server with days of uptime
is harmless against a fresh one, so whatever accumulates is a function of uptime, not of load.

**So run a watchdog, not just a supervisor.** `Restart=always` is blind here by construction — the
process never exits. [`leadbbs-healthcheck.sh`](../leadbbs-healthcheck.sh) probes `Boards.asp`
every minute, restarts after two consecutive failures, and — because the process is being killed
anyway — first sends **`SIGQUIT`**, which the Go runtime answers even when the ASP workers are
wedged (`SIGTERM` does not: the graceful-shutdown path blocks on the same pool). With
`GOTRACEBACK=all` in the unit file that dumps every goroutine stack into the log, so the next
occurrence arrives with its own evidence and no `pprof` endpoint has to be exposed. Measured
recovery, failure to serving: about 65 seconds.

Full analysis, measurements and the dump:
[`docs/axonasp-32-vm-pool-deadlock.md`](docs/axonasp-32-vm-pool-deadlock.md),
[`docs/axonasp-32-goroutine-dump.txt`](docs/axonasp-32-goroutine-dump.txt). Driver:
`test/repro32.mjs`.


### 33. `FileSystemObject` caches a folder's listing

`GetFolder(dir).Files` returns the snapshot taken at the **first** enumeration of that folder
in the process's lifetime. A file created afterwards is invisible to the listing — and so is
`Files.Count` — until the server restarts:

    data/backup   3 files on disk    FSO enumerated 1
    inc/ruffle    8 files, then a 9th added    FSO still enumerated 8

`FileExists`, `GetFile(...).Size` and reads are **not** affected; only enumeration is.

That broke the SQL backup UI in a way that curl could never show: you could export a dump and
then neither download nor delete it, because the listing that offers those links only knew
about the folder as it was earlier. `manage/Database/BackupDatabase.asp` now keeps its own
manifest (`data/backup/index.txt`), appended on export and consulted for the listing, with each
entry stat'ed live via `FileExists`/`GetFile`; the stale enumeration is still merged in so files
created before the manifest existed are not lost. Guarded by `test/browser/13-adminflows.mjs`,
which exports, downloads, deletes and asserts the file is really gone (404).

Worth reporting upstream along with §32.


### 34. `Response.Write (X) & Y` silently drops the `& Y`

    Response.Write (a & "") & "|TAIL"     IIS: AAA|TAIL      AxonASP: AAA
    Response.Write a & "" & "|TAIL"       both: AAA|TAIL
    Response.Write ((a & "") & "|TAIL")   both: AAA|TAIL

The parentheses are only grouping in VBScript, but AxonASP treats the parenthesised group as the
whole argument and discards everything concatenated after it — **silent output truncation**.
LeadBBS itself never uses the form (the only two occurrences in the tree are commented out), so
this cost the port nothing; it bit the loopback SQL oracle in `test/browser/helpers/q.asp`, whose column
separator vanished and made two-column results unparseable. Worth reporting upstream.


### 35. A dimensioned array declared as a `Class` member gets the wrong bounds

`Public DT(5,4)` inside a `Class` does not allocate a 6×5 array. AxonASP shifts the bound
list: dimension 1 gets `0`, dimension 2 gets the **first** declared bound, and the last one is
dropped. A one-dimensional `Public One(5)` comes out with `UBound = 0`.

```asp
Class T
  Public One(5)      '  UBound(One)    -> 0   (VBScript: 5)
  Public Two(5,4)    '  UBound(Two,1)  -> 0   (VBScript: 5)
End Class            '  UBound(Two,2)  -> 5   (VBScript: 4)
```

So every element outside the first row raises *Subscript out of range* — including from
`Class_Initialize`, which makes `New` itself fail. A module-level `Dim MT(5,4)` is correct;
only the class-member declaration is wrong. Workaround: declare it bare and size it in the
initializer — `Public DT()` + `ReDim DT(5,4)` — which allocates the real bounds.

Two files were affected, and both were completely dead: the extended-skin manager
(`manage/SiteManage/inc/skin_fun.asp`, `Public DT(5,4)`) 500'd the whole
*编辑风格参数* page, and the CMS channel editor (`article/inc/center_setchannel.asp`, six
`Private form_type(16)`-style fields) 500'd *设置栏目内容*. Guarded by
`test/browser/16-adminsetup.mjs` and `test/browser/21-cms.mjs`.


### 36. LF-only data files break `Split(content, VbCrLf)` — the CMS home page was empty

Not an AxonASP bug: a consequence of this port normalising the whole tree to LF (and of any
Linux editor doing the same). LeadBBS parses several of its own on-disk data files by
splitting on `VbCrLf`; against an LF-only file that returns **one** element, so every record
collapses into the first and its trailing field swallows the rest of the file.

The CMS home-page channel list (`article/inc/cache/home_channellist_*.asp`, records of
`type#~#^#title#~#^#count#~#^#id#~#^#flag#~#^#style`) is parsed that way in two places. The
editor 500'd with *Type mismatch* — `cCur("7\n999#~#^#…")` — and `CMS_HOMECONTENT_MakeFile`
produced an empty channel block, so the generated cache file fell back to its
"nothing configured" branch and **`/index.asp` silently redirected to the forum** instead of
rendering the CMS. Fixed with `SplitLines()` in `inc/Str_Fun.asp`, which accepts CRLF, CR or
LF, at both parse sites.

`.gitattributes` now normalises on commit as well, because the application writes CRLF back:
without it every admin action that regenerates an include (`inc/IncHtm/*`, `inc/*_Setup.asp`,
`inc/js/ad.js`, `User/inc/User_Reg.asp`) showed up as a whole-file diff.

While fixing this, one upstream defect in the same path was corrected: the empty-channel
fallback bakes a **relative** `Response.Redirect Rw_boards(0)` into a cache file that *every*
CMS page includes, so *更新缓存* in the CMS admin resolved it against `article/` and answered
**404**. It is now scoped to the home page and root-relative.


### 37. A `String` operand never compares numerically, and `>` in an `If` condition is always False

Two separate defects in one expression, both silent. VBScript converts a numeric string to a
number when the other operand is numeric; AxonASP compares as **text**:

```asp
s = "60"
x = (s > 500)          '  IIS: False (60 > 500)      AxonASP: True  ("60" > "500")
```

And a `>` comparison used **directly as an `If` / `ElseIf` condition** evaluates False no
matter what the operands are:

```asp
s = "1000"
If s > 0    Then …     '  IIS: taken     AxonASP: NOT taken
If s > 500  Then …     '  IIS: taken     AxonASP: NOT taken
If "b" > "a" Then …    '  IIS: taken     AxonASP: NOT taken
x = (s > 0) : If x Then …                '  works — evaluate it first
If s > 0 And True Then …                 '  works — a sub-expression of a larger term
```

`=`, `<>`, `<`, `<=` and `>=` in condition position follow the (still wrong) *string*
comparison rather than always-False, so `If s >= 500` is False for `s = "1000"` too.
Workaround: make the operands numbers — LeadBBS's own `toNum(v, default)` is the safe form,
since `cCur("")` raises a type mismatch.

LeadBBS is mostly immune because it coerces form input (`FormClass_CheckFormValue(…, "int", …)`
returns `Fix(cCur(…))`, `toNum`, `cCur(Fix(…))`) before comparing. A tree-wide scan for
`If <var> > …` where the nearest assignment to `<var>` was an uncoerced string expression left
exactly one victim: `manage/SiteManage/inc/skin_fun.asp`, where `StyleID` comes straight from
`GetFormData`. Every extended-skin edit answered *参数不足．*, every delete answered
*因意外操作中止．*, and the stylesheet never loaded into the edit form (`If DT(0,4) > 0`).
Fixed by coercing at the reads. Worth reporting upstream along with §32/§33/§35.


### 38. Bare `Request.QueryString` stringifies differently inside a string function

`Request.QueryString` with no key is an object. Classic ASP gives you the raw query string
wherever a string is wanted; AxonASP does that for **concatenation**, `CStr()` and
`Response.Write`, but a string *function* gets the object's debug repr instead:

```asp
' request is /page.asp?abc=1&d=2
x = "?" & Request.QueryString      ' both: "?abc=1&d=2"
Response.Write Request.QueryString ' both: "abc=1&d=2"
CStr(Request.QueryString)          ' both: "abc=1&d=2"
Left(Request.QueryString, 4)       ' IIS: "abc="      AxonASP: "[Nat"
Len(Request.QueryString)           ' IIS: 9           AxonASP: 19  (len "[NativeObject:1001]")
InStr(Request.QueryString, "dir=") ' IIS: found       AxonASP: never
```

12 sites across 10 files, and the two most damaging were dispatchers:
`User/UserTop.asp` and `Search/List.asp` both select their mode with
`Left(Request.QueryString, 1)`, which became `"["` — so **every** ranking tab
(积分/经验/灌水/新入用户/查找用户/版面排行) fell through to the same default page, and the
search list always used the same root flag. `inc/Board_Popfun.asp` built its "return to this
page" URL from it, so pages emitted links like `LookUserInfo.asp?[NativeObject:1001]`.
Fixed by using `Request.ServerVariables("QUERY_STRING")`, which is identical on IIS.


### 39. `Eval()` cannot see a module-level global from inside a routine that has locals

`app/leadbbs/default.asp` stores each 徽章's award rule as a VBScript expression
(`datediff("d",applytime,DEF_Now)>=3650`) and runs it with `Eval`. `applytime` is a local of
the enclosing routine and `DEF_Now` is a module-level global from `inc/BBSSetup.asp`; AxonASP
fails the eval unit's **compilation** with *Variable not defined: 'DEF_Now'*, so the whole
badge page 500'd — but only for a logged-in user, since a guest never reaches that branch,
which is exactly why a curl sweep never saw it.

Eval scoping is not broken in general — a global, a `Const`, a `Function`, a routine local
and a class field are all resolvable from `Eval` in isolation — so this is a narrower
interaction than "Eval has no scope". Worked around by substituting the values into the
expression before evaluating it, which is a no-op on IIS.


### 40. Reflected XSS on the error landing page (an upstream defect, not AxonASP)

`Global_ErrMsg(Str)` writes its argument with `<%=Str%>` — deliberately, because almost every
caller hands it markup (the "please log in" message embeds a link). One caller passes it
straight off the URL:

```asp
Case "err": Global_ErrMsg(Request.QueryString("err"))     ' User/Login.asp
```

`ErrorJump()` redirects there with the message in the query string, so
`/User/Login.asp?action=err&err=<script>…` reflected whatever was asked for. Escaped at that
one call site (`htmlencode(Left(...,500))`), which leaves the internal callers' markup intact.
`22-misc` asserts both halves: the message a real redirect carries is shown, and injected
markup comes back as text.


### 41. Several built-ins get a slot index instead of the value when passed a bare variable

The captcha was a **blank white rectangle** — `User/number.asp` returned a structurally valid
90×27 GIF with a correct palette and no pixels a human could read, so nobody could register or
post. Untangling it turned up one divergence family with a wide blast radius.

**`Int`, `Abs`, `Sqr`, `Exp`, `Log`, `Sin`, `Cos`, `Tan`, `Atn` and `Round` do not read their
argument when it is a bare variable.** They receive what looks like its storage slot:

```asp
g = 4
Int(g)   ' IIS: 4        AxonASP: 330
Abs(g)   ' IIS: 4        AxonASP: 330
Sqr(g)   ' IIS: 2        AxonASP: 18.1659…   (= sqrt(330))
Int(g+0) ' IIS: 4        AxonASP: 4          — an EXPRESSION is evaluated correctly
Int(4)   ' IIS: 4        AxonASP: 4          — a literal is fine
Fix(g), Sgn(g), CLng(g), CInt(g), Hex(g), Len(g) — all correct
```

Inside a routine the number returned is the argument's position, so `Int(p1)`, `Int(p2)`,
`Int(p3)` give 0, 1, 2. `Canvas.Pixel`'s setter began `lX = int(lX) : lY = int(lY)`, so **every
pixel ever written to that canvas landed at (0,1)** and the image stayed blank. Workaround:
pass an expression — `Int(x + 0)` — or use `Fix`/`CLng`, which are unaffected.

**The same family: a `Double` argument is silently rejected where VBScript coerces it.**
`String(n, c)`, `MidB(s, start, len)` and `RGB(r, g, b)` return `""` / `0` — no error:

```asp
String(1260, "A")   ' 1260 chars      String(1260.0, "A")   ' ""
MidB(s, 1, 3)       ' 3 bytes         MidB(s, 1, CDbl(3))   ' ""
RGB(255,255,255)    ' 16777215        RGB(a,a,a) with Doubles ' 0
```

`^` yields a Double, and so does `/`, so `String(lWidth * ((lHeight + 1) / 2), …)` produced an
empty pixel buffer and `2^iBits - 2` made `MidB` drop every chunk of raster data. `DecHex()`
returned a Double, so `RGB()` gave 0 and the captcha's white background came out black.

One more, in the same file: **AxonASP strings are byte strings** — `LenB()` equals `Len()`,
where classic ASP reports twice as many bytes for UTF-16. `Clear()` relied on the UTF-16
behaviour to allocate `w*(h+1)` bytes from `w*(h+1)/2` characters; it now detects which kind of
host it is on so IIS is unaffected.

`06-member` now asserts what a human sees: it draws the captcha to a canvas and requires real
ink on it. `naturalWidth > 20` was true of the blank rectangle for the whole of this bug.

A tree-wide sweep for the same shape found two more victims outside the image code, both
fixed the same way: `a/inc/MakeGoodAnnounce.asp` computes the points a 评帖 deducts and awards
— and the clamps that keep a rating inside `DEF_BBS_PrizeAnnouncePoints` — entirely through
`Abs()` of bare variables, so both the amounts and the range checks were nonsense; and the
MariaDB dump writer decides integer-vs-decimal formatting with `If v = Int(v)`.


### 42. `Dictionary` stores an array by reference, not a copy

```asp
arr(0) = "first"  : d.Add "A", arr
arr(0) = "second" : d.Add "B", arr
d("A")(0)   ' IIS: "first"      AxonASP: "second"
```

`User/inc/font.asp` builds each of its 37 glyphs in one module-level `Letter` array and
`Font.Add`s it, so under AxonASP all 37 entries aliased the same array and every glyph came
back as whatever the last letter left — all zeros. That is why the captcha drew its decorative
strokes but no characters. Storing a per-letter *object* did not round-trip either; each glyph
is now stored as its 31 rows joined with `|`, and `canvas.asp` reads a row back through a small
`FontRow()` accessor that caches the split.

(The fix also had to be parenthesised — `AddLetter("A")`, not `AddLetter "A"` — because the
helper is defined below its callers, which is §6 all over again.)


### 43. A backslash before a **non-ASCII** character is a fatal regex error

```asp
Set r = New RegExp
r.Pattern = "@([^\ ]{1,30})"      ' escaped ASCII space  — fine everywhere
r.Pattern = "@([^\　]{1,30})"     ' escaped U+3000       — IIS: fine
                                  '                       AxonASP: 800A1399
                                  '   error parsing regexp: invalid escape sequence: `\　`
```

VBScript's regex engine treats `\x` as a literal `x` for any non-word `x`. Go's `regexp/syntax`
— which AxonASP delegates to — allows that **only for ASCII**: escaping a rune ≥ U+0080 is a
parse error, and `RegExp.Pattern` raises it as a runtime error at the point of assignment.

`a/a2.asp:1613` excludes both space characters from an @-mention name with
`"@([^\ \　\.\""\'\[\]\(\)\<\>\&\\\/]{1,30})"`, so **every attempt to post a topic or a reply
blew up** — but only after the `LeadBBS_Announce` row had already been inserted. The poster got
an AxonASP error page for a post that really had been created, and everything below that line
never ran: the @-mention notifications, the attachment binding (`UpdateUpload`), remote-image
saving, and the redirect to the finished post. Combined with §27's broken links, a new member's
first experience was an error page, then a topic they could see in the list but could not open.

The fix is to drop the backslash and put the character itself in the class. `23-reader-view.mjs`
posts a topic containing `@admin` as an ordinary member and asserts both halves: no error banner,
**and** that the mention PM below the regex was delivered — the flow completing is not enough,
because the row got written either way.


### 44. An undecodable image aborts the request, because upstream commented out its own guard

```asp
Set MyObj = Server.CreateObject("Persits.Jpeg")
MyObj.Open(LoadFile)
if err Then ...        ' unreachable: nothing enabled On Error Resume Next
```

`inc/Upload_Fun.asp` opens every uploaded picture through `Persits.Jpeg` to build the
thumbnail, and both `GetPicInfo` and `SaveSmallPic` test `if err Then` immediately afterwards
— but the `On Error Resume Next` that would make those tests reachable ships **commented out**
(line 39, upstream). AxonASP emulates the component with its own imaging library, and a file it
cannot decode raises

    800A0033  AxonASP Error [11002] G3IMAGE: failed to load image from path
              | zlib: invalid checksum | File: axonvm/lib_g3image.go

which, with no error handling in scope, kills the request. As in §43 the announce row is
already written by then, so a truncated or unsupported picture produces a post plus a server
error page. Restoring the guard around the two `Open` calls (and turning it off again straight
after) makes the upload degrade the way the author intended: `GBL_FileType = 2`, no thumbnail,
post proceeds. Found by accident, when a corrupt test fixture crashed a suite instead of
failing it.

**Enable it and do not turn it off again**, which is what the commented-out upstream line
meant. The first version of this fix paired each `On Error Resume Next` with an
`On Error Goto 0`, and that broke `article/center.asp?action=updatecache`: the CMS calls
`SaveSmallPic` with its *own* handler enabled, and disabling on the way out stripped the
caller's protection from a pre-existing `Save`-after-`Close` further down the same function
(`800A0033 … image context not initialized`). Suite 21 caught it. VBScript restores the
caller's error state when a procedure returns, so enabling without disabling is both safer and
closer to the original.


### 45. Attachments over 2 MB vanished silently (an upstream defect, not AxonASP)

Three upstream decisions combined into one invisible failure, reported by a user who attached a
2.2 MB photo and got a post with no picture and no message:

- `Upload_File` caps **images** at a hardcoded `2097152` — separate from, and far below,
  `DEF_FileMaxBytes`;
- the post form advertises only `DEF_FileMaxBytes` (`8024K` here), so nothing on screen hints
  that a 2.2 MB photo will be refused;
- the refusal text goes into `Upd_ErrInfo`, which is printed on the *confirmation* page — and
  `a2.asp` ends with `If UpdateFlag = 0 Then Response.Clear : Response.Redirect …`, so unless
  the poster happened to gain a level on that post, the page carrying the message was
  discarded before it was sent.

Fixed on all three counts: the cap is now the named `DEF_ImageMaxBytes` (defined in
`a/inc/Editor_Fun.asp`, **not** in `inc/Upload_Setup.asp`, which
`manage/SiteManage/UploadSetup.asp` regenerates from a fixed template and would silently drop
it from); the form states both limits; `upl_onchange` measures the file with the File API and
refuses it with a clear message *before* the post is made; and the redirect is skipped when
there is something to tell the poster. `24-attachment.mjs` covers all four, and asserts the
in-limit case by measuring the image's rendered width in a guest's browser — the check the old
1×1-transparent-GIF fixture in `03-features` could never make.

### 46. Every reply became a new topic: an id rendered as `2.26151e+06`

The extension of §15/§22 that mattered most, and the one that hid the longest. `a/a.asp` builds
the topic page's reply form with

```asp
A_ID = cCur(A_ID)                                   ' a Currency
<input name="ID" value="<%=A_ID%>" type="hidden" />  ' AxonASP: value="2.26151e+06"
```

Under IIS that prints `2261510`. AxonASP switches to scientific notation once the value passes a
million, so the browser posted `ID=2.26151e+06`, `a2.asp` could not parse it as an announce id,
`Re_ID` fell back to `0` — and the reply was stored as **a brand-new top-level topic**:
`ParentID = 0`, its own `RootIDBak`, and the parent's `ChildNum` left at `0`. Every reply, from
the moment the port started working. The same value leaked into the *回复此主题* link and into
`Get_MobileUrl`'s `id=` parameter.

The port already had `LngStr()` for exactly this; it simply had not been applied to id emission.
Sixteen sites across `a/a.asp`, `a/a2.asp`, `a/EditAnnounce.asp`, `a/Processor.asp` and the four
`a/inc/*Announce.asp` dialogs now go through it, plus `inc/Board_Popfun.asp`.

**Why the suite missed it for so long** is the more useful half. `01-core` asserted that the
announce count went up and that the reply text appeared on the page — both true of a reply that
had been silently turned into its own topic. And it posted to `a2.asp?ID=…`, whose *query string*
carried a clean id, rather than through the reply form on the topic page that a reader actually
uses. Both gaps are now closed: the suite posts through the topic page's own form and asserts
`ParentID`, `RootIDBak` and the parent's `ChildNum`; and `04-admin` sweeps eight pages asserting
that **no id is ever rendered in scientific notation**, which fails on the pre-fix tree.

**A straggler found in production**, long after that sweep, is worth recording for what hid it.
`User/LookUserInfo.asp` printed `更多关于第[2.361371e+06]号在线人员的信息` — the same `cCur` →
string leak, in the *online member* heading. Neither the sweep nor `04-admin`'s eight-page check
caught it, because three conditions have to hold at once before the page renders that heading:
the viewer must **not** be a supervisor (a supervisor takes the username branch, unless the
subject is a guest, which is the other way in), the subject's row in `LeadBBS_onlineUser` must
still exist, and the id must be past a million. Every suite ran as the admin, and every fixture
had **two-digit online-user ids** — that table is auto-increment, so a database minutes old
cannot reach the failing range while a forum years old is already past it. Reproducing it needed
`ALTER TABLE leadbbs_onlineuser AUTO_INCREMENT = 2361371` and a second, non-supervisor account;
both are now in `test/fixtures/seed.sql` and `02-user`, along with a check that fails loudly if
the fixture's ids are ever too small to fail. This is the
[coverage-gaps](coverage-gaps.md) lesson in a new costume: **a fixture that cannot reach the
failing state cannot fail.**

### 47. Avatar upload is broken on every fresh deployment (an upstream defect)

`GetSaveFileName` creates the year and month folders under the upload directory, but requires
the *base* directory to already exist:

```asp
TDir = Server.MapPath(PhotoDirectory) & "/"        ' images/upload/face/
If Not FS.FolderExists(TDir) then
    GetSaveFileName = 0
    Upd_ErrInfo = ... "附件存放目录错误，请联系站长!"
End If
```

`images/upload/face/` is not in `leadbbs92.zip` — a zip cannot carry an empty directory — so on
a new install the first avatar upload takes that branch. The row was still written, pointing at
a file that had never been created: a broken image beside every post by that user, and a 404 in
the link crawl. `FileSystemObject.CreateFolder` makes exactly one level and raises if the parent
is missing, which is why the existing year/month loop could not cover it.

Fixed with an `EnsureFolder` helper that walks and creates each missing level, and by shipping
the directories with a `.gitkeep` so even the first upload on a clean checkout works. The call
needed `Call EnsureFolder(TDir)` rather than `EnsureFolder TDir` — §6 again, since the helper is
defined below its caller.

**Found by running the suite against a fresh `git clone` and an empty database**, which is what
a new user actually gets. Nothing on the development box could have shown it: those directories
had existed there since the first upload months ago.

### 48. An upper-case file extension made avatar upload fail with a bare "error"

```asp
tmpFile = Mid(FileName, inStrRev(FileName,".")+1)      ' "GIF"
If tmpFile = "gif" or tmpFile = "jpg" or ... Then      ' never true
    ...
Else
    Processor_Msg("error")                             ' the page shows just: error
End If
```

An upstream defect, and one that hits real users first: phones and cameras name files
`IMG_1234.JPG`, and the staging step of the two-part avatar flow compared the extension
**exactly**. Anything upper-case was rejected with an unexplained `error` — no message about
formats, nothing in the log.

`LCase()` on the extension fixes it. The suite now deliberately uploads `images/face/0001.GIF`,
upper-case, so the regression cannot come back.

Worth noting how it surfaced: it did not, for months, because the suite happened to upload the
*lower-case alias* of that same file. It only appeared when the test was changed to reference
the real committed filename while preparing a public release, and then only on a fresh clone —
the alias exists on any tree where `make-compat-symlinks.sh` has run.

### 49. Nobody could set their first avatar: the INSERT stored an absolute path

`CheckUploadDatabase` has two branches. The UPDATE branch — a user who already has an avatar —
trims the value down to what `LeadBBS_UserFace.PhotoDir` is meant to hold: `2026\07\26_x.gif`,
the part after `images/upload/face/`. The INSERT branch — a user setting their **first** avatar —
stored `Server.MapPath`'s absolute filesystem path instead.

`PhotoDir` is `varchar(100)`, so on a normal Linux deployment that is

    ERROR 1406 (22001): Data too long for column 'PhotoDir' at row 1

`LDExeCute` swallowed the error and the page still answered `upload_resetajax("ok")` — success
on screen, no avatar, nothing in any log. Any web root deeper than about forty characters hits
it; a shorter one "succeeds" and stores a wrong absolute path. Fixed with a `TrimFacePath()`
helper applied in the INSERT branch.

Three calls to that Sub were also parenthesis-less (`CheckUploadDatabase x, ""`), and it lives
in a different include — §6/§28 says AxonASP silently drops those — so they are now
`Call CheckUploadDatabase(...)`. An upstream debug `Response.Write` that printed a raw `UPDATE`
statement onto the avatar page went with them.

**This was invisible on the development box for the entire project**, because its admin account
had had an avatar row since the first upload, so only the UPDATE branch ever ran. It took a
pristine database to reach the other half of an `If`.

### 50. Our own LF normalisation silently disabled part of the installer

The installer patches two things into `inc/BBSSetup.asp`. The connection string goes in through
a whole-file rewrite and works. `DEF_InstallDir` — the base URL that eleven files build absolute
links from — goes through a targeted search-and-replace:

```asp
OldStr_start = "Const DEF_InstallDir =

### 51. Bare `Request.QueryString` is an Object, so comparing it to `""` is always true

```asp
Response.Write TypeName(Request.QueryString)      ' IIS: String     AxonASP: Object
Response.Write Len(Request.QueryString)           ' IIS: 0          AxonASP: 19
Response.Write (Request.QueryString <> "")        ' IIS: False      AxonASP: True   <-- always
Response.Write ((Request.QueryString & "") <> "") ' IIS: False      AxonASP: False  <-- correct
```

Under IIS, `Request.QueryString` with no key returns its default property — the raw query
string. AxonASP hands back the collection object itself, and comparing that to a string never
matches, so **every `If Request.QueryString <> "" Then` is taken**. Concatenating an empty
string forces the coercion and behaves correctly, which is why the many places that build URLs
with `& Request.QueryString` were fine all along and only the comparisons broke.

The expensive instance was the admin panel. `manage/default.asp` chooses between rendering the
whole backend **shell** — the top tab bar, the left navigation column and the content iframe —
and rendering just the inner panel that the iframe loads:

```asp
If Request.QueryString <> "" Then GBL_InPageFlag = 1 Else GBL_InPageFlag = 0
...
If GBL_InPageFlag = 1 Then Default_info() : Exit Sub
```

The flag was never 0, so the shell never rendered: `/manage/` showed the info panel with **no
navigation at all**, and every management page had to be reached by typing its URL. That is the
whole administrative interface missing, on every deployment, and it survived a 25-suite test
pass because the suites drive management pages by URL — exactly the way you cope with the bug.

Fixed at three comparison sites: `manage/default.asp`, `manage/User/SendMailList.asp` (its
`= "MailList"` test was always False) and `inc/Board_Popfun.asp` (always True, so it appended a
`?` to URLs that had no query string).

**And a second bug hid behind the first.** With the shell finally rendering, the nav column was
still empty, because line 129 is `<%Default_NavItem%>` — a parenthesis-less call to a Sub
defined 350 lines further down. §6 again: AxonASP silently drops those. `Call Default_NavItem()`
restores it. Two independent faults on the same feature, the second only visible once the first
was fixed.

### 52. Absolute URLs say `http://` behind a TLS-terminating proxy (a deployment fix)

`LD_GetUrl()` in `inc/Str_Fun.asp` builds the site's absolute URL from `SERVER_PROTOCOL` and the
`HTTPS` server variable. Put the forum behind nginx, BunkerWeb, Caddy or a load balancer — which
is how anyone terminates TLS — and AxonASP sees the proxy's plain HTTP request:

```
SERVER_NAME             = example.net
HTTPS                   = off          <-- so the scheme comes out http://
SERVER_PROTOCOL         = HTTP/1.0
HTTP_X_FORWARDED_PROTO  = https        <-- the proxy does tell us
```

So an `https://` site handed out `http://` links in @-mention private messages, RSS and the
"copy this post's address" control. There is no configuration for this: AxonASP has no
proxy-scheme option, and the value is computed per request rather than read from a setting.
`LD_GetUrl` now honours `X-Forwarded-Proto` when present and falls back to the old behaviour
when it is not, so a direct-to-port deployment is unchanged.
