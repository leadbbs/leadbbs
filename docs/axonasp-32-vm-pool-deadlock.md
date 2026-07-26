# #32 — the "server degrades under a long run" hang, root-caused

For most of the port, §32 was an honest unknown: after a long test run the site would start
misbehaving in ways it never did in isolation, and only a restart fixed it. This is what it
actually is.

## Symptoms as seen from outside

- `/a/a.asp` renders as a **guest** — no 加入收藏 / 加入好友 links — while `/Boards.asp` in the
  *same* browser session still shows the user logged in.
- `/User/UserModify.asp` renders without its form fields.
- The avatar upload POST returns **200 with an empty body** instead of its
  `upload_resetajax(...)` callback.
- Eventually **every** ASP request times out. The process is still alive and
  `/debug/pprof/...` still answers — only script execution has stopped.
- `SIGTERM` does **not** stop it (graceful shutdown waits for in-flight requests). It needs
  `SIGKILL`, and until then a fresh instance cannot bind the port
  (`listen tcp :9596: bind: address already in use`).
- Sockets accumulate in `CLOSE-WAIT`: clients gave up, the server never closed its end.

## What the goroutine dump shows

Captured from the hung process with
`curl 'http://localhost:9596/debug/pprof/goroutine?debug=2'` (43 goroutines total):

| count | state | where |
|------:|-------|-------|
| 14 | `chan send`, 2 min | `axonvm.acquireVMPoolSlot` — 12 of them under `GlobalASA.ExecuteSessionOnStart` |
| 10 | `sync.Cond.Wait`, 2 min | `asp.(*Application).WaitForServer`, via `VM.dispatchNativeCall` → `VM.Run` |

Representative stacks:

```
g3pix.com.br/axonasp/axonvm.acquireVMPoolSlot()
g3pix.com.br/axonasp/axonvm.AcquireVMFromCachedProgram(...)
g3pix.com.br/axonasp/axonvm.AcquireVMFromCompiler(...)
g3pix.com.br/axonasp/axonvm.(*GlobalASA).executeHandler(...)
g3pix.com.br/axonasp/axonvm.(*GlobalASA).ExecuteSessionOnStart(...)
main.NewWebHost(...) -> main.executeASPWithStatus(...)

sync.(*Cond).Wait(...)
g3pix.com.br/axonasp/axonvm/asp.(*Application).WaitForServer(0x…, …)
g3pix.com.br/axonasp/axonvm.(*VM).dispatchNativeCall(…)
g3pix.com.br/axonasp/axonvm.(*VM).Run(…)
main.executeASPWithStatus.func1()
```

All ten `WaitForServer` goroutines wait on the **same** `sync.Cond` (`0x39baecd8990`).

## The mechanism

`/opt/axonasp/temp/error.log` — which, unlike `/root/asp/axonasp.log`, **survives restarts** —
holds the missing link:

```
2026/07/25 07:48:10  [4011] Script timeout reached and execution goroutine was detached
                     Detached blocked ASP execution goroutine after script timeout (60s).
                     File: /root/asp/leadbbs/Boards.asp                                x10
2026/07/24 19:46:09  ... same, File: /root/asp/leadbbs/plug-ins/bbschat/Default.asp     x5
                     followed by [3011] Server forced to shutdown | context deadline exceeded
```

Ten detachments on `Boards.asp`, timestamped at the exact minute the reproduction hung — and
`vm_pool_size` was **10**. The chain is:

1. **Heap pressure.** `golang_memory_limit_mb` was 256 and the process sat at ~253 MB, pinned
   against its own ceiling, so the Go runtime was in permanent GC. AxonASP's manual names this
   exactly: *"Request blocking is usually caused by Garbage Collector pressure rather than
   insufficient VM count... If the server is missing or delaying requests, increase this value
   before raising `vm_pool_size`."*
2. **A script exceeds `default_script_timeout` (60 s)** waiting its turn at
   `Application.WaitForServer` — Application access is serialised through a single owner, and
   under GC pressure everything queues.
3. **AxonASP detaches the goroutine (error 4011) — but the detached goroutine keeps its VM pool
   slot.** It is still parked in `WaitForServer` in the dump above.
4. **Each detachment permanently burns one slot.** After `vm_pool_size` of them the pool is
   empty for good, and every later request queues in `acquireVMPoolSlot` forever — including
   `Session_OnStart` for any client without a session, which is why opening a fresh browser
   context made it worse rather than better.

It is a **positive feedback loop**: every leaked slot makes the next request likelier to queue
past 60 s, which leaks the next slot. A slow minute becomes a permanent hang.

## Why the heap gets pinned: ~5 MB retained per distinct page path

Measured directly against `/debug/pprof/heap?gc=1` on the running server:

| step | HeapAlloc |
|---|---|
| baseline | 179 MB |
| after serving **25 distinct** `.asp` paths | 307 MB — **+5.2 MB per path** |
| after serving **the same 25 again** | 307 MB — +11 KB |

AxonASP retains several megabytes of permanently-live heap for every distinct path it has ever
served, and essentially nothing for repeat visits: the compiled program and its per-program VM
pool are never released, and `cache_max_size_mb = 100` does not give the memory back.

