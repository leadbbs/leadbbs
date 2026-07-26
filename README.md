# LeadBBS 9.2 on Linux

LeadBBS 9.2 is a Chinese-language Classic ASP forum from the mid-2000s, written for IIS,
VBScript and Microsoft Access on Windows. This repository runs it on **Linux**, on the
[AxonASP](https://g3pix.com.br/axonasp) Classic ASP engine, with **MariaDB** instead of Access —
no Windows, no IIS, no COM components.

It is the complete forum, not a subset: registration, posting, attachments, private messages,
polls, moderation tools, the admin backend, the CMS and the plugin set all work. What that took
is documented in full, because the most reusable part of this project is not the forum — it is
the **52 documented behavioural differences** between AxonASP and the VBScript/ADO semantics the
application was written against, each with a minimal repro:
**[docs/axonasp-divergences.md](docs/axonasp-divergences.md)**. If you are porting any Classic ASP
application to AxonASP, read that file first.

**History is deliberately two commits.** The first is `leadbbs92.zip` unpacked and untouched. The
second is everything this port changed. `git diff HEAD~1` is the entire port, auditable in one
view.

---

## Status

| | |
|---|---|
| Forum, user area, admin backend, CMS, plugins | working |
| Test suite | 25 Playwright suites, 482 checks, green |
| Coverage | 93.5% of executable files, 54/54 `action=` verbs (measured — see [docs/coverage-gaps.md](docs/coverage-gaps.md)) |
| QQ login, Alipay, outbound e-mail | **not working — see Limitations** |

## Quick start (release zip)

The zip attached to each [release](../../releases) is built by CI from a green test run.

Needs `bash`, `curl`, `unzip` and `python3` on the host (`python3` only for the alias script).

```sh
# 1. AxonASP (MPL-2.0). Pick the package for your distro from
#    https://github.com/guimaraeslucas/axonasp/releases
sudo dpkg -i axonasp_2.3.5_amd64.deb

# 2. MariaDB, with lower_case_table_names=1 — REQUIRED, see Configuration
sudo apt install mariadb-server
printf '[mysqld]\nlower_case_table_names = 1\n' | sudo tee /etc/mysql/mariadb.conf.d/99-leadbbs.cnf
sudo systemctl restart mariadb

# 3. An EMPTY database and a user for it. The installer creates the tables, but it does
#    not create the database or the account — it only connects to them. Pick your own
#    name and password; you type these into the installer in step 6.
sudo mariadb <<'SQL'
CREATE DATABASE leadbbs DEFAULT CHARACTER SET utf8mb4;
CREATE USER 'leadbbs'@'localhost' IDENTIFIED BY 'CHANGE-ME';
GRANT ALL PRIVILEGES ON leadbbs.* TO 'leadbbs'@'localhost';
FLUSH PRIVILEGES;
SQL

# 4. The forum
unzip leadbbs-9.2.0-linux.zip -d /srv/leadbbs && cd /srv/leadbbs
./make-compat-symlinks.sh                 # required after unzipping — see Configuration
cp axonasp.example.toml axonasp.toml      # then set web_root = "/srv/leadbbs/"

# 5. Make the directories the forum writes into writable by whoever runs AxonASP.
#    inc/ matters as much as the rest: the installer writes inc/BBSSetup.asp there, and
#    without it the install half-completes with no connection string.
chmod -R u+w inc temp images/upload images/temp data/backup
./start-server.sh

# 6. Open http://localhost:9596/ — it redirects to the installer.
#    On 配置数据库, SELECT MySQL FIRST: the form arrives with Microsoft Access preselected
#    and the MySQL fields hidden. Then enter localhost / 3306 and the user, password and
#    database name from step 3, and leave the driver on "Mysql ODBC 5.2 ANSI Driver".
#    On 配置管理 you choose an admin username and password — see the note below.
#    DELETE install/ afterwards.

# 7. RESTART the server. This is not optional and it is easy to mistake for a failed
#    install: the installer rewrites inc/BBSSetup.asp, but the running process keeps
#    serving the copy it compiled at startup, so every page carries on redirecting you
#    to the installer — which then says 论坛安装已锁定 because the install DID succeed.
#    Restart and the forum appears.
```

**Your admin password is also your security answer.** The installer asks for a username and a
password and nothing else, then stores the MD5 of that password in *both* the password and the
`answer` columns (`install/scripts/install_fun.asp`). The admin backend at `/manage/` demands
username, password **and** 问题答案 — so type the same password there. Getting it wrong gives
`此功能只有管理员才能操作[2]！`, which reads like a permissions error and is not one. Change the
answer afterwards from the backend's own user editor; the front-end profile page will not do it.

**Restart after anything rewrites an include.** That means after installing, and after changing
settings in `manage/` — the admin panel regenerates `inc/*_Setup.asp`, and those changes do not
take effect in the running process either. A restart takes about two seconds and touches no
data. Worth wiring up properly rather than doing by hand:

```ini
# /etc/systemd/system/leadbbs.service
[Unit]
Description=LeadBBS on AxonASP
After=network.target mariadb.service

[Service]
ExecStart=/opt/axonasp/axonasp-http -c /srv/leadbbs/axonasp.toml
WorkingDirectory=/opt/axonasp
Restart=always
# A wedged AxonASP (§32) ignores SIGTERM, so cap the wait before systemd escalates to SIGKILL,
# and let the runtime dump every goroutine when leadbbs-healthcheck.sh SIGQUITs it.
TimeoutStopSec=20
Environment=GOTRACEBACK=all

[Install]
WantedBy=multi-user.target
```

then `sudo systemctl restart leadbbs`. Pair it with
[`leadbbs-healthcheck.sh`](leadbbs-healthcheck.sh) — `Restart=always` alone cannot recover the
§32 wedge, because the wedged process never exits. The details of what is and is not picked up live are in
the divergence catalogue (§31); disabling the bytecode cache does **not** avoid it.

**Check the base path after installing:** `grep DEF_InstallDir inc/BBSSetup.asp` should show
your site's base URL — `"/"` for a root deployment. It is written by the installer, and eleven
files (mostly the CMS) build absolute URLs from it, so a wrong value produces 404 images and
links once you have content.

`GRANT ALL` on that one database is what the installer needs: it issues `CREATE TABLE`,
`INSERT` and `ALTER` inside it. It never needs a server-wide privilege, so do not hand it
`root`.

## From source

Steps 1–3 above are the same — you still need AxonASP, MariaDB with
`lower_case_table_names=1`, and an empty database with a user granted on it. Then:

```sh
git clone https://github.com/leadbbs/leadbbs && cd leadbbs
cp axonasp.example.toml axonasp.toml       # set web_root to this directory
chmod -R u+w temp images/upload images/temp data/backup
./start-server.sh                          # then open / and follow the installer
```

A clone needs no symlink step — the case aliases are committed. Re-run
`./make-compat-symlinks.sh` only if you add files.

Note that `inc/BBSSetup.asp` is **generated by the installer**, so after installing, `git
status` will show it modified. That is expected; do not commit your site's settings back.

## Configuration

Four things are not optional, and each fails in a way that is hard to diagnose:

- **`lower_case_table_names = 1` in MariaDB.** LeadBBS spells its tables in about five different
  cases (`LeadBBS_Boards`, `leadbbs_boards`, …) because MySQL on Windows does not care. On Linux
  it does: without this, most queries hit a table that "doesn't exist" and **return empty rather
  than erroring**, which looks like an empty forum rather than a broken configuration.
- **`web_root` in `axonasp.toml`** — absolute, with a trailing slash. `axonasp.example.toml`
  documents every setting this application actually needs, and why each one matters.
- **The case-alias symlinks.** AxonASP routes URLs case-sensitively; LeadBBS emits internal links
  in whatever case the author typed. ~1,130 alias symlinks make every emitted URL resolve. They
  are committed, and `git archive`/`tar` preserve them — but a plain `zip -r` **silently
  dereferences symlinks into copies**, which then breaks the ~30 files the application rewrites
  at runtime. If you repackage, use `git archive` or `tar`.
- **`inc/BBSSetup.asp` is written by the installer.** The repository ships it as upstream does:
  a stub whose first statement redirects to `install/default.asp`, so every page sends you to
  the installer until the forum is installed. After installing, that file holds your site's
  settings and connection string — expect `git status` to show it modified, and do not commit
  it back.
- **Both admin factors.** The backend needs the admin password *and* the security-question
  answer. A missing answer is refused with `此功能只有管理员才能操作[2]！`, which reads like a
  permissions problem but is not: `[1]` means the account is not in `DEF_SupervisorUserName`,
  `[2]` means the answer was wrong or empty.

## Limitations

An honest list; none of these are fixable without the third parties involved:

- **QQ social login** — Tencent retired the API. Kept only so it does not crash the pages that
  include it.
- **Alipay** — the payment endpoints are gone. The merchant credentials upstream shipped have
  been blanked.
- **Outbound e-mail** — needs the JMail COM component, which AxonASP does not provide. E-mail
  password recovery and the mailing-list page do not send. SMS (China Telecom) is likewise
  unconfigured.
- **Flash** — `flash_gold` runs on self-hosted [Ruffle](https://ruffle.rs) instead of the dead
  Flash plugin. `inc/ruffle/` is 28 MB, most of this repository's size.
- **Case-insensitive filesystems** — the alias symlinks differ from their targets only in case,
  so a checkout on macOS or Windows collapses some of them. Deploy on Linux.
- **A script timeout can wedge the server.** AxonASP 2.3.5 leaks a VM-pool slot on timeout; after
  `vm_pool_size` of them it stops executing scripts and ignores `SIGTERM`, while staying alive and
  holding the port (§32 in the divergence catalogue). The *mechanism* is root-caused — a detached
  goroutine keeps its slot — but the **trigger is not**: an idle public deployment hit it after
  **31 requests** on a 93%-idle machine, and replaying that exact traffic against a freshly
  started server does not reproduce it. Because the process never exits, `Restart=always` cannot
  see the failure. Run [`leadbbs-healthcheck.sh`](leadbbs-healthcheck.sh) on a one-minute timer;
  it probes, `SIGQUIT`s for a goroutine dump, and restarts. Measured recovery: ~65 seconds.

## Tests

```sh
bunx playwright install chromium
bash test/browser/run-all.sh          # ~40 min: 25 suites, server restarted between each
```

Playwright driving real Chromium is the only evidence this project accepts: a `curl` POST takes a
different code path from a browser's multipart form, and that difference hid a real bug for
weeks. Every check asserts a rendered artefact or a database row — an image must decode with
`naturalWidth > 0`, a deletion must remove both the row and the thing a reader sees.

Credentials come from `LEADBBS_ADMIN_USER` / `LEADBBS_ADMIN_PASS` / `LEADBBS_ADMIN_ANSWER`,
defaulting to the install defaults.

[docs/coverage-gaps.md](docs/coverage-gaps.md) records what is measured, what is deliberately not
covered, and the two ways this suite has been wrong — running everything as `admin`, and using a
fixture too small to fail. A green suite that cannot tell a bug from a fix is not evidence.

## Security notes for a real deployment

- **Delete `install/`** after installing. It is an unauthenticated web installer.
- **Delete `test/` and `docs/`.** The release zip already excludes them. `test/browser/helpers/`
  contains loopback-gated SQL and file-read endpoints for the harness — behind a reverse proxy,
  `REMOTE_ADDR` becomes the proxy's own address and that gate opens.
- **Rotate `DEF_DownKey`** in the admin panel; it guards attachment downloads.
- **The admin panel writes database backups into `data/backup/`, inside the web root**, and
  links them as ordinary static files — anyone who guesses a filename can fetch one, and a dump
  contains every password hash on the forum. **Download each dump and delete it** (the backup
  page says so too). You can block them wholesale by adding `".sql"` to `blocked_extensions` in
  `axonasp.toml`, but be aware that also breaks the panel's own download button, since it
  fetches the file over HTTP.
- **Change the admin password and security answer** from whatever you set during install if the
  site is reachable by anyone else.

## Documentation

These live in the repository; the release zip ships the application only.

| | |
|---|---|
| [docs/axonasp-divergences.md](https://github.com/leadbbs/leadbbs/blob/main/docs/axonasp-divergences.md) | the 52 AxonASP/VBScript differences, with repros — the reason this repo exists |
| [docs/coverage-gaps.md](https://github.com/leadbbs/leadbbs/blob/main/docs/coverage-gaps.md) | what is tested, what is not, and how it was measured |
| [test/README.md](https://github.com/leadbbs/leadbbs/blob/main/test/README.md) | running and extending the suites |

## Licence

The porting work is MIT ([LICENSE](LICENSE)). **LeadBBS itself is not free software**, and this
repository does not grant you rights to it — read [NOTICE](NOTICE) before deploying commercially
or redistributing. AxonASP is MPL-2.0 and is not redistributed here.
