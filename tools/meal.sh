#!/bin/sh
# 나이스 급식 식단을 직접 조회한다. PlayMCP 가 "정보 없음" 을 줄 때
# 진짜 미등록인지 MCP 쪽 문제인지 가르는 용도.
#
#   sh tools/meal.sh 20260902           # 하루
#   sh tools/meal.sh 20260901 20260930  # 기간(등록 건수 확인용)
#
# 해제초등학교 고정: 전남광주통합특별시교육청(Q10) / 8662027
# ※ 사용자 근무지는 해제남초(8662028)지만, 해제남초는 해제초에서 급식을 배달받는다.
#   식단은 조리교인 해제초 이름으로만 등록되므로 해제남초 코드로는 아무것도 안 나온다.
# 인증키 없이 호출하므로 한 번에 5건까지만 내려온다. 기간 조회는 건수 확인용으로만 쓸 것.

ATPT=Q10
SCHUL=8662027
BASE=https://open.neis.go.kr/hub/mealServiceDietInfo

[ -n "$1" ] || { echo "사용법: sh tools/meal.sh YYYYMMDD [YYYYMMDD]" >&2; exit 1; }

if [ -n "$2" ]; then
  URL="$BASE?Type=json&ATPT_OFCDC_SC_CODE=$ATPT&SD_SCHUL_CODE=$SCHUL&MLSV_FROM_YMD=$1&MLSV_TO_YMD=$2"
else
  URL="$BASE?Type=json&ATPT_OFCDC_SC_CODE=$ATPT&SD_SCHUL_CODE=$SCHUL&MLSV_YMD=$1"
fi

curl -s -m 40 "$URL" | python3 -c '
import sys, json, re
raw = sys.stdin.read()
try:
    d = json.loads(raw)
except ValueError:
    print("응답을 못 읽었습니다(네트워크/프록시 확인):", raw[:200]); sys.exit(1)
if "mealServiceDietInfo" not in d:
    print("등록된 식단 없음 —", d.get("RESULT", {}).get("MESSAGE", d))
    print("※ API 장애가 아니라 학교가 나이스에 안 올린 것이다. 사진으로 추정하고 답장에 밝힐 것.")
    sys.exit(0)
head, body = d["mealServiceDietInfo"]
print("등록 건수:", head["head"][0]["list_total_count"], "(무인증 호출이라 아래는 최대 5건)")
for r in body["row"]:
    print()
    print(r["MLSV_YMD"], r["MMEAL_SC_NM"], "·", r["CAL_INFO"])
    for m in r["DDISH_NM"].split("<br/>"):
        print("  -", re.sub(r"\s*\([\d.]+\)\s*$", "", m).strip())
    print(" ", r["NTR_INFO"].replace("<br/>", " / "))
'
