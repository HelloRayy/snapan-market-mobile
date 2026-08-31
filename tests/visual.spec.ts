import { test, expect } from '@playwright/test';

test.describe('1:1 Pop.site Visual Regression Suite', () => {
  test('Desktop Viewport (1440x900) - 1:1 Pixel Parity', async ({ page }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.goto('/app', { waitUntil: 'networkidle' });

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

    const videos = page.locator('video');

    await expect(page).toHaveScreenshot('target-desktop.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.02,
      animations: 'disabled',
      mask: [videos],
    });
  });

  test('Mobile Viewport (390x844) - 1:1 Pixel Parity', async ({ page }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/app', { waitUntil: 'networkidle' });

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

    const videos = page.locator('video');

    await expect(page).toHaveScreenshot('target-mobile.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.02,
      animations: 'disabled',
      mask: [videos],
    });
  });
});
