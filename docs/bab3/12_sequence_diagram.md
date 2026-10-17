# 12. SEQUENCE DIAGRAM (PROSES REGISTRASI & LOGIN AKUN NIS)

**Dokumen**: Bab III - Bagian 3.10  
**Proyek**: Snapan Market Mobile (sNaps) - SMKN 8 Semarang  
**Teknologi**: Flutter Client, Supabase Auth Service, dan PostgreSQL  
**Fokus**: Pemodelan Alur Pesan Kronologis Antar Objek (*Temporal Message Sequences*)  

---

## 1. Definisi & Notasi Sequence Diagram
Sequence Diagram adalah jenis diagram interaksi UML yang memperlihatkan bagaimana objek-objek sistem berkolaborasi melalui pertukaran pesan (*message passing*) yang disusun dalam urutan waktu tertentu dari atas ke bawah. Notasi diagram mencakup:
- **Garis Kehidupan (*Lifeline*)**: Garis putus-putus vertikal yang merepresentasikan eksistensi objek sepanjang durasi interaksi.
- **Batang Aktivasi (*Activation Bar*)**: Kotak persegi panjang sempit pada garis hidup yang menandakan durasi saat objek aktif mengeksekusi operasi komputasi.
- **Fragmen Alternatif (`alt`)**: Kotak partisi bersyarat untuk menangani percabangan logika sukses vs kegagalan (*exception flow*).

---

## 2. Sequence Diagram 1: Proses Registrasi Akun Siswa (Verifikasi NIS)

Diagram ini memodelkan pendaftaran akun baru siswa dengan validasi silang ke master data buku induk sekolah:

```mermaid
sequenceDiagram
    autonumber
    actor Siswa as 👤 Siswa Pendaftar
    participant UI as 📱 RegisterScreen
    participant Ctrl as 🎮 AuthController
    participant Svc as 🌐 SupabaseAuthService
    participant DB_Reg as 🗄️ student_registry (Buku Induk)
    participant Auth_Svr as 🔐 Supabase Auth (auth.users)
    participant DB_Prof as 🗄️ profiles (Data Akun)

    Siswa->>UI: Input NIS, Username, Password, & Konfirmasi
    UI->>Ctrl: registerWithNis(nis, username, password)
    activate Ctrl
    
    Ctrl->>Svc: executeRegistration(payload)
    activate Svc
    
    %% TAHAP 1: VALIDASI BUKU INDUK
    Svc->>DB_Reg: SELECT * FROM student_registry WHERE nis = :nis AND is_active = true
    activate DB_Reg
    alt NIS Tidak Terdaftar / Tidak Aktif di SMKN 8
        DB_Reg-->>Svc: Data Kosong (0 Row)
        deactivate DB_Reg
        Svc-->>Ctrl: Throw Error: 'NIS tidak valid sebagai siswa aktif SMKN 8'
        Ctrl-->>UI: Emit State Error (NIS Ilegal)
        UI-->>Siswa: Tampilkan Dialog Penolakan: 'NIS Tidak Terdaftar'
    else NIS Terdaftar Valid
        DB_Reg-->>Svc: Record Siswa (Nama Lengkap, Kelas, Jurusan)
        
        %% TAHAP 2: CEK DUPLIKASI AKUN
        Svc->>DB_Prof: SELECT id FROM profiles WHERE nis = :nis
        activate DB_Prof
        alt NIS Sudah Pernah Didaftarkan Sebelumnya
            DB_Prof-->>Svc: Record Ditemukan (Duplikat)
            deactivate DB_Prof
            Svc-->>Ctrl: Throw Error: 'NIS ini sudah memiliki akun aktif'
            Ctrl-->>UI: Emit State Error (Akun Duplikat)
            UI-->>Siswa: Tampilkan Peringatan: 'Akun Sudah Ada, Silakan Login'
        else NIS Belum Pernah Didaftarkan (Fresh Account)
            DB_Prof-->>Svc: Data Kosong
            
            %% TAHAP 3: PEMBUATAN AKUN SUPABASE AUTH
            Svc->>Auth_Svr: signUp(email: nis@smkn8semarang.sch.id, password)
            activate Auth_Svr
            Auth_Svr-->>Svc: User Credential Created (UUID)
            deactivate Auth_Svr
            
            %% TAHAP 4: RECORD PROFILE RESMI
            Svc->>DB_Prof: INSERT INTO profiles (id, nis, username, full_name, class_group, role='user')
            activate DB_Prof
            DB_Prof-->>Svc: Profile Created Successfully
            deactivate DB_Prof
            
            Svc-->>Ctrl: Registrasi Sukses
            deactivate Svc
            Ctrl-->>UI: Emit State Sukses
            deactivate Ctrl
            UI-->>Siswa: Tampilkan Notifikasi Sukses & Arahkan ke Layar Login
        end
    end
```

