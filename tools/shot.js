/*
 * health.html 상단(제목 + 지표 + 통합 타임라인)을 잘라 PNG 카드로 뽑는 개발용 스크립트.
 * 사이트 자체는 여전히 의존성 0 — 이 파일은 배포물이 아니라 매일 아침 채팅에
 * 붙일 현황 이미지를 만드는 용도다.
 *
 *   npm i playwright        (브라우저는 /opt/pw-browsers 에 이미 있음)
 *   node tools/shot.js [출력경로.png] [health.html]
 */
const path = require('path');
const { chromium } = require('playwright');

const OUT = process.argv[2] || path.join(process.cwd(), 'weight-card.png');
const SRC = process.argv[3] || 'health.html';        // 기본은 통합 페이지
const PAGE = 'file://' + path.resolve(__dirname, '..', SRC);
const CHROME = process.env.CHROME_PATH || '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';
const PAD = 26;

(async () => {
  const browser = await chromium.launch({ executablePath: CHROME });
  const page = await browser.newPage({
    viewport: { width: 1000, height: 1200 },
    deviceScaleFactor: 2,
  });

  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto(PAGE);
  // 정지 이미지에서는 눌러볼 수 없는 범위 버튼을 숨긴다
  await page.addStyleTag({ content: '.ranges{display:none !important}' });
  // 웹폰트(차단될 수 있음)와 SVG 렌더가 끝날 시간을 준다
  await page.waitForTimeout(700);

  const head = await page.locator('header.head').boundingBox();
  const tail = await page.locator('.card').first().boundingBox();
  if (!head || !tail) {
    console.error('기록이 없어 카드로 만들 화면이 없습니다.');
    await browser.close();
    process.exit(1);
  }

  await page.screenshot({
    path: OUT,
    clip: {
      x: Math.max(0, head.x - PAD),
      y: head.y, // header.head 자체 상단 여백으로 충분 — 위 nav가 걸리지 않게
      width: Math.min(1000, tail.x + tail.width + PAD) - Math.max(0, head.x - PAD),
      height: tail.y + tail.height + PAD - head.y,
    },
  });

  await browser.close();
  if (errors.length) {
    console.error('페이지 오류:', errors.join(' / '));
    process.exit(1);
  }
  console.log(OUT);
})();
