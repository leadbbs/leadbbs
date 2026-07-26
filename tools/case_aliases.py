#!/usr/bin/env python3
"""
Create case-alias symlinks for the EXACT spellings the source actually emits.

AxonASP routes case-sensitively (README divergence #29) and LeadBBS emits internal URLs
in whatever case the author happened to type: `MyInfobox.asp` for `myinfobox.asp`,
`Help/About.asp` for `help/about.asp`, `Other/RSS.asp` for `OTHER/rss.asp`. Guessing two
canonical forms (all-lower, Capitalised) does not cover that, so this scans the source for
URL-shaped tokens and, for each one that does not resolve but has a case-insensitive match
on disk, creates the alias — including intermediate directory components.

Usage (from the web root):
    python3 tools/case_aliases.py          # report only
    python3 tools/case_aliases.py --apply  # create the symlinks

make-compat-symlinks.sh runs this as its final pass.
"""
import os, re, sys

EXTS = 'asp|asa|css|js|htm|html|gif|jpg|jpeg|png|ico|swf|xml|txt|json'
TOKEN = re.compile(r'[A-Za-z0-9_][A-Za-z0-9_./-]*\.(?:' + EXTS + r')\b', re.I)
SRC_EXTS = ('.asp', '.js', '.css', '.htm', '.html')
SKIP_DIRS = {'.git', 'install'}
# Leftovers from the pre-#21 backslash-path bug are not real paths; never alias them.
BAD = '\\'


def listdir_cache(cache, d):
    if d not in cache:
        try:
            cache[d] = {n.lower(): n for n in os.listdir(d)}
        except OSError:
            cache[d] = {}
    return cache[d]


def resolve_ci(path, cache):
    """Resolve `path` allowing any component to differ in case. Returns (real_path, fixes)
    where fixes is the list of (alias_path, real_name) needed to make `path` itself work."""
    parts = [q for q in path.split('/') if q not in ('', '.')]
    cur = '.'
    fixes = []
    for i, part in enumerate(parts):
        if part == '..':
            cur = os.path.dirname(cur) or '.'
            continue
        cand = os.path.join(cur, part)
        if os.path.exists(cand):
            cur = cand
            continue
        real = listdir_cache(cache, cur).get(part.lower())
        if real is None:
            return None, []
        fixes.append((cand, real))
        cur = os.path.join(cur, real)
    return cur, fixes


def main():
    apply = '--apply' in sys.argv
    cache = {}
    refs = set()
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not os.path.islink(os.path.join(root, d))]
        for f in files:
            if not f.lower().endswith(SRC_EXTS):
                continue
            p = os.path.join(root, f)
            if os.path.islink(p):
                continue
            try:
                txt = open(p, encoding='utf-8', errors='replace').read()
            except OSError:
                continue
            for m in TOKEN.finditer(txt):
                t = m.group(0)
                if '://' in t or t.startswith('//'):
                    continue
                # resolve relative to the web root and to the referencing file's directory
                refs.add(t.lstrip('/'))
                refs.add(os.path.normpath(os.path.join(os.path.dirname(p), t)).lstrip('./'))

    # Paths built by concatenation ("images/" & GBL_DefineImage & "jh1.GIF") have no
    # literal directory in the source, so the scan above sees only the file name. For a
    # bare file-name token, alias it in every directory that holds a case-insensitive
    # match — that is where such a path can land.
    bare = {t for t in refs if '/' not in t}
    bare_by_lower = {}
    for t in bare:
        bare_by_lower.setdefault(t.lower(), set()).add(t)
    extra = []
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and BAD not in d and not os.path.islink(os.path.join(root, d))]
        present = {f.lower(): f for f in files if BAD not in f}
        for low, spellings in bare_by_lower.items():
            real = present.get(low)
            if not real:
                continue
            for sp in spellings:
                if sp != real and not os.path.exists(os.path.join(root, sp)):
                    extra.append((os.path.join(root, sp), real))

    made, missing = [], set()
    for ref in sorted(refs):
        if os.path.exists(ref):
            continue
        real, fixes = resolve_ci(ref, cache)
        if real is None:
            missing.add(ref)
            continue
        for alias, realname in fixes:
            if os.path.exists(alias) or os.path.islink(alias):
                continue
            if apply:
                os.symlink(realname, alias)
                cache.pop(os.path.dirname(alias) or '.', None)
            made.append(f"{alias} -> {realname}")

    for alias, realname in extra:
        if os.path.exists(alias) or os.path.islink(alias):
            continue
        if apply:
            os.symlink(realname, alias)
        made.append(f"{alias} -> {realname}")

    seen = set()
    for m in made:
        if m in seen:
            continue
        seen.add(m)
        print(('created ' if apply else 'would create ') + m)
    made = list(seen)
    print(f"\n{len(made)} alias(es) {'created' if apply else 'needed'}; "
          f"{len(missing)} referenced path(s) have no match on disk at all")
    return 0


if __name__ == '__main__':
    sys.exit(main())
