import { chromium } from '@playwright/test';
import http from 'http';
import fs from 'fs';
import path from 'path';

function createStaticServer(distDir) {
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

    if (!fs.existsSync(filePath)) {
      filePath = path.join(distDir, 'index.html');
    }

    const ext = path.extname(filePath);
    const contentType = mimeTypes[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, content) => {
      if (err) {
        res.writeHead(500);
        res.end(`Server Error: ${err.code}`);
      } else {
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(content, 'utf-8');
      }
    });
  });

  return new Promise((resolve) => {
    server.listen(5199, () => {
      console.log(`🌐 Static Server running at http://localhost:5199`);
      resolve(server);
    });
  });
}

async function capture() {
  const distDir = path.resolve('dist');
  const server = await createStaticServer(distDir);
  const serverUrl = 'http://localhost:5199';

  const browser = await chromium.launch({ headless: true });
  const outDir = path.resolve('/home/rayhan/.gemini/antigravity/brain/68aaf641-f00d-4a6e-a62b-e4a95ec1e1e2');

  try {
    // 1. Desktop (1440x900)
    console.log('📸 Capturing Desktop Footer...');
    const contextDesktop = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const pageDesktop = await contextDesktop.newPage();
    await pageDesktop.goto(serverUrl, { waitUntil: 'domcontentloaded' });
    await pageDesktop.waitForTimeout(1000);

    await pageDesktop.evaluate(async () => {
      await document.fonts.ready;
      window.scrollTo(0, document.body.scrollHeight);
    });
    await pageDesktop.waitForTimeout(1000);

    const footerDesktop = pageDesktop.locator('footer.snapan-modern-footer');
    const desktopScreenshotPath = path.join(outDir, 'footer_desktop_snapshot.png');
    await footerDesktop.screenshot({ path: desktopScreenshotPath });
    console.log(`✅ Desktop Footer Screenshot captured: ${desktopScreenshotPath}`);
    await contextDesktop.close();

    // 2. Mobile (390x844)
    console.log('📸 Capturing Mobile Footer...');
    const contextMobile = await browser.newContext({ viewport: { width: 390, height: 844 } });
    const pageMobile = await contextMobile.newPage();
    await pageMobile.goto(serverUrl, { waitUntil: 'domcontentloaded' });
    await pageMobile.waitForTimeout(1000);

    await pageMobile.evaluate(async () => {
      await document.fonts.ready;
      window.scrollTo(0, document.body.scrollHeight);
    });
    await pageMobile.waitForTimeout(1000);

    const footerMobile = pageMobile.locator('footer.snapan-modern-footer');
    const mobileScreenshotPath = path.join(outDir, 'footer_mobile_snapshot.png');
    await footerMobile.screenshot({ path: mobileScreenshotPath });
    console.log(`✅ Mobile Footer Screenshot captured: ${mobileScreenshotPath}`);
    await contextMobile.close();
  } catch (err) {
    console.error('Error during capture:', err);
  } finally {
    await browser.close();
    server.close();
    console.log('🏁 Capture process completed successfully.');
  }
}

capture();