---

## 3. Sequence Diagram 2: Proses Login Siswa & Device Binding

Diagram ini memodelkan interaksi saat siswa melakukan login dan sistem mengamankan sesi pada perangkat smartphone:

```mermaid
sequenceDiagram
    autonumber
    actor Siswa as 👤 Siswa
    participant UI as 📱 LoginScreen
    participant Ctrl as 🎮 AuthController
    participant Svc as 🌐 SupabaseAuthService
    participant Auth_Svr as 🔐 Supabase Auth (JWT Engine)
    participant DB_Prof as 🗄️ profiles
    participant DB_Dev as 🗄️ device_registrations

    Siswa->>UI: Input NIS & Password Akun
    UI->>Ctrl: login(nis, password)
    activate Ctrl
    
    Ctrl->>Svc: authenticate(nis, password)
    activate Svc
    
    Svc->>Auth_Svr: signInWithPassword(nis_email, password)
    activate Auth_Svr
    alt Kredensial Salah / Password Keliru
        Auth_Svr-->>Svc: 400 Bad Request (Invalid Credentials)
        deactivate Auth_Svr
        Svc-->>Ctrl: Throw AuthException: 'NIS atau Password salah'
        Ctrl-->>UI: Update State Gagal
        UI-->>Siswa: Tampilkan SnackBar Merah: 'Password Salah'
    else Kredensial Benar
        Auth_Svr-->>Svc: Session Valid (Access Token & User UUID)
        
        %% CEK REGISTRASI HARDWARE DEVICE
        Svc->>DB_Dev: SELECT COUNT(*) FROM device_registrations WHERE user_id = :uid
        activate DB_Dev
        DB_Dev-->>Svc: Jumlah Perangkat Terdaftar
        deactivate DB_Dev
        
        opt Belum Mencapai Batas Perangkat
            Svc->>DB_Dev: INSERT INTO device_registrations (user_id, device_id, device_model)
        end
        
        Svc->>DB_Prof: SELECT * FROM profiles WHERE id = :uid
        activate DB_Prof
        DB_Prof-->>Svc: Data Lengkap Siswa (Nama, Avatar, Jurusan)
        deactivate DB_Prof
        
        Svc-->>Ctrl: Login Sukses & Sesi Terverifikasi
        deactivate Svc
        Ctrl-->>UI: Update State Login Berhasil
        deactivate Ctrl
        UI-->>Siswa: Navigasi Otomatis Membuka Layar Beranda (Feed & Market)
    end
```

---

## 4. Evaluasi Alur Interaksi
1. **Pencegahan Akun Bodong (*Sybil Attack*)**:
   Melalui verifikasi di langkah (4-8) pada Diagram 1, pihak di luar SMKN 8 Semarang tidak akan pernah bisa membuat akun karena NIS mereka akan ditolak secara instan oleh tabel `student_registry`.
2. **Kepatuhan Satu Siswa Satu Identitas**:
   Pengecekan duplikasi pada langkah (10-15) memastikan bahwa siswa tidak dapat membuat banyak akun menggunakan satu nomor induk yang sama.
3. **Keamanan Sesi Perangkat (*Device Security*)**:
   Melalui pencatatan `device_registrations`, sistem dapat mendeteksi jika suatu akun diakses secara tidak wajar dari perangkat yang tidak dikenali.
