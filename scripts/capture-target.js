import { chromium } from '@playwright/test';
import fs from 'fs';
import path from 'path';

async function captureViewport(browser, { name, width, height, url, snapshotDir }) {
  console.log(`🚀 [Playwright Capture] Memotret ${name} (${width}x${height})...`);

  const context = await browser.newContext({
    viewport: { width, height },
    deviceScaleFactor: 1,
  });

  const page = await context.newPage();

  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 45000 });

    await page.evaluate(async () => {
      await document.fonts.ready;
      window.scrollTo(0, document.body.scrollHeight);
      await new Promise((r) => setTimeout(r, 1500));
      window.scrollTo(0, 0);
      await new Promise((r) => setTimeout(r, 1000));
    });

    await page.addStyleTag({
      content: `
        *, *::before, *::after {
          animation-play-state: paused !important;
          transition: none !important;
        }
      `,
    });

    const snapshotPath = path.join(snapshotDir, `target-${name}-linux.png`);
    const videos = page.locator('video');

    await page.screenshot({
      path: snapshotPath,
      fullPage: true,
      animations: 'disabled',
      mask: [videos],
    });

    console.log(`✅ [Playwright Capture] Baseline ${name} tersimpan di: ${snapshotPath}`);
  } catch (err) {
    console.error(`❌ [Playwright Capture] Error pada ${name}:`, err.message);
  } finally {
    await context.close();
  }
}

async function run() {
  const url = process.argv[2] || 'https://pop.site/';
  const snapshotDir = path.resolve('tests/visual.spec.ts-snapshots');
  fs.mkdirSync(snapshotDir, { recursive: true });

  const browser = await chromium.launch({ headless: true });

  try {
    // 1. Desktop Viewport (1440x900)
    await captureViewport(browser, {
      name: 'desktop',
      width: 1440,
      height: 900,
      url,
      snapshotDir,
    });

    // 2. Mobile Viewport (390x844)
    await captureViewport(browser, {
      name: 'mobile',
      width: 390,
      height: 844,
      url,
      snapshotDir,
    });

    console.log('\n🎉 [Playwright Capture] Seluruh baseline dual-viewport berhasil diambil!');
  } finally {
    await browser.close();
  }
}

run();
