# CompuPay-Mobile

Aplikasi mobile untuk karyawan mengakses layanan HR & payroll secara mandiri (self-service) — mulai dari presensi berbasis lokasi dan kamera, melihat slip gaji, hingga mengajukan cuti — tanpa harus melalui proses manual/administratif. Aplikasi ini merupakan companion mobile dari backend CompuPay.

## Tech Stack

- **Framework:** Flutter (Dart SDK ^3.11.0)
- **HTTP Client:** package `http`
- **Konfigurasi environment:** `flutter_dotenv`
- **Notifikasi push:** Firebase Core + Firebase Messaging, dengan `flutter_local_notifications`
- **Lokasi & peta:** `geolocator` + `flutter_map` (OpenStreetMap, bukan Google Maps) untuk presensi berbasis lokasi
- **Kamera & file:** `camera`, `image_picker`, `file_picker`, `open_filex` (buka file/PDF), `path_provider`
- **Penyimpanan lokal:** `shared_preferences`
- **Izin perangkat:** `permission_handler`
- **Platform target:** Android, iOS, Web, Windows, Linux, macOS

## Fitur Utama

**Autentikasi**
- Login, lupa password, reset password, dan verifikasi OTP

**Dashboard & Profil**
- Ringkasan informasi karyawan di halaman utama
- Lihat dan edit profil karyawan

**Presensi (Attendance)**
- Check-in/check-out dengan foto kamera dan lokasi real-time (peta)
- Riwayat presensi harian

**Slip Gaji (Payslip)**
- Daftar dan detail slip gaji (rincian pendapatan & potongan)
- Unduh slip gaji dalam format PDF

**Pengajuan Cuti**
- Pengajuan cuti/sakit dengan lampiran dokumen pendukung
- Pelacakan status pengajuan

**Notifikasi**
- Penerimaan notifikasi push (Firebase Cloud Messaging) untuk update terkait presensi, payroll, dan pengajuan cuti

## Instalasi & Menjalankan Proyek

### Prasyarat
- Flutter SDK (sesuai `environment.sdk` di `pubspec.yaml`: `^3.11.0`)
- Backend CompuPay (API) sudah berjalan dan dapat diakses
- Untuk fitur notifikasi: konfigurasi Firebase project (`google-services.json` / `GoogleService-Info.plist`)

### Langkah instalasi

```bash
# 1. Clone repository
git clone <repository-url>
cd compupay_mobile

# 2. Install dependencies
flutter pub get

# 3. Buat file .env di root project berisi konfigurasi API
```

Aplikasi membaca base URL & konfigurasi API dari file `.env` (dimuat lewat `flutter_dotenv`) — sesuaikan dengan alamat backend CompuPay yang digunakan.

```bash
# 4. Jalankan aplikasi
flutter run
```

### Build untuk production

```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web       # Web
```

## Struktur Folder Singkat

```
lib/
├── core/
│   └── controllers/    # Logic autentikasi, presensi, home
├── models/           # Model data (profil, payslip, leave request, dll)
├── navigation/         # Routing antar halaman
├── providers/          # State/konfigurasi aplikasi
├── repositories/        # Pemanggilan API backend
├── screens/           # Halaman UI (login, dashboard, attendance, payslip, leave request, dll)
└── shared/            # Komponen & utilitas bersama
```
