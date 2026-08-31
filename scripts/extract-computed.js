import { chromium } from '@playwright/test';
import fs from 'fs';

async function extractComputed(targetUrl = 'https://pop.site/') {
  console.log(`🔍 [Extract Computed] Menganalisis elemen & styling: ${targetUrl}...`);
  
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 2,
  });

  const page = await context.newPage();

  try {
    await page.goto(targetUrl, { waitUntil: 'networkidle', timeout: 45000 });
    await page.evaluate(() => document.fonts.ready);

    // Ambil computed styles untuk elemen penting
    const computedData = await page.evaluate(() => {
      const getStyles = (selector) => {
        const el = document.querySelector(selector);
        if (!el) return null;
        const cs = window.getComputedStyle(el);
        return {
          selector,
          fontFamily: cs.fontFamily,
          fontSize: cs.fontSize,
          fontWeight: cs.fontWeight,
          lineHeight: cs.lineHeight,
          letterSpacing: cs.letterSpacing,
          color: cs.color,
          backgroundColor: cs.backgroundColor,
          padding: cs.padding,
          margin: cs.margin,
          borderRadius: cs.borderRadius,
          border: cs.border,
          boxShadow: cs.boxShadow,
          width: cs.width,
          height: cs.height,
        };
      };

      // Query headings, buttons, nav, cards
      const headings = Array.from(document.querySelectorAll('h1, h2, h3, p, a, button')).map((el) => {
        const cs = window.getComputedStyle(el);
        return {
          tag: el.tagName.toLowerCase(),
          text: el.innerText ? el.innerText.slice(0, 50).replace(/\n/g, ' ') : '',
          fontFamily: cs.fontFamily,
          fontSize: cs.fontSize,
          fontWeight: cs.fontWeight,
          lineHeight: cs.lineHeight,
          letterSpacing: cs.letterSpacing,
          color: cs.color,
          padding: cs.padding,
          borderRadius: cs.borderRadius,
        };
      });

      return {
        headings: headings.filter((h) => h.text.length > 0).slice(0, 30),
      };
    });

    fs.writeFileSync('target-computed-styles.json', JSON.stringify(computedData, null, 2));
    console.log('✅ [Extract Computed] Berhasil mengekstrak computed styles ke: target-computed-styles.json');
    console.table(computedData.headings.slice(0, 10));
  } catch (err) {
    console.error('❌ [Extract Computed] Error:', err);
  } finally {
    await browser.close();
  }
}

const target = process.argv[2] || 'https://pop.site/';
extractComputed(target);
