# itsme

송화영 개인 사이트. 정적 HTML만 있고 빌드 도구·의존성은 없다. 파일을 브라우저로 바로 열면 그대로 동작해야 한다.

- `index.html` — 포트폴리오 랜딩 페이지
- `weight.html` — 매일 아침 체중 기록 (index에서 링크하지 않는 비공개용 페이지, `noindex`)

## 말투 규칙 (최우선)

이 저장소에서 사용자에게 답할 때는 **항상 존댓말**을 쓴다. 짧게 답할 때도 예외 없다. 반말 금지.

## 매일 아침 체중 입력 루틴

사용자가 아침에 숫자만 던지면 아래를 **그대로** 수행한다. 되묻지 말 것.

**숫자 해석 규칙**
- **4자리 숫자는 체중이다.** 앞 두 자리가 정수부, 뒤 두 자리가 소수부.
  `7374` → `73.74` kg, `6805` → `68.05` kg
- `72.4`, `오늘 71.8kg` 처럼 소수점·단위를 붙여 주면 그대로 쓴다.
- 값은 받은 정밀도 그대로 저장한다. 페이지도 소수 **둘째** 자리까지 그대로 표시한다.

1. `weight.html` 상단의 `<script id="weight-data">` JSON 블록 안 `entries` 배열에 한 줄 추가
   ```json
   {"d":"2026-08-04","w":73.74}
   ```
   - `d` = **오늘 날짜**(YYYY-MM-DD, 시스템 컨텍스트의 currentDate 기준)
   - `w` = 위 규칙으로 해석한 체중(kg)
   - 사용자가 한마디 덧붙이면(“어제 회식”, “운동함”) `"memo":"…"` 로 같이 기록
   - 같은 날짜가 이미 있으면 새로 추가하지 말고 그 줄을 덮어쓴다
   - 날짜 오름차순 유지 (페이지가 정렬하긴 하지만 diff 가독성을 위해)
   - **반드시 Edit로 해당 줄만 고친다. `weight.html` 전체를 Write로 다시 쓰지 말 것** —
     기록이 페이지 안에 들어 있어 전체 재작성은 데이터 유실 위험이 있다.
     정상적인 하루치 커밋은 `2 insertions(+), 1 deletion(-)` 이다(직전 줄에 쉼표가 붙어 -1).
     이보다 크게 바뀌었으면 커밋 전에 `git diff` 로 확인한다.
2. 커밋 메시지: `Log weight YYYY-MM-DD: 73.74kg`
3. `git push -u origin claude/daily-weight-tracking-trm7fj`
4. **현황 카드 이미지를 만들어 채팅에 첨부한다** (매번, 빠뜨리지 말 것)
   ```bash
   ln -sfn "<스크래치패드>/node_modules" node_modules   # playwright 없으면 스크래치패드에 npm i playwright
   node tools/shot.js "<스크래치패드>/weight-card.png"
   ```
   나온 PNG를 `SendUserFile` 로 보낸다 (`display:"render"`). `weight.html` 상단(제목·지표·그래프)을 그대로 잘라낸 이미지라 페이지와 항상 같은 내용이다.
5. 답장은 짧게, **존댓말로** — 기록 완료 + 전일 대비 / 7일 평균 정도만. 장황한 코칭 금지.

목표 체중·키는 `config.target` / `config.height` 에 넣으면 목표선과 BMI가 표시된다. 비워두면 해당 항목은 숨는다.

## 스타일 규칙

- 색·타이포는 `index.html`의 `:root` 토큰(ink / teal / slate / hair, Pretendard + JetBrains Mono)을 따른다.
- 외부 JS 라이브러리를 쓰지 않는다. 차트도 순수 SVG로 직접 그린다.
- 데이터는 별도 파일로 빼지 말고 HTML 안에 인라인으로 둔다 (`file://` 로 열어도 `fetch` 없이 동작하도록).
