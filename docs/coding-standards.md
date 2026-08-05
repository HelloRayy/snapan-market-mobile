# Coding Standards & Best Practices

Dokumen ini berisi panduan dan standar penulisan kode di proyek **Snapan Market Mobile**.

---

## 🔵 1. TypeScript & Type Safety

- Gunakan **Strict Mode** TypeScript. Hindari penggunaan tipe `any`.
- Gunakan `interface` untuk struktur objek data/domain dan `type` untuk union/intersection.
- Selalu ekspor tipe dari folder `src/types/` agar terpusat dan tidak ada duplikasi.

```typescript
// Good
import { Product } from '@/types/product';

interface ProductCardProps {
  product: Product;
}
```

---

## 🟢 2. Component Design & React Patterns

- Gunakan **Functional Components** dengan `React.FC` atau `React.forwardRef`.
- Gunakan utility function `cn()` untuk menggabungkan class Tailwind secara dinamis.
- Gunakan `React.lazy` untuk pemuatan komponen halaman yang berat (Code Splitting).

```typescript
// Contoh Penggunaan cn()
import { cn } from '@/utils/cn';

<div className={cn('bg-slate-900 p-4 rounded-xl', isActive && 'border-emerald-500')} />
```

---

## 🟡 3. Tailwind CSS v4 Guidelines

- Gunakan variabel warna `@theme` di `src/index.css`.
- Gunakan warna bertema dark mode bawaan (`slate-900`, `slate-950`, `emerald-500`, `slate-100`).
- Pastikan area sentuh (touch targets) pada perangkat seluler berukuran minimal `44px x 44px`.

---

## 🔴 4. State Management (Zustand & React State)

- Gunakan **Zustand** di `src/ui/store/` untuk state global (seperti `cartStore` dan `userStore`).
- Gunakan `useState` lokal hanya untuk state internal komponen UI (misal: toggle modal, input text).
- Simpan data keranjang belanja secara otomatis ke `localStorage`.
