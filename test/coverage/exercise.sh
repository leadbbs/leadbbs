#!/bin/bash
: "${LEADBBS_ADMIN_USER:=admin}"
: "${LEADBBS_ADMIN_PASS:=leadbbs123}"
: "${LEADBBS_ADMIN_ANSWER:=leadbbsans}"
# Exercise the running LeadBBS site for the coverage census: a guest crawl of
# every served .asp, an authenticated admin crawl of the same, and one write
# flow. Assumes the coverage probe is already instrumented and the server up.
# Usage: bash exercise.sh [base_url]
set -u
BASE="${1:-http://localhost:8801}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"

mapfile -t urls < <(cd "$ROOT" && find . -type f -name '*.asp' ! -type l \
  | grep -vE '/_test/|/_diag/|/test/' | sed 's|^\./||' | sort)
echo "exercising ${#urls[@]} .asp files (guest + admin)"

# --- guest pass ---
JG="$TMP/guest.jar"
for u in "${urls[@]}"; do curl -s -c "$JG" -b "$JG" "$BASE/$u" -o /dev/null; done
echo "guest pass done"

# --- admin pass (forum login + admin-panel second factor) ---
JA="$TMP/admin.jar"
curl -s -c "$JA" -b "$JA" "$BASE/User/Login.asp" -o /dev/null
curl -s -c "$JA" -b "$JA" -X POST "$BASE/User/Login.asp" \
  --data-urlencode "submitflag=ddddls-+++" --data-urlencode "user=$LEADBBS_ADMIN_USER" \
  --data-urlencode "pass=$LEADBBS_ADMIN_PASS" --data-urlencode "JsFlag=0" -o /dev/null
curl -s -c "$JA" -b "$JA" "$BASE/test/browser/helpers/setcaptcha.asp" -o /dev/null
curl -s -c "$JA" -b "$JA" -X POST "$BASE/manage/default.asp" -H "Referer: $BASE/manage/default.asp" \
  --data-urlencode "submitflag=ddddls-+++" --data-urlencode "user=$LEADBBS_ADMIN_USER" --data-urlencode "pass=$LEADBBS_ADMIN_PASS" \
  --data-urlencode "MPass=$LEADBBS_ADMIN_ANSWER" --data-urlencode "ForumNumber=1234" --data-urlencode "CkiExp=-99" -o /dev/null
for u in "${urls[@]}"; do curl -s -c "$JA" -b "$JA" "$BASE/$u" -o /dev/null; done
echo "admin pass done"

# --- write flow: post a topic ---
curl -s -c "$JA" -b "$JA" "$BASE/test/browser/helpers/setcaptcha.asp" -o /dev/null
M="COV$RANDOM"
curl -s -c "$JA" -b "$JA" -X POST "$BASE/a/a2.asp?BoardID=100" -H "Referer: $BASE/a/a2.asp?BoardID=100" \
  --data-urlencode "submitflag=true" --data-urlencode "BoardID=100" --data-urlencode "Form_Title=Topic $M" \
  --data-urlencode "Form_Content=coverage exercise $M" --data-urlencode "Form_HTMLFlag=0" \
  --data-urlencode "Form_FaceIcon=0" --data-urlencode "ForumNumber=1234" -o /dev/null
echo "write flow done"
rm -rf "$TMP"
