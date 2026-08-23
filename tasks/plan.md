# Rencana Implementasi: Perbaikan Navigasi Search Page & Preservasi State Feed Detail

## 1. Analisis Masalah (Root Cause)
1. **Bug 1 (Tombol Kembali `[ ← ]` di Search Feed)**:
   - Saat user sedang melihat hasil pencarian feed (`isSubmitted === true`), tombol panah kiri `[ ← ]` di search pill memanggil `onBack()` yang langsung melakukan `window.history.back()` sehingga keluar dari Search Page dan kembali ke Home.
   - **Solusi**: Saat `isSubmitted === true` atau `searchQuery` ada isinya, tombol `[ ← ]` harus mereset status pencarian (`setIsSubmitted(false)` dan mengembalikan ke mode discovery Search Page) tanpa melempar user keluar ke Home Page. Hanya ketika Search Page dalam kondisi kosong awal (`!isSubmitted && !searchQuery`), tombol `[ ← ]` kembali ke Home.

2. **Bug 2 (Search Page State Hilang saat Buka Detail & Kembali)**:
   - Di `App.tsx`, `SearchPage` dirender kondisional: `{isSearchRoute && <SearchPage ... />}`.
   - Saat user mengklik postingan dari Search Page, `currentRoute` berubah menjadi `/@author/post/:id`, sehingga `isSearchRoute` bernilai `false`.
   - Akibatnya, `SearchPage` **ter-unmount dari DOM**.
   - Ketika user menekan Kembali dari `PostDetailPage`, `SearchPage` ter-mount ulang dari awal dengan `searchQuery = ''` dan `isSubmitted = false` (hasil pencarian hilang).
   - **Solusi**:
     - Pertahankan `SearchPage` di dalam DOM (menggunakan `hidden` / `block` atau state preservasi seperti `HomePage`) saat `selectedPost` sedang aktif dibuka dari halaman pencarian.
     - Saat menutup `PostDetailPage`, pastikan rute kembali ke `/search` dan Search Page tetap berada di tab & query pencarian yang sama.

---

## 2. Rincian Perubahan File
- **`src/ui/pages/SearchPage.tsx`**:
  - Perbarui tombol panah kiri `[ ← ]` di search pill:
    - Jika `isSubmitted || searchQuery`, klik `[ ← ]` akan memanggil `handleResetToDiscovery()` (reset `isSubmitted = false`, kosongkan query).
    - Jika sudah di halaman discovery awal, panggil `onBack()` untuk kembali ke Home.
- **`src/App.tsx`**:
  - Catat asal navigasi saat membuka postingan (`originRouteRef.current = currentRoute`).
  - Render `SearchPage` dengan preservasi DOM (`className={isSearchRoute || (selectedPost && originRoute === '/search') ? 'block' : 'hidden'}`) sehingga query pencarian, tab aktif, dan posisi scroll tidak hilang saat membuka dan menutup detail postingan.
  - Pastikan `handleClosePostDetail` mengembalikan rute ke `/search` jika dibuka dari Search Page.

---

## 3. Rencana Verifikasi
- `npx tsc --noEmit && npm run build` (0 TypeScript errors).
- Uji alur navigasi:
  1. Buka Search Page, ketik "web", submit pencarian feed.
  2. Klik tombol `[ ← ]` di search bar $\rightarrow$ pastikan kembali ke halaman discovery Search Page (bukan terlempar ke Home).
  3. Submit pencarian "web" lagi, klik postingan untuk membuka `PostDetailPage`.
  4. Klik tombol Kembali di `PostDetailPage` $\rightarrow$ pastikan langsung kembali ke Search Page dengan query "web" dan hasil pencarian yang tetap utuh!
