#!/bin/bash
# AxonASP's HTTP router is case-sensitive, but LeadBBS (written for
# case-insensitive IIS) emits internal links/redirects/form-actions in
# inconsistent case (e.g. boards.asp vs the actual Boards.asp, login.asp vs
# Login.asp). This creates a lowercase-named symlink beside every served file
# whose name contains uppercase, so any all-lowercase URL resolves.
#
# Includes (#include / MapPath) already resolve case-insensitively inside
# AxonASP, so this is only about HTTP-served URLs. Idempotent; re-run anytime.
set -euo pipefail
cd "$(dirname "$0")"

# Extensions that are requested over HTTP (not include-only .inc files).
EXTS='asp|asa|css|js|htm|html|gif|jpg|jpeg|png|ico|swf|xml|txt|json|map'

created=0
while IFS= read -r -d '' f; do
  dir=$(dirname "$f")
  base=$(basename "$f")
  lower=$(printf '%s' "$base" | tr 'A-Z' 'a-z')
  [ "$base" = "$lower" ] && continue
  target="$dir/$lower"
  # skip if a real file or an existing symlink already occupies the lowercase name
  [ -e "$target" ] || [ -L "$target" ] && continue
  ln -s "$base" "$target"
  created=$((created+1))
done < <(find . -path ./.git -prune -o -type f -regextype posix-extended \
           -iregex ".*\.($EXTS)" -print0)

echo "created $created lowercase symlink(s)"

# --- Also create Capitalised aliases for all-lowercase files ---
# Some LeadBBS pages link to a capitalised name (e.g. Search/search.asp is linked as
# "Search.asp"), which 404s on a case-sensitive filesystem. The loop above only makes
# lowercase aliases, so add the capitalised-first-letter direction too.
# NOTE: use `if`, not `[ ... ] && continue` — under `set -e` the latter makes the whole
# statement return 1 for every already-capitalised file, which kills this subshell and
# silently leaves most aliases uncreated (that bug hid a 404 on User/Register.asp).
capped=0
while IFS= read -r -d '' f; do
  d=$(dirname "$f"); b=$(basename "$f")
  cap="$(printf '%s' "${b%%"${b#?}"}" | tr '[:lower:]' '[:upper:]')${b#?}"
  if [ "$cap" = "$b" ]; then continue; fi
  if [ -e "$d/$cap" ] || [ -L "$d/$cap" ]; then continue; fi
  ln -s "$b" "$d/$cap"
  capped=$((capped+1))
done < <(find . -path ./.git -prune -o -type f -name '*.asp' ! -type l -print0)

echo "created $capped capitalised alias(es)"

# --- Directory aliases ---
# The passes above only alias FILES. LeadBBS also emits URLs whose DIRECTORY component is
# in the wrong case — mini/'s registration form posts to "../user/Register.asp" while the
# directory is "User", which 404s on a case-sensitive filesystem. Alias directories the
# same way, in both directions. find(1) does not descend into symlinks, so the aliases
# created here can never be re-scanned or nested.
dirs=0
while IFS= read -r -d '' d; do
  b=$(basename "$d"); parent=$(dirname "$d")
  for alias in "$(printf '%s' "$b" | tr 'A-Z' 'a-z')" \
               "$(printf '%s' "${b%%"${b#?}"}" | tr '[:lower:]' '[:upper:]')${b#?}"; do
    if [ "$alias" = "$b" ]; then continue; fi
    if [ -e "$parent/$alias" ] || [ -L "$parent/$alias" ]; then continue; fi
    ln -s "$b" "$parent/$alias"
    dirs=$((dirs+1))
  done
done < <(find . -path ./.git -prune -o -type d ! -name . -print0)

echo "created $dirs directory alias(es)"

# --- Built-filename aliases: the UBB emoticons ---
# The passes above alias whole-name spellings, and case_aliases.py can only alias spellings
# that appear literally in the source. Neither covers a filename the code BUILDS. There is
# exactly one such family in the tree: the emoticon picker (a/emot.asp), the icon dialog
# (a/Edit/icon.asp) and the [emNN] renderer in leadedit.js / leadcode.js all emit
# `"../images/UBBicon/em" & NN & ".GIF"` — a lowercase stem beside a literal uppercase
# extension — while the files on disk are a mix of EM01.GIF and em50.gif. Result: every
# emoticon in the editor AND in every rendered post was a broken image. Alias that exact
# spelling for the whole set.
emots=0
if [ -d images/UBBicon ]; then
  while IFS= read -r -d '' f; do
    base=$(basename "$f")
    stem="${base%.*}"
    alias=$(printf '%s' "$stem" | tr 'A-Z' 'a-z').GIF
    if [ "$alias" = "$base" ]; then continue; fi
    if [ -e "images/UBBicon/$alias" ] || [ -L "images/UBBicon/$alias" ]; then continue; fi
    ln -s "$base" "images/UBBicon/$alias"
    emots=$((emots+1))
  done < <(find images/UBBicon -maxdepth 1 -type f -iname '*.gif' -print0)
fi

echo "created $emots emoticon alias(es)"

# --- Exact-spelling aliases harvested from the source ---
# The passes above guess two canonical spellings (all-lower, Capitalised). LeadBBS also
# emits arbitrary mixes -- MyInfobox.asp, Help/About.asp, Other/RSS.asp, jh1.GIF -- so
# scan the source for URL-shaped tokens and alias whatever actually appears.
ALIAS_PY="$(dirname "$0")/tools/case_aliases.py"
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found: skipping the exact-spelling alias pass ($ALIAS_PY)"
elif [ ! -f "$ALIAS_PY" ]; then
  # Do not fail the deployment over a missing optional pass -- the four passes above have
  # already created the aliases that matter. Say so loudly rather than exiting non-zero
  # halfway through someone's install.
  echo "WARNING: $ALIAS_PY is missing; skipping the exact-spelling alias pass."
  echo "         A few unusually-spelled URLs may 404. Re-run this script with the full"
  echo "         source tree to add them."
else
  python3 "$ALIAS_PY" --apply | tail -1
fi
