import { chromium } from '@playwright/test';
import fs from 'fs';
import path from 'path';

async function captureTarget(targetUrl, specBaseName = 'visual.spec.ts') {
  console.log(`🚀 [Playwright Capture] Membuka URL target: ${targetUrl}...`);
  
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 2,
  });

  const page = await context.newPage();

  try {
    await page.goto(targetUrl, { waitUntil: 'networkidle', timeout: 45000 });

    // 1. Tunggu webfonts & trigger lazy loading gambar dengan smooth scroll
    console.log('⏳ [Playwright Capture] Menunggu webfonts & memicu scroll assets...');
    await page.evaluate(async () => {
      await document.fonts.ready;
      window.scrollTo(0, document.body.scrollHeight);
      await new Promise((r) => setTimeout(r, 1500));
      window.scrollTo(0, 0);
      await new Promise((r) => setTimeout(r, 1000));
    });

    // 2. Bekukan animasi berulang & transisi
    console.log('❄️ [Playwright Capture] Membekukan CSS animations & transitions...');
    await page.addStyleTag({
      content: `
        *, *::before, *::after {
          animation-play-state: paused !important;
          transition: none !important;
        }
      `,
    });

    // 3. Pause semua video HTML5
    await page.evaluate(() => {
      document.querySelectorAll('video').forEach((v) => {
        v.pause();
        v.currentTime = 0;
      });
    });

    // 4. Siapkan snapshot directory
    const snapshotDir = path.resolve(`tests/${specBaseName}-snapshots`);
    fs.mkdirSync(snapshotDir, { recursive: true });

    const targetPath = path.resolve('target.png');
    const testSnapshotPath = path.join(snapshotDir, 'target-linux.png');
    const videos = page.locator('video');

    console.log(`📸 [Playwright Capture] Menyimpan baseline screenshot ke: ${targetPath}`);
    await page.screenshot({ path: targetPath, fullPage: true, animations: 'disabled', mask: [videos] });
    await page.screenshot({ path: testSnapshotPath, fullPage: true, animations: 'disabled', mask: [videos] });

    // 5. Simpan full rendered DOM HTML
    const renderedHtml = await page.content();
    fs.writeFileSync('target-rendered.html', renderedHtml);

    console.log(`✅ [Playwright Capture] Sukses! Snapshot baseline tersimpan di: ${testSnapshotPath}`);
  } catch (err) {
    console.error('❌ [Playwright Capture] Error:', err);
  } finally {
    await browser.close();
  }
}

const target = process.argv[2] || 'https://pop.site/';
captureTarget(target);
