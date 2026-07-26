# CI fixtures

`seed.sql` — schema plus the data the suites assume: boards, an admin account, topics, replies,
CMS categories. No personal data (all addresses are `@example.invalid`, all IPs loopback, the
activity log empty). Load into an empty database before running the suites.

`BBSSetup.ci.asp` — a **post-install** `inc/BBSSetup.asp` matching that database.

The repository ships `inc/BBSSetup.asp` as upstream does: a stub whose first act is
`Response.Redirect "install/default.asp"`, so a fresh deployment is sent to the installer, which
writes the real file. CI has no installer to run, so it copies this fixture into place and
substitutes `__CONNECTION_STRING__`. If you change site settings that live in `BBSSetup.asp`,
regenerate this fixture from a working install.

## One deliberate difference from a real deployment

`BBSSetup.ci.asp` sets **`DEF_RepeatLoginTimeOut = 0`**, where a normal install ships `300`.

That setting is the forum's anti-account-sharing guard, and its own description in
站点管理 says what it does: *"某人登录后，其它人则无法再进行登录．设成0或大于在线超时，则无效"* —
once somebody logs in, **nobody else can log in** for that many seconds. Every suite logs in as
the same `admin` account, and on a fast machine a whole suite finishes in seconds, so run after
run lands inside the window and the logins are refused. On a GitHub runner that produced nine
consecutive suites failing between 11:49 and 11:54 — five minutes, exactly the window — with
everything before and after green.

It is a deployment policy, not behaviour any suite is checking, so the fixture turns it off.
Real installs keep the default; nothing in the application changed.
