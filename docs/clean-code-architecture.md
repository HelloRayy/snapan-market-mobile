# 🏛️ Panduan Arsitektur Clean Code & Long-Term Maintainability
**Proyek: Snapan Market Mobile (sNaps)**  
*Arsitektur Berbasis Feature-First Modular untuk Kemudahan Perawatan Jangka Panjang & Konsistensi AI Coding Agent*

---

## 🎯 1. Filosofi Arsitektur

Arsitektur **Snapan Market Mobile** dirancang berdasarkan prinsip **Feature-First Architecture**, **Separation of Concerns (SoC)**, dan **Single Source of Truth**.

### Tujuan Utama:
1. **Prediktabilitas Tinggi**: AI atau developer baru dapat menemukan file target dalam 1 kali pencarian tanpa perlu menelusuri seluruh repositori.
2. **Isolasi Fitur**: Modifikasi pada satu fitur (misalnya `auth` atau `checkout`) tidak akan menimbulkan efek domino yang merusak fitur lain (seperti `feed` atau `profile`).
3. **Mencegah Monolithic Code**: File dijaga tetap ramping (<250 baris) dengan memisahkan tampilan, logika bisnis, dan interaksi data.

---

## 📂 2. Struktur Direktori Utama (`lib/`)

```text
lib/
├── main.dart                          # App bootstrap, MaterialApp, theme global, route table
│
├── core/                              # Layer Pondasi (Shared Lintas Fitur)
│   ├── theme/                         # Token desain: app_colors.dart, typography
│   ├── components/                    # Atomic reusable widgets (snaps_logo.dart, kumo_button.dart)
│   ├── constants/                     # Konstanta aplikasi & asset paths
│   ├── navigation/                    # Transisi halaman kustom (app_slide_page_route.dart)
│   ├── services/                      # Service global (Supabase singleton, notification, registry)
│   │   ├── supabase/                  # Domain query supabase (feed, social, poll, profile)
│   │   ├── global_notification_service.dart
│   │   ├── student_registry_service.dart
│   │   └── device_security_service.dart
│   └── utils/                         # Helper murni (rupiah_formatter.dart, date_formatter.dart)
│
└── features/                          # Modul Fitur Berbasis Domain (Feature-First)
    ├── feed/                          # Linimasa beranda, postingan pasar & threads
    ├── auth/                          # Autentikasi NIS/Username, login, register
    ├── profile/                       # Profil siswa, portofolio kejuruan, edit profile
    ├── create_post/                   # Pembuat post pasar & voting polling
    ├── messages/                      # Direct messages & chat COD
    ├── checkout/                      # Keranjang, checkout COD, rincian pembayaran
    ├── locations/                     # Titik temu COD kampus SMKN 8
    ├── map/                           # Blueprint 2D peta interaktif kampus
    ├── search/                        # Pencarian produk & penemuan akun siswa
    ├── activity/                      # Notifikasi & riwayat interaksi
    └── onboarding/                    # Walkthrough pengenalan aplikasi
```

---

## 🧩 3. Anatomi Sebuah Fitur (`features/<nama_fitur>/`)

Setiap fitur dalam `lib/features/` memiliki struktur internal yang seragam:

```text
lib/features/<nama_fitur>/
├── screens/               # 1. ORCHESTRATOR (Halaman Utama)
│   └── <nama>_screen.dart # Hanya mengatur Scaffold, AppBar, layout dasar, dan state binding
│
├── components/            # 2. PRESENTATION (Sub-komponen visual terpecah)
│   ├── <nama>_header.dart
│   ├── <nama>_card.dart
│   └── <nama>_tab.dart
│
├── controllers/           # 3. STATE & LOGIC (State Controller)
│   └── <nama>_controller.dart # Mengatur state, validasi, dan orkestrasi pemanggilan service
│
└── models/                # 4. DATA CONTRACTS (Domain Models)
    └── <nama>_model.dart  # Data class immutabel dengan fromJson / toJson
```

---

## 🔒 4. Aturan Aliran Ketergantungan (Dependency Flow)

Untuk mencegah *circular dependency* dan *spaghetti code*, aturan impor kode mengikuti alur satu arah berikut:

$$\text{Screens} \longrightarrow \text{Components} \longrightarrow \text{Controllers} \longrightarrow \text{Services} \longrightarrow \text{Supabase / DB}$$

| Lapisan (Layer) | Boleh Mengimpor | DILARANG Mengimpor |
| :--- | :--- | :--- |
| **`models/`** | `core/constants/`, `core/utils/` | `screens/`, `controllers/`, `services/` |
| **`services/`** | `core/`, `models/`, SDK external (Supabase) | `screens/`, `components/` |
| **`controllers/`**| `services/`, `models/`, `core/` | `screens/`, `components/` |
| **`components/`** | `models/`, `core/theme/`, `core/components/` | Memanggil langsung SQL / query DB mentah |
| **`screens/`** | `controllers/`, `components/`, `core/` | Menulis query database langsung di dalam `build()` |

---

## 🛡️ 5. Prinsip Pertahanan Terhadap Efek Domino

1. **Jaga Kontrak Parameter**:
   - Jika mengubah constructor widget atau parameter controller, gunakan default value atau pertahankan backward compatibility agar tidak merusak pemanggil lain.
2. **Jangan Mengubah File di Luar Scope Tugas**:
   - Jika ditugaskan merapikan satu sub-komponen (misal kartu postingan), fokuslah hanya pada file sub-komponen tersebut. Jangan mengutak-atik routing global atau service database.
3. **Pemisahan Validasi & State**:
   - Validasi form sebaiknya didelegasikan ke controller atau validator helper teruji, bukan dicampur di tengah-tengah fungsi `onPressed` tombol.
