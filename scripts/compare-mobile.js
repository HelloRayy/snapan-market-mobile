import { chromium } from '@playwright/test';
import http from 'http';
import fs from 'fs';
import path from 'path';

function createStaticServer(distDir, port = 5198) {
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
    server.listen(port, () => {
      console.log(`🌐 Local Server running at http://localhost:${port}`);
      resolve(server);
    });
  });
}

async function run() {
  const distDir = path.resolve('dist');
  const server = await createStaticServer(distDir, 5198);
  const outDir = path.resolve('/home/rayhan/.gemini/antigravity/brain/68aaf641-f00d-4a6e-a62b-e4a95ec1e1e2');

  const browser = await chromium.launch({ headless: true });

  try {
    const context = await browser.newContext({
      viewport: { width: 390, height: 844 },
      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
    });

    // 1. Capture Target pop.site Mobile
    console.log('📸 Fetching and capturing target pop.site mobile...');
    const pageTarget = await context.newPage();
    try {
      await pageTarget.goto('https://pop.site/', { waitUntil: 'networkidle', timeout: 30000 });
      await pageTarget.evaluate(async () => {
        await document.fonts.ready;
        window.scrollTo(0, document.body.scrollHeight);
        await new Promise((r) => setTimeout(r, 1200));
        window.scrollTo(0, 0);
      });
      await pageTarget.screenshot({
        path: path.join(outDir, 'target_mobile_fullpage.png'),
        fullPage: true,
      });
      console.log('✅ Target pop.site mobile captured!');
    } catch (e) {
      console.error('Target fetch error:', e.message);
    } finally {
      await pageTarget.close();
    }

    // 2. Capture Local Mobile
    console.log('📸 Capturing local mobile...');
    const pageLocal = await context.newPage();
    await pageLocal.addInitScript(() => {
      localStorage.setItem('snapan_has_onboarded', 'true');
    });
    await pageLocal.goto('http://localhost:5198/download', { waitUntil: 'networkidle' });
    await pageLocal.evaluate(async () => {
      await document.fonts.ready;
      window.scrollTo(0, document.body.scrollHeight);
      await new Promise((r) => setTimeout(r, 1200));
      window.scrollTo(0, 0);
    });
    await pageLocal.screenshot({
      path: path.join(outDir, 'local_mobile_fullpage.png'),
      fullPage: true,
    });
    console.log('✅ Local mobile full page captured!');
    await pageLocal.close();

  } finally {
    await browser.close();
    server.close();
    console.log('🏁 Capture finished.');
  }
}

run();
