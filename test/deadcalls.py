#!/usr/bin/env python3
"""
Find server-side calls to routines that are not defined in the calling page's include
closure.

AxonASP silently ignores a call to an undefined Sub/Function (docs/axonasp-divergences.md §28),
where IIS raises "Type mismatch"/"Object required" and stops the page. That makes such
calls invisible "the button does nothing" bugs, so they have to be found statically.

Run from the web root:   python3 test/deadcalls.py

Only ENTRY pages are analysed (files nobody #includes), since an include fragment on its
own is expected to reference things its host defines.

Known false positives to expect in the output:
  * class-level `Private arr(n)` / `Public arr(n,m)` array declarations,
  * JavaScript inside <script> blocks that looks like a call (getAJAX, setTimeout, ...),
  * fragments reached through a mixed-case DIRECTORY (this resolver case-fixes file
    names, not directory names).
"""
import re, os, sys, functools

ROOT = '.'
BUILTIN = set('''abs array asc ascb ascw atn cbool cbyte ccur cdate cdbl chr chrb chrw cint clng cos
createobject csng cstr date dateadd datediff datepart dateserial datevalue day escape eval exp filter fix
formatcurrency formatdatetime formatnumber formatpercent getlocale getobject getref hex hour inputbox
instr instrb instrrev int isarray isdate isempty isnull isnumeric isobject join lbound lcase left leftb
len lenb loadpicture log ltrim mid midb minute month monthname msgbox now oct randomize replace rgb right
rightb rnd round rtrim second setlocale sgn sin space split sqr strcomp string strreverse tan time
timer timeserial timevalue trim typename ubound ucase unescape vartype weekday weekdayname year erase
execute executeglobal print printf sleep'''.split())
KEYWORD = set('''if then else elseif end sub function dim redim set call for each next do loop while wend
select case exit class new me and or not xor mod is byval byref preserve const option explicit stop
with property let get on error resume public private randomize to step in until'''.split())
INTRINSIC = ('response', 'request', 'server', 'session', 'application', 'err')

inc_re = re.compile(r'<!--\s*#include\s+(file|virtual)\s*=\s*"([^"]+)"\s*-->', re.I)
def_re = re.compile(r'^\s*(?:public\s+|private\s+)?(?:sub|function|property\s+(?:get|let|set))\s+([A-Za-z_]\w*)', re.I)
dim_re = re.compile(r'^\s*(?:dim|redim(?:\s+preserve)?|const|class|set|public|private)\s+(.*)$', re.I)
call_re = re.compile(r'^\s*(call\s+)?([A-Za-z_]\w*)\s*\(', re.I)


@functools.lru_cache(maxsize=None)
def resolve(path):
    if os.path.exists(path):
        return os.path.normpath(path)
    d, b = os.path.split(path)
    if not os.path.isdir(d or '.'):
        return None
    for f in os.listdir(d or '.'):
        if f.lower() == b.lower():
            return os.path.normpath(os.path.join(d, f))
    return None


@functools.lru_cache(maxsize=None)
def read(p):
    try:
        return open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        return ''


def server_code(txt):
    """Only <% ... %> regions. An unterminated final region runs to EOF, because most
    include files are pure code and never close the tag."""
    out, i = [], 0
    while True:
        a = txt.find('<%', i)
        if a < 0:
            break
        b = txt.find('%>', a + 2)
        if b < 0:
            out.append(txt[a + 2:])
            break
        out.append(txt[a + 2:b])
        i = b + 2
    return '\n'.join(out)


def closure(path, seen=None):
    if seen is None:
        seen = set()
    p = resolve(path)
    if not p or p in seen:
        return seen
    seen.add(p)
    for kind, ref in inc_re.findall(read(p)):
        base = ROOT if kind.lower() == 'virtual' else os.path.dirname(p)
        closure(os.path.join(base, ref.lstrip('/')), seen)
    return seen


def main():
    pages = []
    for root, _, files in os.walk(ROOT):
        if '.git' in root:
            continue
        for f in files:
            if f.lower().endswith('.asp'):
                p = os.path.normpath(os.path.join(root, f))
                if not os.path.islink(p):
                    pages.append(p)

    included = set()
    for p in pages:
        for kind, ref in inc_re.findall(read(p)):
            base = ROOT if kind.lower() == 'virtual' else os.path.dirname(p)
            r = resolve(os.path.join(base, ref.lstrip('/')))
            if r:
                included.add(r)
    entry = [p for p in pages if p not in included]

    report = {}
    for page in entry:
        cl = closure(page)
        defs, dims = set(), set()
        for f in cl:
            for line in server_code(read(f)).split('\n'):
                m = def_re.match(line)
                if m:
                    defs.add(m.group(1).lower())
                m = dim_re.match(line)
                if m:
                    for n in re.findall(r'([A-Za-z_]\w*)', m.group(1).split("'")[0]):
                        dims.add(n.lower())
        for f in cl:
            for line in server_code(read(f)).split('\n'):
                if line.strip().startswith("'"):
                    continue
                m = call_re.match(line)
                if not m:
                    continue
                nl = m.group(2).lower()
                if nl in BUILTIN or nl in KEYWORD or nl in dims or nl in defs:
                    continue
                if not m.group(1) and nl in INTRINSIC:
                    continue
                report.setdefault(m.group(2), set()).add(page)

    for n in sorted(report, key=lambda k: -len(report[k])):
        print(f"{n:26s} {len(report[n]):3d} entry page(s)   e.g. {sorted(report[n])[0]}")
    print(f"\n{len(entry)} entry pages analysed; {len(report)} undefined-in-closure name(s)")
    return 0


if __name__ == '__main__':
    sys.exit(main())
