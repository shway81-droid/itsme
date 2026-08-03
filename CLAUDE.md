# itsme

송화영 개인 사이트. 정적 HTML만 있고 빌드 도구·의존성은 없다. 파일을 브라우저로 바로 열면 그대로 동작해야 한다.

- `index.html` — 포트폴리오 랜딩 페이지
- `weight.html` — 매일 아침 체중 기록 (index에서 링크하지 않는 비공개용 페이지, `noindex`)

## 매일 아침 체중 입력 루틴

사용자가 아침에 숫자만 던지면(예: "72.4", "오늘 71.8kg") 아래를 **그대로** 수행한다. 되묻지 말 것.

1. `weight.html` 상단의 `<script id="weight-data">` JSON 블록 안 `entries` 배열에 한 줄 추가
   ```json
   {"d":"2026-08-04","w":72.1}
   ```
   - `d` = **오늘 날짜**(YYYY-MM-DD, 시스템 컨텍스트의 currentDate 기준)
   - `w` = 입력받은 체중(kg, 소수 첫째 자리)
   - 사용자가 한마디 덧붙이면(“어제 회식”, “운동함”) `"memo":"…"` 로 같이 기록
   - 같은 날짜가 이미 있으면 새로 추가하지 말고 그 줄을 덮어쓴다
   - 날짜 오름차순 유지 (페이지가 정렬하긴 하지만 diff 가독성을 위해)
2. 커밋 메시지: `Log weight YYYY-MM-DD: 72.1kg`
3. `git push -u origin claude/daily-weight-tracking-trm7fj`
4. 답장은 짧게 — 기록 완료 + 전일 대비 / 7일 평균 정도만. 장황한 코칭 금지.

목표 체중·키는 `config.target` / `config.height` 에 넣으면 목표선과 BMI가 표시된다. 비워두면 해당 항목은 숨는다.

## 스타일 규칙

- 색·타이포는 `index.html`의 `:root` 토큰(ink / teal / slate / hair, Pretendard + JetBrains Mono)을 따른다.
- 외부 JS 라이브러리를 쓰지 않는다. 차트도 순수 SVG로 직접 그린다.
- 데이터는 별도 파일로 빼지 말고 HTML 안에 인라인으로 둔다 (`file://` 로 열어도 `fetch` 없이 동작하도록).
