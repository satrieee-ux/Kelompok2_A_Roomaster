# Roomaster

**Aplikasi Peminjaman Ruangan dan Pelaporan Kerusakan Fasilitas ITS**

Proyek Kelompok 2 – DPP A, Institut Teknologi Sepuluh Nopember (ITS).

## Anggota Kelompok

| No | Nama | NRP |
|----|------|-----|
| 1 | Nayla Eka Widazulfia | _(isi)_ |
| 2 | Muhammad Satrio Adjie | 5026241065 |
| 3 | Christine Rotua Deborah H. | _(isi)_ |
| 4 | Thalia Harnum Fathina | _(isi)_ |
| 5 | Naina Mazaya Putri | _(isi)_ |
| 6 | Nayla Rameyza Alya | _(isi)_ |
| 7 | Salsa Aulia Azzahra H. | _(isi)_ |

## Deskripsi Singkat

Roomaster adalah aplikasi mobile untuk lingkungan ITS yang menyatukan pencarian ruangan berdasarkan jadwal, pengajuan dan persetujuan peminjaman, serta pelaporan kerusakan fasilitas dalam satu platform. Tiga peran pengguna:

- **Mahasiswa ITS**: mencari ruangan, mengajukan peminjaman beserta dokumen, check-in/check-out, melapor kerusakan (QR), dan berkirim pesan dengan TU.
- **Petugas Tata Usaha (TU)**: meninjau pengajuan, memberi catatan revisi, menyetujui atau menolak.
- **Petugas Sarana dan Prasarana (Sarpras)**: menindaklanjuti laporan kerusakan hingga selesai.

## Teknologi yang Digunakan

| Lapisan | Teknologi |
|---------|-----------|
| Aplikasi | Flutter (Dart >= 3.4) |
| State management | flutter_riverpod |
| Navigasi | go_router (redirect berdasarkan sesi login) |
| Backend | Supabase: Auth, PostgreSQL (PostgREST), Storage, Realtime |
| Logika server | SQL: view, RPC `SECURITY DEFINER`, trigger, RLS, pg_cron |
| Pendukung | image_picker, file_picker, mobile_scanner (QR), google_fonts, flutter_svg, intl, shared_preferences, url_launcher |
| Kolaborasi | Git dan GitHub |

## Arsitektur

Pola *feature-first*. Satu-satunya lapisan yang berbicara ke Supabase adalah `data/*_repo.dart`; layar hanya memanggil provider (`data/*_providers.dart`). Aturan bisnis berada di server (RLS, RPC, trigger), bukan di aplikasi. Dependensi impor hanya mengarah ke bawah: `features` -> `data` -> `core`, dan `core` tidak mengimpor `data` atau `features`.

## Struktur Folder (kerangka awal)

Keadaan saat ini: belum ada layar. Folder `features/*` hanya berisi `.gitkeep` agar struktur terlihat di Git, dan `router.dart` baru memuat satu rute placeholder. Layar, repo, provider, dan rute ditambahkan bertahap oleh paket commit 1-7.

```
Kelompok2_A_Roomaster/
├── .vscode/
│   └── launch.json
├── assets/
│   └── images/
│       ├── bg/
│       │   ├── auth.jpg
│       │   ├── myits.jpg
│       │   └── splash.jpg
│       ├── rooms/
│       │   ├── blue-class.jpg
│       │   ├── building.jpg
│       │   ├── class.jpg
│       │   ├── computer-lab.jpg
│       │   ├── hall.jpg
│       │   └── si-4202.jpg
│       ├── avatar.jpg
│       ├── logo-its.svg
│       └── logo.svg
├── docs/
│   └── SETUP.md
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── nav.dart
│   │   └── router.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── colors.dart
│   │   │   ├── text.dart
│   │   │   └── theme.dart
│   │   ├── utils/
│   │   │   ├── format.dart
│   │   │   ├── pick.dart
│   │   │   └── storage_url.dart
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_icon.dart
│   │       ├── bars.dart
│   │       ├── cards.dart
│   │       ├── forms.dart
│   │       ├── headers.dart
│   │       ├── icon_paths.dart
│   │       ├── misc.dart
│   │       ├── page.dart
│   │       ├── popups.dart
│   │       ├── status.dart
│   │       ├── success_page.dart
│   │       └── tabs.dart
│   ├── data/
│   │   ├── models.dart
│   │   └── supabase_client.dart
│   ├── features/
│   │   ├── auth/
│   │   │   └── .gitkeep
│   │   ├── booking/
│   │   │   └── .gitkeep
│   │   ├── home/
│   │   │   └── .gitkeep
│   │   ├── inbox/
│   │   │   └── .gitkeep
│   │   ├── profile/
│   │   │   └── .gitkeep
│   │   ├── report/
│   │   │   └── .gitkeep
│   │   ├── rooms/
│   │   │   └── .gitkeep
│   │   ├── sarpras/
│   │   │   └── .gitkeep
│   │   └── tu/
│   │       └── .gitkeep
│   └── main.dart
├── supabase/
│   ├── migrations/
│   │   ├── 20261111000001_schema.sql
│   │   ├── 20261111000002_logic.sql
│   │   ├── 20261111000003_rls_storage.sql
│   │   └── 20261111000004_tu_sarpras.sql
│   ├── reset/
│   │   └── 00_reset_public.sql
│   └── seed.sql
├── .gitignore
├── README.md
├── analysis_options.yaml
├── env.example.json
└── pubspec.yaml
```

