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
