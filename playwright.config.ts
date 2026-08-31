import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 45000,
  
  // SANGAT PENTING: Gunakan 1 worker untuk visual regression testing agar tidak terjadi perebutan GPU render
  workers: 1,
  fullyParallel: false,

  expect: {
    timeout: 10000,
    toHaveScreenshot: {
      maxDiffPixelRatio: 0.02, // Toleransi 2%
      threshold: 0.2,          // Sensitivitas warna piksel
      animations: 'disabled',  // Nonaktifkan animasi CSS otomatis
    },
  },

  use: {
    baseURL: 'http://127.0.0.1:5173',
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 2,      // Retina display resolution
    actionTimeout: 15000,
  },

  // Otomatis jalankan Vite dev server lokal saat visual test dijalankan
  webServer: {
    command: 'npm run dev',
    url: 'http://127.0.0.1:5173',
    reuseExistingServer: true,
    timeout: 30000,
  },
});
