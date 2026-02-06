# Quick Start Guide - Merchant Product Management App

## ⚠️ PENTING: Konfigurasi Network

**JIKA DATA TIDAK MUNCUL**, masalahnya biasanya adalah Base URL!

### Cek Platform Yang Digunakan:

- **Android Emulator**: Gunakan `http://10.0.2.2:3000` ✅ (Default)
- **iOS Simulator**: Gunakan `http://localhost:3000`
- **Physical Device**: Gunakan `http://<IP_KOMPUTER>:3000`

**Ubah di file**: `lib/core/utils/constants.dart`

📖 **Panduan lengkap**: Lihat [TROUBLESHOOTING_NETWORK.md](TROUBLESHOOTING_NETWORK.md)

---

## Langkah Cepat untuk Menjalankan Aplikasi

### 1. Setup Backend (Terminal 1)

```bash
# Masuk ke folder backend
cd /Users/wwwaste/Documents/workspace/merchant-backend

# Install dependencies
npm install

# Jalankan server
npm start
```

Server akan berjalan di `http://localhost:3000`

✅ **Test server**: Buka browser → `http://localhost:3000/products` (harus muncul data JSON)

### 2. Setup & Run Flutter App (Terminal 2)

```bash
# Masuk ke folder merchant
cd /Users/wwwaste/Documents/workspace/merchant

# Install dependencies
flutter pub get

# Generate kode (jika belum)
dart run build_runner build --delete-conflicting-outputs

# Jalankan aplikasi
flutter run
```

### 3. Lihat Console Logs

Saat app berjalan, Anda akan melihat logs seperti:
```
🔄 Loading products - Page: 1, Refresh: false
🌐 Fetching: http://10.0.2.2:3000/products?_page=1&_limit=20
✅ Response status: 200
✅ Received 10 products
```

Jika tidak muncul atau ada ❌, check network configuration!

## Test Offline Mode

1. Jalankan aplikasi
2. Buat atau edit beberapa produk (akan tersimpan ke local)
3. Matikan WiFi atau enable Airplane Mode
4. Coba buat atau edit produk lagi (akan masuk ke pending queue)
5. Nyalakan kembali koneksi
6. Lihat produk otomatis tersinkronisasi!

## Troubleshooting

### Backend tidak bisa diakses

- Pastikan server JSON berjalan di `http://localhost:3000`
- Test dengan browser atau curl: `curl http://localhost:3000/products`

### Dependencies error

```bash
# Update dependencies
cd merchant
flutter pub upgrade
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Database error

```bash
# Clear app data di emulator/simulator
flutter clean
flutter run
```

## Fitur yang Bisa Dicoba

1. ✅ **List Products** - Scroll ke bawah untuk load more (pagination)
2. ✅ **View Detail** - Tap pada produk untuk lihat detail
3. ✅ **Create Product** - Tap FAB (+) untuk tambah produk baru
4. ✅ **Edit Product** - Di detail page, tap "Edit Product"
5. ✅ **Offline Mode** - Matikan internet dan coba create/edit
6. ✅ **Auto Sync** - Nyalakan kembali internet, produk otomatis sync
7. ✅ **Pull to Refresh** - Swipe down di list untuk refresh

## API Endpoints (Backend)

- GET `/products?_page=1&_limit=20` - List products
- GET `/products/:id` - Get product detail
- POST `/products` - Create product
- PUT `/products/:id` - Update product

Lihat README.md untuk dokumentasi lengkap!
