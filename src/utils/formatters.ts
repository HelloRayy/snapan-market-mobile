/**
 * Format Angka ke Mata Uang Rupiah (IDR)
 * Example: 150000 -> "Rp 150.000"
 */
export function formatRupiah(amount: number): string {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0
  }).format(amount);
}

/**
 * Format Angka Besar menjadi Singkatan (misal: 1200 -> "1.2k")
 */
export function formatCompactNumber(num: number): string {
  return new Intl.NumberFormat('id-ID', {
    notation: 'compact',
    compactDisplay: 'short'
  }).format(num);
}

const SHORT_MONTHS_ID = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

const FULL_MONTHS_ID = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];

/**
 * Format timestamp adaptif bertingkat standar Threads & Twitter (Opsi 1):
 * - < 1 menit: "Baru saja"
 * - < 1 jam: "{m}m" (contoh: "15m")
 * - < 24 jam: "{j}j" (contoh: "2j")
 * - < 7 hari: "{h}h" (contoh: "3h")
 * - Tahun yang sama: "{tgl} {blnSingkat}" (contoh: "22 Agu", "6 Jul")
 * - Beda tahun: "{tgl} {blnSingkat} {yy}" (contoh: "22 Agu 25")
 */
export function formatSmartTimestamp(dateInput?: string | Date | number | null): { display: string; full: string } {
  if (!dateInput) return { display: 'Baru saja', full: 'Baru saja' };

  // If already relative string like "Baru saja" or "15m lalu" without ISO date
  if (typeof dateInput === 'string') {
    const trimmed = dateInput.trim();
    if (trimmed === 'Baru saja' || trimmed === 'Baru Saja') {
      return { display: 'Baru saja', full: 'Baru saja' };
    }

    // Clean legacy string formats like "15m lalu" -> "15m", "1j lalu" -> "1j", "2h lalu" -> "2h"
    if (trimmed.endsWith('lalu') || /^\d+[mjhd]\s*(lalu)?$/i.test(trimmed)) {
      const cleaned = trimmed
        .replace(/\s*lalu\s*/gi, '')
        .replace(/(\d+)\s*menit/gi, '$1m')
        .replace(/(\d+)\s*jam/gi, '$1j')
        .replace(/(\d+)\s*hari/gi, '$1h')
        .trim();
      return { display: cleaned, full: trimmed };
    }
  }

  const date = new Date(dateInput);
  if (isNaN(date.getTime())) {
    return { display: String(dateInput), full: String(dateInput) };
  }

  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffSec = Math.floor(diffMs / 1000);
  const diffMin = Math.floor(diffSec / 60);
  const diffHours = Math.floor(diffMin / 60);
  const diffDays = Math.floor(diffHours / 24);

  const day = date.getDate();
  const monthIdx = date.getMonth();
  const year = date.getFullYear();
  const currentYear = now.getFullYear();

  const hoursStr = String(date.getHours()).padStart(2, '0');
  const minutesStr = String(date.getMinutes()).padStart(2, '0');
  const full = `${day} ${FULL_MONTHS_ID[monthIdx]} ${year} pukul ${hoursStr}:${minutesStr} WIB`;

  // 1. Kurang dari 1 menit
  if (diffSec < 60) {
    return { display: 'Baru saja', full };
  }

  // 2. Kurang dari 1 jam -> "15m"
  if (diffMin < 60) {
    return { display: `${diffMin}m`, full };
  }

  // 3. Kurang dari 24 jam -> "2j"
  if (diffHours < 24) {
    return { display: `${diffHours}j`, full };
  }

  // 4. Kurang dari 7 hari -> "3h"
  if (diffDays < 7) {
    return { display: `${diffDays}h`, full };
  }

  // 5. Tahun yang sama -> "22 Agu"
  if (year === currentYear) {
    return { display: `${day} ${SHORT_MONTHS_ID[monthIdx]}`, full };
  }

  // 6. Beda tahun -> "22 Agu 25"
  const shortYear = String(year).slice(-2);
  return { display: `${day} ${SHORT_MONTHS_ID[monthIdx]} ${shortYear}`, full };
}

const EMOJI_REGEX = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/gu;

/**
 * Membersihkan emoji unicode dari string teks (misal judul produk/caption)
 */
export function stripEmojis(text?: string | null): string {
  if (!text) return '';
  return text.replace(EMOJI_REGEX, '').trim();
}

/**
 * Mengubah nama lengkap menjadi username slug yang valid (lowercase, tanpa spasi)
 * Example: "Raditya Rayhan" -> "radityarayhan"
 */
export function toUsernameSlug(name?: string | null, fallback = 'user'): string {
  if (!name || !name.trim()) return fallback;
  const slug = name.toLowerCase().replace(/\s+/g, '');
  return slug || fallback;
}