### Yang akan ditambahkan oleh paket commit
- `lib/data/`: `*_repo.dart` (akses Supabase), `*_providers.dart` (Riverpod), `refresh_all.dart` (paket 1)
- `lib/features/<fitur>/`: layar dan file pendampingnya (paket 1-7)
- `lib/app/router.dart`: rute bertambah di tiap paket

### Penjelasan folder
| Folder | Isi |
|--------|-----|
| `lib/app/` | `app.dart` (MaterialApp.router), `router.dart` (semua rute + redirect sesi), `nav.dart` |
| `lib/core/theme/` | warna, tipografi, tema (mengikuti Design System) |
| `lib/core/widgets/` | komponen UI umum: tombol, ikon, header/navbar, kartu, form, popup, status, tab |
| `lib/core/utils/` | format tanggal/angka, pemilih file, URL storage |
| `lib/data/` | model, klien Supabase, dan (nanti) repo + provider |
| `lib/features/` | satu folder per fitur: `auth`, `home`, `rooms`, `booking`, `report`, `inbox`, `profile`, `tu`, `sarpras` |
| `supabase/` | migrasi SQL, seed, dan reset database |
| `docs/SETUP.md` | langkah setup lokal dan izin platform |

## Menjalankan

Ringkas (rincian di [`docs/SETUP.md`](docs/SETUP.md)):

```bash
flutter create --project-name roomaster --org id.ac.its --platforms android,ios .   # sekali, oleh koordinator
cp env.example.json env.json        # isi SUPABASE_URL dan SUPABASE_ANON_KEY
flutter pub get
flutter run --dart-define-from-file=env.json
```

`env.json` berisi kunci proyek dan **tidak boleh di-commit** (sudah ada di `.gitignore`).

## Urutan Pengerjaan (Commit Bertahap)

Repositori dibangun bertahap lewat 7 paket. Tiap paket dikerjakan oleh satu anggota di branch sendiri, dibuka sebagai Pull Request, dan di-merge ke `main` **berurutan** (paket N hanya dimulai setelah paket N-1 ter-merge). Panduan taruh file, perubahan router, dan pesan commit ada di README di dalam tiap paket.

| Paket | Pemegang | Cakupan |
|-------|----------|---------|
| 1 | Muhammad Satrio Adjie | Lapisan data, splash, login |
| 2 | Nayla Eka Widazulfia | Detail ruangan, ruang chat, ringkasan laporan |
| 3 | Christine Rotua Deborah H. | Login ITS, notifikasi, daftar chat, ubah profil |
| 4 | Thalia Harnum Fathina | Beranda, signup, profil, tindak lanjut Sarpras |
| 5 | Naina Mazaya Putri | Form dan riwayat laporan, modul TU |
| 6 | Nayla Rameyza Alya | Daftar ruangan, pencarian, form booking, check-in |
| 7 | Salsa Aulia Azzahra H. | Dokumen booking, check-out, scan QR, modul Sarpras, RoleGate |

## Commit Awal (oleh orang 1)

```bash
git init -b main
git add .
git commit -m "chore: kerangka awal proyek Roomaster"
```
Langkah GitHub selengkapnya ada di README Paket 1.

## Database

Skema, logika, RLS, dan seed ada di `supabase/`. Proyek Supabase kelompok memakai kondisi database terbaru yang sama dengan berkas-berkas ini.
