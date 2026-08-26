---
name: security
description: "Comprehensive security auditing, vulnerability discovery, and hardening skill for Web, React, PWA, Supabase, and Node.js ecosystems. Triggers on /security, security, audit security, security review, vulnerability check, penetration testing, RLS audit, secret leak scan, and code hardening."
metadata:
  author: snapan-market
  version: "1.0.0"
---

# 🛡️ Security Audit & Hardening Skill (`/security`)

Dokumentasi & instruksi protokol audit keamanan perangkat lunak (*Software Security Audit*) untuk mendeteksi kerentanan, mencegah kebocoran data, menguji Row Level Security (RLS), dan memperketat pertahanan sistem dari layer Frontend, API, hingga Database.

---

## 🎯 1. METODOLOGI & MATRIKS TINGKAT KEPARAHAN (SEVERITY MATRIX)

Setiap temuan keamanan wajib diklasifikasikan ke dalam 4 tingkatan standar industri (CVSS-aligned):

| Tingkat | Kriteria Dampak | Tindakan Wajib |
| :--- | :--- | :--- |
| 🔴 **CRITICAL** | Akses tanpa izin ke seluruh data pengguna (*data breach*), eksekusi kode jarak jauh (RCE), bypass autentikasi total, atau kebocoran `service_role` key. | Hentikan rilis, perbaiki seketika (*immediate fix*). |
| 🟠 **HIGH** | Modifikasi data pengguna lain (*IDOR / Insecure Direct Object Reference*), RLS policy bocor, Stored XSS, atau eskalasi hak akses (*Privilege Escalation*). | Perbaiki sebelum merge ke branch `main`. |
| 🟡 **MEDIUM** | Reflected/DOM XSS, session fixation, token CSRF lemah, tidak adanya rate limiting pada endpoint sensitif, atau informasi sensitif di log/console. | Jadwalkan perbaikan dalam sprint aktif. |
| 🔵 **LOW / INFO** | Missing security headers (CSP, HSTS, X-Frame-Options), versi library minor berisiko, atau praktik sanitasi input yang kurang ketat. | Catat dalam backlog hardening. |

---

## 🔍 2. CHECKLIST AUDIT KEAMANAN LINTAS LAYER

### A. Frontend, DOM & PWA Security
1. **Cross-Site Scripting (XSS)**:
   - Hindari penggunaan `dangerouslySetInnerHTML`, `innerHTML`, `eval()`, atau `document.write` tanpa sanitasi murni (gunakan parser aman seperti `DOMPurify`).
   - Pastikan seluruh interpolasi teks dari input pengguna di-escape secara default oleh React JSX.
2. **Penyimpanan Sesi & Token (Token Storage)**:
   - Dilarang menyimpan credential sensitif atau password plaintext di `localStorage` / `sessionStorage`.
   - Gunakan Supabase Client Auth token helper bawaan yang terenkripsi dan ter-refresh otomatis.
3. **Penyusupan Cache PWA & Service Worker**:
   - Pastikan Service Worker tidak meng-cache data privat transaksi (`/api/orders`, data saldo/pembayaran) ke dalam cache publik yang bisa dibaca saat offline oleh pihak lain di perangkat bersama.
4. **Clickjacking & Frame Busting**:
   - Pastikan header `X-Frame-Options: DENY` atau `Content-Security-Policy: frame-ancestors 'none'` aktif pada konfigurasi hosting (`vercel.json` / server header).

---

### B. Supabase, PostgreSQL & Row Level Security (RLS)
1. **Kebijakan Row Level Security (RLS)**:
   - Seluruh tabel publik **WAJIB** `ALTER TABLE <nama_tabel> ENABLE ROW LEVEL SECURITY;`.
   - **Tabel Privat (Pesanan, Keranjang, Notifikasi)**:
     - `SELECT`: `USING (auth.uid() = user_id)`
     - `INSERT`: `WITH CHECK (auth.uid() = user_id)`
     - `UPDATE`: `USING (auth.uid() = user_id)`
     - `DELETE`: `USING (auth.uid() = user_id)`
2. **Jebakan `user_metadata` vs `app_metadata`**:
   - **DILARANG KERAS** menggunakan `raw_user_meta_data` / `user_metadata` untuk penentuan hak akses (role admin / seller) di RLS Policy, karena nilai ini dapat diedit langsung oleh pengguna dari client!
   - Gunakan kolom `role` pada tabel `public.profiles` atau `app_metadata` yang hanya bisa dimodifikasi oleh admin/trigger server.
3. **Perlindungan `service_role` Key**:
   - Dilarang keras menaruh `SUPABASE_SERVICE_ROLE_KEY` di file `.env` frontend atau meng-import ke client React (`import.meta.env.VITE_...`).
   - Frontend hanya boleh menggunakan `VITE_SUPABASE_ANON_KEY` dengan public RLS.
4. **SQL Injection & Function Security**:
   - Gunakan parameter binding `eq()`, `filter()` bawaan Supabase JS SDK.
   - Pada Database Function PL/pgSQL, selalu sertakan `SECURITY DEFINER` dan `SET search_path = public;` untuk mencegah *search_path hijacking*.

---

### C. Autentikasi & Autorisasi (Auth Guardrails)
1. **Validasi OAuth Redirect URL**:
   - Pastikan `redirectTo` pada fungsi login mengarah ke domain whitelist resmi (bukan open redirect yang bisa dimanfaatkan untuk phishing).
2. **State & Sesi Pengguna**:
   - Pastikan fungsi logout (`signOut`) membersihkan state lokal, cache feed, dan sesi di browser secara menyeluruh.

---

### D. Sanitasi & Validasi Input
1. **Validasi Tipe Data & Range Nilai**:
   - Nilai angka harga (`price`), kuantitas (`quantity`), dan stok (`stock`) wajib divalidasi `> 0` dan tidak menerima angka negatif di sisi client maupun database constraint `CHECK (price >= 0)`.
2. **Pembersihan String (String Sanitization)**:
   - Sanitasi teks dari karakter berbahaya sebelum disimpan atau dikirim ke tautan luar (seperti nomor WhatsApp atau URL).

---

## 📋 3. FORMAT LAPORAN HASIL AUDIT (`/security`)

Saat perintah `/security` dijalankan, hasil audit wajib disajikan dalam struktur terstandarisasi:

```markdown
# 🛡️ Laporan Audit Keamanan Sistem

### 📊 Ringkasan Skor Keamanan
- 🔴 Critical: 0
- 🟠 High: 0
- 🟡 Medium: 0
- 🔵 Low / Info: 0

---

### 🚨 Temuan & Analisis Kerentanan

#### 1. [SEVERITY] Nama Kerentanan / Area Terpapar
- **Lokasi File**: `path/to/file.ts:line`
- **Kategori**: XSS / RLS / Auth / Secret Leak / Input Validation
- **Bukti Kerentanan (Evidence)**:
  Penjelasan detail bagaimana celah ini bisa dieksploitasi oleh pihak luar.
- **Rekomendasi Perbaikan (Remediation)**:
  ```typescript
  // Kode perbaikan yang aman
  ```

---

### ✅ Rekomendasi Hardening Tambahan
1. Langkah hardening jangka panjang.
2. Konfigurasi Content Security Policy (CSP) & Header keamanan.
```

---

## ⚡ 4. CARA MENJALANKAN AUDIT

Jalankan perintah berikut di OMP:
- Ketik **`/security`** untuk memulai pemindaian menyeluruh terhadap codebase.
