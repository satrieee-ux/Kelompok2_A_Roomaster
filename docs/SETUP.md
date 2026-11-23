# Setup Lokal Roomaster

Panduan ini dijalankan **sekali** oleh koordinator (orang 1), lalu anggota lain cukup `git clone` dan langkah 3–5.

## 1. Prasyarat
- Flutter SDK stabil (Dart >= 3.4), `flutter doctor` tanpa error utama
- Git, dan akun GitHub kelompok
- Akses ke proyek Supabase kelompok (Project URL + anon public key)

## 2. Membuat folder platform (Android/iOS) — hanya orang 1, sekali
Folder `android/` dan `ios/` sengaja tidak disertakan. Nama folder berhuruf besar tidak valid sebagai nama paket Dart, jadi nama proyek ditetapkan eksplisit:

```bash
cd Kelompok2_A_Roomaster
flutter create --project-name roomaster --org id.ac.its --platforms android,ios .
```
Perintah ini hanya menambah file yang belum ada (`lib/` dan `pubspec.yaml` tetap). Hapus `test/widget_test.dart` bawaan karena merujuk `MyApp` yang tidak ada, lalu commit `android/` dan `ios/`.

## 3. Isi kunci Supabase
```bash
cp env.example.json env.json      # env.json diabaikan git
```
Isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` (Supabase Dashboard > Project Settings > API). Pakai **anon public key**, bukan `service_role`.

## 4. Pasang dependensi
```bash
flutter pub get
```

## 5. Jalankan
```bash
flutter run --dart-define-from-file=env.json
```
Di VS Code cukup tekan F5 (konfigurasi sudah ada di `.vscode/launch.json`).

## 6. Izin platform (setelah `flutter create`)
Fitur kamera/galeri/QR memerlukan izin berikut.

**Android** — `android/app/src/main/AndroidManifest.xml`, di dalam `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```
**iOS** — `ios/Runner/Info.plist`, di dalam `<dict>`:
```xml
<key>NSCameraUsageDescription</key><string>Dipakai untuk memindai QR ruangan dan memotret bukti.</string>
<key>NSPhotoLibraryUsageDescription</key><string>Dipakai untuk melampirkan foto dokumentasi.</string>
```
Untuk `url_launcher` di Android 11+, tambahkan di `<manifest>`:
```xml
<queries><intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent></queries>
```

## 7. Database
Skema sudah ada di `supabase/`. Urutan menjalankan di SQL Editor:
1. `supabase/reset/00_reset_public.sql` (opsional, hanya jika ingin mengulang dari nol)
2. `supabase/migrations/20261111000001_schema.sql`
3. `supabase/migrations/20261111000002_logic.sql`
4. `supabase/migrations/20261111000003_rls_storage.sql`
5. `supabase/migrations/20261111000004_tu_sarpras.sql`
6. `supabase/seed.sql`

Jika proyek Supabase kelompok sudah berisi database terbaru, langkah ini **tidak perlu diulang**.
