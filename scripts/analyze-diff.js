import fs from 'fs';
import path from 'path';
import { PNG } from 'pngjs';

async function analyzeDiff() {
  if (!fs.existsSync('test-results')) {
    return console.log('ℹ️ Belum ada folder test-results');
  }

  const dirs = fs.readdirSync('test-results').filter((d) => fs.statSync(path.join('test-results', d)).isDirectory());
  if (dirs.length === 0) return console.log('ℹ️ Tidak ada subfolder test-results');

  const diffPath = path.join('test-results', dirs[0], 'target-diff.png');
  if (!fs.existsSync(diffPath)) {
    return console.log(`ℹ️ File diff tidak ditemukan di ${diffPath}`);
  }

  const png = PNG.sync.read(fs.readFileSync(diffPath));
  console.log(`📐 Dimensi Layar: ${png.width} x ${png.height} px`);

  const diffY = new Set();
  for (let y = 0; y < png.height; y++) {
    for (let x = 0; x < png.width; x++) {
      const idx = (png.width * y + x) << 2;
      const r = png.data[idx],
        g = png.data[idx + 1],
        b = png.data[idx + 2];
      // Deteksi pixel diff warna merah / magenta
      if ((r > 200 && g < 60 && b < 60) || (r > 200 && g < 60 && b > 200)) {
        diffY.add(y);
      }
    }
  }

  const sorted = Array.from(diffY).sort((a, b) => a - b);
  console.log(`🔍 Total baris piksel berbeda: ${sorted.length}`);

  const clusters = [];
  let start = sorted[0],
    prev = sorted[0];
  for (let i = 1; i < sorted.length; i++) {
    if (sorted[i] - prev > 15) {
      clusters.push({ startY: start, endY: prev, height: prev - start + 1 });
      start = sorted[i];
    }
    prev = sorted[i];
  }
  if (sorted.length > 0) clusters.push({ startY: start, endY: prev, height: prev - start + 1 });

  console.log('📍 Klaster Koordinat Selisih Piksel (Y-axis):');
  console.table(clusters);
}

analyzeDiff();
