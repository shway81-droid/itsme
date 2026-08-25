#!/bin/sh
# 사진의 촬영 시각을 뽑는다. 음식 사진이 "남은 음식"인지 판단하려면 시각이 필요한데,
# 대화 중에는 시계가 없어서 파일에서 직접 읽는다.
#
#   sh tools/phototime.sh <사진경로>
#
# EXIF 촬영시각(사용자 현지시각, KST)이 있으면 그걸 쓰고, 없으면 업로드 시각으로 물러선다.
# 업로드 시각은 서버 UTC라서 KST(+9)로 변환해 내보낸다.

F="$1"
[ -f "$F" ] || { echo "파일 없음: $F" >&2; exit 1; }

python3 - "$F" <<'PY'
import sys, re, os, datetime

path = sys.argv[1]
# EXIF의 날짜는 "YYYY:MM:DD HH:MM:SS" ASCII로 헤더 근처에 박혀 있다
head = open(path, 'rb').read(256 * 1024)
hits = sorted(set(re.findall(rb'\d{4}:\d{2}:\d{2} \d{2}:\d{2}:\d{2}', head)))

if hits:
    t = hits[0].decode().replace(':', '-', 2)
    print(f"{t}\tEXIF 촬영시각 (현지/KST)")
else:
    # 업로드 시각(UTC) → KST
    utc = datetime.datetime.utcfromtimestamp(os.path.getmtime(path))
    kst = utc + datetime.timedelta(hours=9)
    print(f"{kst:%Y-%m-%d %H:%M:%S}\t업로드 시각에서 추정 (EXIF 없음)")
PY
