import fs from 'fs';
import path from 'path';
import https from 'https';

const FONTS = [
  {
    name: 'instrument-serif-italic.woff2',
    url: 'https://fonts.gstatic.com/s/instrumentserif/v5/jizHRFtNs2ka5fXjeivQ4LroWlx-6zAjjH7M.woff2',
  },
  {
    name: 'satoshi-400.woff2',
    url: 'https://framerusercontent.com/third-party-assets/fontshare/wf/TTX2Z3BF3P6Y5BQT3IV2VNOK6FL22KUT/7QYRJOI3JIMYHGY6CH7SOIFRQLZOLNJ6/KFIAZD4RUMEZIYV6FQ3T3GP5PDBDB6JY.woff2',
  },
  {
    name: 'satoshi-500.woff2',
    url: 'https://framerusercontent.com/third-party-assets/fontshare/wf/P2LQKHE6KA6ZP4AAGN72KDWMHH6ZH3TA/ZC32TK2P7FPS5GFTL46EU6KQJA24ZYDB/7AHDUZ4A7LFLVFUIFSARGIWCRQJHISQP.woff2',
  },
  {
    name: 'satoshi-700.woff2',
    url: 'https://framerusercontent.com/third-party-assets/fontshare/wf/LAFFD4SDUCDVQEXFPDC7C53EQ4ZELWQI/PXCT3G6LO6ICM5I3NTYENYPWJAECAWDD/GHM6WVH6MILNYOOCXHXB5GTSGNTMGXZR.woff2',
  },
  {
    name: 'satoshi-900.woff2',
    url: 'https://framerusercontent.com/third-party-assets/fontshare/wf/NHPGVFYUXYXE33DZ75OIT4JFGHITX5PE/PSUTMASCDJTVPERDYJZPN23BVUFUCQIF/J64QX5IPOHK56I2KYUNBQ5M2XWZEYKYX.woff2',
  },
];

const IMAGES = [
  { name: 'avatar-1.png', url: 'https://framerusercontent.com/images/faaNGs13tJFdVwu9AmLhWZQ4iKY.png' },
  { name: 'avatar-2.png', url: 'https://framerusercontent.com/images/dvasWTfovyZZuh8eTWbsvvQw80U.png' },
  { name: 'avatar-3.png', url: 'https://framerusercontent.com/images/SOnU8rT2yRS5jR2ov0U1eC6T0.png' },
  { name: 'django-avatar.jpg', url: 'https://framerusercontent.com/images/KqkGbSLtwSpCaNdUkG8IFD3kNoA.jpg' },
  { name: 'responsive-mockup.png', url: 'https://framerusercontent.com/images/WYeXLQfd4HWciZeQrD0RgF5V8Dw.png' },
  { name: 'analytics-dashboard.png', url: 'https://framerusercontent.com/images/pcuazrEIpAoQPBPbCjblc9C1YJY.png' },
  { name: 'theme-1.jpg', url: 'https://framerusercontent.com/images/jvWQK1OAcvujJal5mRbPS1GGzuI.jpg' },
  { name: 'theme-2.jpg', url: 'https://framerusercontent.com/images/4cRxw5WzNfrPAjGUiEtbGYKewQw.jpg' },
  { name: 'theme-3.jpg', url: 'https://framerusercontent.com/images/00EUntV8RMJM5PyskAclGChN9s8.jpg' },
  { name: 'theme-4.jpg', url: 'https://framerusercontent.com/images/ANN0pcYUTu1irgW2Shitk6Y.jpg' },
  { name: 'theme-5.jpg', url: 'https://framerusercontent.com/images/U7ONvjSO4tFRexJCBv69x0O7I.jpg' },
  { name: 'theme-6.jpg', url: 'https://framerusercontent.com/images/FslHXXxXCDOMyOJzYO89SJJlvXA.jpg' },
  { name: 'theme-7.jpg', url: 'https://framerusercontent.com/images/7dO8cZCgml9VNEVN3iHoGpId9Dw.jpg' },
  { name: 'theme-8.jpg', url: 'https://framerusercontent.com/images/qZzGjNL8NXrwCD6Qf0liwVfZ3g.jpg' },
  { name: 'theme-9.jpg', url: 'https://framerusercontent.com/images/Qr7KMQJHcfeNk4LSsnK1id52E7g.jpg' },
  { name: 'phone-frame.jpg', url: 'https://framerusercontent.com/images/xYwfKaNeG7urMQUnPh6hUwvl1Yo.jpg' },
];

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    const file = fs.createWriteStream(dest);
    https
      .get(url, (response) => {
        if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
          return downloadFile(response.headers.location, dest).then(resolve).catch(reject);
        }
        response.pipe(file);
        file.on('finish', () => {
          file.close(resolve);
        });
      })
      .on('error', (err) => {
        fs.unlink(dest, () => {});
        reject(err);
      });
  });
}

async function run() {
  console.log('📦 [Asset Downloader] Mengunduh font lokal (.woff2)...');
  for (const font of FONTS) {
    const dest = path.join('public', 'fonts', font.name);
    process.stdout.write(`  ⏳ ${font.name}... `);
    try {
      await downloadFile(font.url, dest);
      console.log('✅ Selesai');
    } catch (e) {
      console.log('❌ Gagal:', e.message);
    }
  }

  console.log('\n🖼️ [Asset Downloader] Mengunduh gambar & mockup asli...');
  for (const img of IMAGES) {
    const dest = path.join('public', 'pop-assets', img.name);
    process.stdout.write(`  ⏳ ${img.name}... `);
    try {
      await downloadFile(img.url, dest);
      console.log('✅ Selesai');
    } catch (e) {
      console.log('❌ Gagal:', e.message);
    }
  }

  console.log('\n🎉 [Asset Downloader] Semua asset lokal siap digunakan!');
}

run();
