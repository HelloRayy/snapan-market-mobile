import { chromium } from '@playwright/test';
import http from 'http';
import fs from 'fs';
import path from 'path';

function createStaticServer(distDir, port = 5197) {
  const mimeTypes = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.webp': 'image/webp',
    '.svg': 'image/svg+xml',
    '.woff2': 'font/woff2',
  };

  const server = http.createServer((req, res) => {
    let reqPath = req.url.split('?')[0];
    let filePath = path.join(distDir, reqPath === '/' || !path.extname(reqPath) ? 'index.html' : reqPath);
    if (!fs.existsSync(filePath)) filePath = path.join(distDir, 'index.html');
    const ext = path.extname(filePath);
    const contentType = mimeTypes[ext] || 'application/octet-stream';
    fs.readFile(filePath, (err, content) => {
      if (err) { res.writeHead(500); res.end(err.code); }
      else { res.writeHead(200, { 'Content-Type': contentType }); res.end(content, 'utf-8'); }
    });
  });

  return new Promise((resolve) => {
    server.listen(port, () => resolve(server));
  });
}

async function run() {
  const distDir = path.resolve('dist');
  const server = await createStaticServer(distDir, 5197);
  const outDir = path.resolve('/home/rayhan/.gemini/antigravity/brain/68aaf641-f00d-4a6e-a62b-e4a95ec1e1e2');

  const browser = await chromium.launch({ headless: true });

  try {
    const page = await browser.newPage({
      viewport: { width: 390, height: 844 },
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
    });

    await page.addInitScript(() => {
      localStorage.setItem('snapan_has_onboarded', 'true');
    });

    await page.goto('http://localhost:5197/download', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // 1. Check for horizontal overflow bugs
    const overflowReport = await page.evaluate(() => {
      const docWidth = document.documentElement.clientWidth;
      const overflowingElements = [];
      const all = document.querySelectorAll('*');
      for (const el of all) {
        const rect = el.getBoundingClientRect();
        if (rect.right > docWidth + 2) {
          overflowingElements.push({
            tag: el.tagName,
            className: el.className ? el.className.toString().substring(0, 50) : '',
            id: el.id,
            right: rect.right,
            width: rect.width,
            docWidth,
          });
        }
      }
      return {
        bodyScrollWidth: document.body.scrollWidth,
        docClientWidth: docWidth,
        hasHorizontalScroll: document.body.scrollWidth > docWidth,
        overflowingElements: overflowingElements.slice(0, 10),
      };
    });

    console.log('=== OVERFLOW AUDIT REPORT ===');
    console.log(JSON.stringify(overflowReport, null, 2));

    // 2. Capture specific viewport snapshots at various scroll positions
    const scrollPositions = [
      { name: 'mobile_01_hero', y: 0 },
      { name: 'mobile_02_showcase', y: 800 },
      { name: 'mobile_03_features', y: 1600 },
      { name: 'mobile_04_team', y: 2600 },
      { name: 'mobile_05_support', y: 3500 },
      { name: 'mobile_06_footer', y: 5000 },
    ];

    for (const pos of scrollPositions) {
      await page.evaluate((y) => window.scrollTo(0, y), pos.y);
      await page.waitForTimeout(500);
      const shotPath = path.join(outDir, `${pos.name}.png`);
      await page.screenshot({ path: shotPath });
      console.log(`Saved ${pos.name} to ${shotPath}`);
    }

  } finally {
    await browser.close();
    server.close();
  }
}

run();
