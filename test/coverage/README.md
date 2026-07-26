# Runtime coverage census

Trace-instruments every source file, exercises the running site (guest crawl +
authenticated admin crawl + a write flow), and reports which files executed.
See `../../docs/axonasp-coverage-census.md` for the recorded result (98.8%).

## Run

```sh
# from the repo root, with a CLEAN git tree (the run reverts via git checkout):
bash test/coverage/run_census.sh /opt/axonasp http://localhost:9596 ./axonasp.toml
```

Files:
- `instrument.py` — prepends `<%Application("cov::<relpath>")=1%>` to each real `.asp/.asa/.inc`
  (after any leading `<%@…%>`). Skips symlinks and `_test/`/`_diag/`/`test/`.
- `exercise.sh` — guest + admin passes over every served `.asp`, plus a topic post.
- `covdump.asp` — loopback-only dump of the recorded `Application` `cov::` keys.
- `run_census.sh` — orchestrates instrument → restart → exercise → compute → **revert**.

The probe is a single unlocked `Application` write; it doesn't alter page error state or output.
The whole run reverts itself via `git checkout -- .`, so nothing is left instrumented.