That is what makes this look like "degrades after a long run". Ordinary forum use touches a few
dozen paths and stays flat — my own earlier note that "RSS, fds and threads are flat" was
measured over a driver that hit the *same three pages* repeatedly, so breadth never grew and I
wrongly concluded there was no leak. Anything that walks the **whole site** — the 170-page
status sweep, `test/browser/07-links.mjs`, the coverage census — multiplies breadth until the
ceiling is reached. The repo has 264 real `.asp` files plus 309 case-alias symlinks (README
§29), and **each spelling is a separate cache key**, so a crawl that also touches aliases
retains roughly double.

## What was changed

In `/root/asp/axonasp.toml`:

```diff
-vm_pool_size = 10
+vm_pool_size = 24
-golang_memory_limit_mb = 256
+golang_memory_limit_mb = 1024
```

The box has 7.7 GB; 256 MB was the stock value, not a sizing decision. After the change the
process settles around **231 MB with 1 GB of headroom**, and a 3000-session run with 16-way
concurrent load overlapping authenticated navigation stays clean.

## Second occurrence — the mechanism confirmed, and the operational fix

It recurred while running the thirteen browser suites back to back, and the numbers settled the
argument:

- `/opt/axonasp/temp/error.log` went from **15 to 39** `[4011]` detachments — **24 new ones**,
  against `vm_pool_size = 24`. Exactly a poolful, again.
- RSS was **917 MB** against the 1024 MB limit when it hung, and `/User/Login.asp` stopped
  responding entirely.
- The pages that timed out were ordinary ones — `User/UserOnline.asp`,
  `User/lookuserinfo.asp`, `plug-ins/HomePageStar/admin_HomePageStar.asp` — i.e. nothing
  special about them beyond being served while the process was starved.

The trigger is identifiable: **`test/browser/07-links.mjs` sweeps 220+ distinct page paths in
one suite**, which at ~5 MB retained per path is most of the memory limit by itself. Every full
run therefore poisoned the server for the suites that followed, which is precisely the flakiness
that had been dogging this work.

`test/browser/run-all.sh` now checks the process's RSS before each suite and restarts AxonASP
when it exceeds **half** its configured `golang_memory_limit_mb`, printing what it did. With
that in place a complete run is clean and reproducible:

```
=== 07-links: 2/2 passed ===
--- AxonASP at 731MB (> 512MB of its 1024MB limit): restarting (README §32)
=== 08-adminops: 13/13 passed ===
...
suites passed: 13, failed: 0
```

## Third occurrence: load alone is enough, memory is not required

A later run tripped it again with **RSS at only 320 MB** — nowhere near the limit — while the
detachment count went 39 → **87**. So heap pressure is one route to a slow request, not the
mechanism itself: *anything* that pushes a request past `default_script_timeout` leaks a slot,
and leaked slots make the next request slower, so it compounds. `07-links.mjs` reaches that on
load alone, because it touches every distinct path the site emits (252 URLs and growing, since
each `04-admin` run adds a board).

Two consequences, both now handled in `test/browser/run-all.sh`:

1. **Every suite gets a freshly started server.** There is no in-process recovery, so the only
   reliable harness is one that never lets a poisoned server reach the next suite. It costs
   ~15 s per suite.
2. **The restart must verify it actually happened.** The first version simply killed the pid and
   waited for `Boards.asp` to answer — but a deadlocked AxonASP ignores `SIGTERM`, and if the
   port is still bound the replacement exits with *address already in use* while the **old,
   still-wedged process keeps answering**. That looks like a successful restart and silently
   poisons every later suite: a run where suites 08-14 all failed was this, not any product
   defect. The restart now waits for the old pid to die *and* the port to free, then requires a
   **different** pid before continuing, and aborts the run if it cannot get one.

The crawler also runs at two-way concurrency rather than six, to keep its own peak down.

With that, a full 14-suite run is clean and repeatable: **144 checks, 0 failures**.

## Honest limits of this fix

It is a **mitigation, not a repair**, and it does not remove the leak:

- The per-path heap retention is unbounded and upstream. On this box (7.7 GB total, ~1.9 GB
  free) you cannot serve all 573 path spellings in one server lifetime whatever the limit is
  set to. **Restart after any full-site crawl** (census, link check, page sweep); normal
  browsing touches a few dozen paths and stays flat.
- The slot leak on detachment is upstream: AxonASP must return a detached goroutine's VM slot,
  or decline to detach one that holds a slot. Nothing in the ASP layer can do that.
- The deadlock is a race in its timing — the driver that first caught it hung after ~300
  sessions while later runs passed 1200 and 3000 — so a clean run does not prove absence.

**Worth reporting upstream**, with this dump and the 4011 lines. If it recurs: `SIGKILL` the
process (SIGTERM will not work), and grab `/debug/pprof/goroutine?debug=2` first — it answers
even while hung. `/opt/axonasp/temp/error.log` keeps the 4011 record across restarts.

Reproduction driver: `test/repro32.mjs`.
