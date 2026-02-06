# Panduan Konfigurasi Base URL

Jika aplikasi tidak menampilkan data, kemungkinan besar masalahnya adalah **Base URL** yang salah.

## Masalah Umum

`localhost:3000` **TIDAK AKAN BEKERJA** dari emulator/simulator karena localhost merujuk ke device itu sendiri, bukan ke komputer host Anda.

## Solusi Berdasarkan Platform

### 1. Android Emulator ✅ (Default)

**File**: `lib/core/utils/constants.dart`

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

`10.0.2.2` adalah IP khusus yang merujuk ke komputer host dari Android Emulator.

### 2. iOS Simulator

**File**: `lib/core/utils/constants.dart`

```dart
static const String baseUrl = 'http://localhost:3000';
// atau
static const String baseUrl = 'http://127.0.0.1:3000';
```

iOS Simulator bisa langsung akses localhost.

### 3. Physical Device (Android/iOS)

Cek IP komputer Anda terlebih dahulu:

**macOS/Linux:**
```bash
ifconfig | grep "inet "
# Cari IP seperti 192.168.x.x atau 10.0.x.x
```

**Windows:**
```bash
ipconfig
# Cari IPv4 Address
```

Kemudian ubah base URL:

```dart
static const String baseUrl = 'http://192.168.1.5:3000'; // Ganti dengan IP Anda
```

**PENTING**: Pastikan phone dan komputer dalam jaringan WiFi yang sama!

### 4. Web (Chrome)

```dart
static const String baseUrl = 'http://localhost:3000';
```

## Cara Mengubah Base URL

1. Buka file: `/Users/wwwaste/Documents/workspace/merchant/lib/core/utils/constants.dart`

2. Ubah baris:
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

3. Uncomment yang sesuai dengan platform Anda:
```dart
class Constants {
  // Android Emulator (Default)
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // iOS Simulator
  // static const String baseUrl = 'http://localhost:3000';
  
  // Physical Device (ganti dengan IP komputer Anda)
  // static const String baseUrl = 'http://192.168.1.5:3000';
  
  // Web
  // static const String baseUrl = 'http://localhost:3000';
  
  // ... rest of code
}
```

4. Save file dan **restart aplikasi** (bukan hot reload, tapi stop dan run lagi):
```bash
flutter run
```

## Cara Test Apakah Server Accessible

### Dari Browser di Komputer:
```
http://localhost:3000/products
```
Harus muncul data JSON.

### Dari Browser di Phone (Physical Device):
```
http://192.168.1.5:3000/products  # Ganti dengan IP Anda
```
Jika tidak bisa akses, berarti ada masalah network/firewall.

## Troubleshooting

### Error: "Connection refused" atau "Network error"

1. ✅ Pastikan JSON Server berjalan:
   ```bash
   cd /Users/wwwaste/Documents/workspace/merchant-backend
   npm start
   ```
   
2. ✅ Test di browser: `http://localhost:3000/products`

3. ✅ Ubah base URL sesuai platform

4. ✅ Restart aplikasi Flutter (bukan hot reload)

### Error: "No data displayed"

1. ✅ Check console logs untuk melihat URL yang dipanggil
2. ✅ Lihat ada error apa di console
3. ✅ Pastikan format data di `db.json` benar

### Firewall Issues (Physical Device)

Jika menggunakan physical device dan tidak bisa connect:

**macOS:**
```bash
# Allow incoming connections
System Preferences > Security & Privacy > Firewall
# Ensure Node/npm is allowed
```

**Windows:**
```bash
# Add firewall rule untuk port 3000
```

## Debug Mode

Aplikasi sekarang sudah dilengkapi dengan logging. Lihat console output saat menjalankan:

```
🔄 Loading products - Page: 1, Refresh: false
🌐 Fetching: http://10.0.2.2:3000/products?_page=1&_limit=20
✅ Response status: 200
✅ Received 10 products
✅ Products loaded: 10 items
```

Jika tidak ada log seperti ini, berarti ada masalah.

## Quick Fix Commands

```bash
# 1. Restart backend
cd /Users/wwwaste/Documents/workspace/merchant-backend
npm start

# 2. Clean & restart Flutter (Terminal baru)
cd /Users/wwwaste/Documents/workspace/merchant
flutter clean
flutter pub get
flutter run
```

## Recommended: Test di Android Emulator Dulu

Android Emulator dengan base URL `http://10.0.2.2:3000` adalah yang paling reliable untuk development.

Jika masih ada masalah setelah mengikuti panduan ini, share console output-nya!
