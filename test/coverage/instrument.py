import os, re
# repo root = two levels up from this script (test/coverage/instrument.py)
ROOT=os.path.abspath(os.path.join(os.path.dirname(__file__),'..','..'))
SKIP=('/.git/','/_test/','/_diag/','/test/')
files=[]
for dp,dn,fns in os.walk(ROOT):
    for fn in fns:
        if os.path.splitext(fn)[1].lower() in ('.asp','.asa','.inc'):
            p=os.path.join(dp,fn)
            if os.path.islink(p): continue
            if any(s in p+'/' for s in SKIP): continue
            files.append(p)

n=0
already=0
skipped=0
touched=[]
for p in files:
    rel=os.path.relpath(p,ROOT).replace('\\','/')
    raw=open(p,'rb').read()
    # decode preserving; work on text
    try: s=raw.decode('utf-8'); enc='utf-8'
    except UnicodeDecodeError: s=raw.decode('latin-1'); enc='latin-1'
    bom = s.startswith('\ufeff')
    body = s[1:] if bom else s

    # A .asp/.inc/.asa with no server code in it is DATA, not source. LeadBBS ships a number
    # of content fragments with an .asp extension — the registration agreement, the CMS
    # contact blocks, the channel-list records, the slideshow snippets, and data/global.asa
    # (the original binary Access database) — which are read with ADODB_LoadFile and never
    # executed. Instrumenting them measures nothing and actively CORRUPTS them: the on-line
    # file editor refuses content containing "<%", so a probe here breaks the app's own round
    # trip. `runat=` keeps inc/sha1.asp, which is server-side JScript with no <% at all.
    if '<%' not in body and not re.search(r'runat\s*=', body, re.I):
        skipped += 1
        continue

    probe = '<%Application("cov::' + rel + '")=1%>'
    # Idempotent, because browser_census.sh re-runs this between suites: the application
    # REGENERATES several of its own sources at runtime (inc/IncHtm/*,
    # article/inc/cache/CACHE_*, inc/*_Setup.asp) and each rewrite drops the probe, after
    # which nothing can mark that file for the rest of the run — it is then reported
    # unreached while a browser is demonstrably using it.
    if probe in body:
        already += 1
        continue

    # if file starts (after optional whitespace) with a <%@ ... %> directive, insert AFTER it
    m = re.match(r'\s*<%@[^%]*%>', body)
    if m:
        idx = m.end()
        newbody = body[:idx] + probe + body[idx:]
    else:
        newbody = probe + body
    out = ('\ufeff' if bom else '') + newbody
    open(p,'w',encoding=enc).write(out)
    touched.append(rel)
    n+=1
# Record exactly what was modified. browser_census.sh used to clean up with
# `git checkout -- .`, which reverts the WHOLE tree — including whatever the person running
# the census was in the middle of editing. It now reverts only this list.
MANIFEST = os.environ.get('LEADBBS_INSTRUMENT_MANIFEST', '/tmp/leadbbs-instrumented.txt')
prev = set()
if os.path.exists(MANIFEST):
    prev = set(l.strip() for l in open(MANIFEST, encoding='utf-8') if l.strip())
with open(MANIFEST, 'w', encoding='utf-8') as fh:
    for rel in sorted(prev | set(touched)):
        fh.write(rel + '\n')
print("instrumented", n, "files (", already, "already probed,", skipped, "data fragments with no server code)")
