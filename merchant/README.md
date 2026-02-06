# Merchant Product Management App

Aplikasi Flutter production-ready untuk manajemen produk merchant dengan clean architecture, offline-first design, dan state management menggunakan Bloc.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Running the Application](#running-the-application)
- [Offline & Sync Strategy](#offline--sync-strategy)
- [Conflict Handling](#conflict-handling)
- [Testing](#testing)

## ✨ Features

- **Product List** - Daftar produk dengan pagination/infinite scroll
- **Product Detail** - Tampilan detail lengkap produk
- **Create Product** - Tambah produk baru
- **Edit Product** - Update informasi produk
- **Offline-First** - Aplikasi tetap berfungsi tanpa koneksi internet
- **Auto Sync** - Sinkronisasi otomatis saat koneksi kembali
- **Status Indicators** - Indikator jelas untuk loading, error, dan offline state
- **Sync Status** - Menampilkan status sinkronisasi produk (synced/not synced)

## 🏗 Architecture

Aplikasi ini menggunakan **Clean Architecture** dengan pemisahan layer yang jelas:

```
lib/
├── core/                      # Core functionality
│   ├── error/                # Error handling & exceptions
│   ├── network/              # Network info & connectivity
│   ├── usecases/             # Base usecase
│   └── utils/                # Constants & utilities
│
├── features/
│   └── products/
│       ├── data/             # Data Layer
│       │   ├── datasources/  # Remote & Local data sources
│       │   ├── models/       # Data models with JSON serialization
│       │   └── repositories/ # Repository implementation
│       │
│       ├── domain/           # Domain Layer
│       │   ├── entities/     # Business entities
│       │   ├── repositories/ # Repository interfaces
│       │   └── usecases/     # Business logic
│       │
│       └── presentation/     # Presentation Layer
│           ├── bloc/         # State management (Bloc)
│           ├── pages/        # UI screens
│           └── widgets/      # Reusable UI components
│
└── injection_container/      # Dependency Injection setup
```

### Layer Responsibilities

1. **Presentation Layer**: UI dan state management dengan Bloc
2. **Domain Layer**: Business logic dan entities
3. **Data Layer**: Data sources (remote API & local database) dan repository implementation

## 🛠 Tech Stack

- **Flutter** - Latest stable version
- **State Management** - flutter_bloc ^8.1.3
- **Local Database** - sqflite ^2.4.1
- **Network** - dio ^5.7.0
- **Dependency Injection** - get_it ^8.0.2
- **Connectivity** - connectivity_plus ^6.1.1, internet_connection_checker_plus ^2.7.2
- **Code Generation** - json_serializable, build_runner
- **Functional Programming** - dartz ^0.10.1

## 📁 Project Structure

```
merchant/
├── lib/
│   ├── core/
│   ├── features/
│   ├── injection_container/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md

merchant-backend/
├── db.json
├── package.json
└── README.md
```

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (3.10.4 atau lebih tinggi)
- Dart SDK
- Android Studio / VS Code
- Node.js (untuk backend)

### 1. Clone Repository

```bash
cd /Users/wwwaste/Documents/workspace/merchant
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Generate Code

Generate kode untuk JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Setup Backend

Backend menggunakan JSON Server dan terletak di folder terpisah:

```bash
cd /Users/wwwaste/Documents/workspace/merchant-backend
npm install
```

## 🎮 Running the Application

### 1. Start Backend Server

Di terminal pertama, jalankan backend:

```bash
cd /Users/wwwaste/Documents/workspace/merchant-backend
npm start
```

Server akan berjalan di `http://localhost:3000`

### 2. Run Flutter App

Di terminal kedua, jalankan aplikasi Flutter:

```bash
cd /Users/wwwaste/Documents/workspace/merchant
flutter run
```

**Untuk iOS Simulator:**
```bash
flutter run -d "iPhone 15 Pro"
```

**Untuk Android Emulator:**
```bash
flutter run -d emulator-5554
```

**Untuk Chrome (Web):**
```bash
flutter run -d chrome
```

## 📡 Offline & Sync Strategy

### Offline-First Approach

Aplikasi menggunakan strategi **offline-first** yang berarti:

1. **Read Operations**
   - Coba fetch data dari server terlebih dahulu
   - Jika gagal atau offline, ambil dari cache local (SQLite)
   - Data dari server selalu di-cache untuk penggunaan offline

2. **Write Operations (Create/Update)**
   - Simpan perubahan ke local database LANGSUNG
   - Jika online: sync ke server, update local dengan response
   - Jika offline: tambahkan ke pending actions queue
   - User mendapat feedback langsung tanpa menunggu network

### Pending Actions Queue

Sistem menggunakan **pending actions table** di SQLite untuk menyimpan operasi yang belum tersinkronisasi:

```sql
CREATE TABLE pending_actions (
  localId INTEGER PRIMARY KEY AUTOINCREMENT,
  productId TEXT NOT NULL,
  actionType TEXT NOT NULL,  -- 'create' or 'update'
  data TEXT NOT NULL,         -- JSON data
  timestamp TEXT NOT NULL,
  retryCount INTEGER DEFAULT 0
)
```

### Auto-Sync Mechanism

1. **Network Listener**
   - Bloc listen ke connectivity changes via NetworkInfo
   - Saat koneksi kembali, trigger automatic sync

2. **Sync Process**
   - Ambil semua pending actions dari queue (FIFO)
   - Execute setiap action secara berurutan
   - Jika sukses: hapus dari queue, update local data
   - Jika gagal: increment retry count (max 3 retries)
   - Jika conflict: hapus dari queue, notify user

3. **Retry Strategy**
   - Max retries: 3 kali
   - Retry delay: 5 detik (configurable)
   - Exponential backoff bisa ditambahkan untuk production

### Visual Indicators

- **Sync Status Icon**: Produk yang belum sync menampilkan icon `sync_disabled`
- **Offline Banner**: Toast notification saat offline
- **Sync Notification**: Success message saat sync selesai
- **Loading States**: Clear loading indicators untuk setiap operasi

## ⚠️ Conflict Handling

### Detection Strategy

Konflik terdeteksi melalui:

1. **HTTP 409 Response**
   - Server mengembalikan 409 Conflict
   - Biasanya karena `updatedAt` timestamp tidak match

2. **Timestamp Comparison**
   - Local `updatedAt` vs Server `updatedAt`
   - Jika server lebih baru = conflict

### Resolution Strategy

#### Conceptual Approach (Untuk JSON Server yang tidak enforce konflik):

1. **Last-Write-Wins**
   - Update terakhir yang menang
   - Paling sederhana tapi bisa kehilangan data

2. **Server-Wins** (Recommended untuk JSON Server)
   - Server data selalu prioritas
   - Local changes di-overwrite
   - User di-notify untuk review changes

3. **Manual Resolution** (Ideal untuk production)
   - Tampilkan dialog dengan:
     - Local changes
     - Server changes
     - Option untuk pilih mana yang dipakai atau merge

#### Implementation dalam Code

```dart
// Di Repository
catch (e) on ConflictException {
  return Left(ConflictFailure(
    e.message,
    serverData: e.serverData,
  ));
}

// Di Bloc
if (failure is ConflictFailure) {
  emit(ProductConflict(
    message: failure.message,
    serverData: failure.serverData,
  ));
}

// Di UI
if (state is ProductConflict) {
  _showConflictDialog(context, state);
}
```

### User Communication

Saat konflik terjadi:
1. Tampilkan dialog dengan pesan jelas
2. Tunjukkan perubahan yang conflict
3. Berikan opsi untuk:
   - Use server version
   - Keep local changes (jika memungkinkan)
   - Manual merge

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Test Coverage

Project ini sudah didesain untuk testability dengan:
- Repository pattern dengan interfaces
- Dependency injection
- Mocking capabilities dengan mockito
- Bloc testing dengan bloc_test

Contoh test yang bisa ditambahkan:
- Unit tests untuk use cases
- Repository tests dengan mock data sources
- Bloc tests untuk state transitions
- Widget tests untuk UI components

## 🎯 Design Decisions & Trade-offs

### 1. Offline-First

**Decision**: Semua operasi write disimpan local dulu, baru sync ke server

**Pros**:
- User experience lebih cepat
- Aplikasi tetap usable saat offline
- Mengurangi dependency ke network

**Cons**:
- Lebih kompleks dalam implementasi
- Perlu handle sync conflicts
- Storage overhead untuk pending actions

### 2. Clean Architecture

**Decision**: Pemisahan strict antara layers (domain, data, presentation)

**Pros**:
- Testability tinggi
- Maintainability bagus
- Scalable untuk fitur baru
- Independent dari framework/UI

**Cons**:
- Lebih banyak boilerplate code
- Learning curve lebih tinggi
- Development awal lebih lambat

### 3. Bloc for State Management

**Decision**: Menggunakan Bloc pattern untuk state management

**Pros**:
- Predictable state changes
- Easy to test
- Good separation of concerns
- Stream-based reactive programming

**Cons**:
- Boilerplate code
- Steeper learning curve
- Overkill untuk aplikasi sederhana

### 4. SQLite untuk Local Storage

**Decision**: Menggunakan sqflite untuk persistence

**Pros**:
- Relational database
- SQL queries untuk filtering/sorting
- Support untuk complex data
- Mature dan stable

**Cons**:
- Manual schema management
- Perlu write SQL
- Migration complexity

**Alternative Considered**: Hive (lebih simple tapi kurang powerful untuk queries)

### 5. Pending Actions Queue

**Decision**: Menyimpan pending operations dalam separate table

**Pros**:
- FIFO guarantee
- Easy to retry
- Can track retry count
- Independent dari product data

**Cons**:
- Additional database table
- Need to serialize/deserialize data
- Complexity dalam sync logic

## 📝 Future Improvements

1. **Conflict Resolution UI**
   - Implement full manual conflict resolution
   - Show diff view untuk changes

2. **Better Error Handling**
   - Retry dengan exponential backoff
   - Better error messages untuk users

3. **Caching Strategy**
   - Cache expiration
   - Partial updates untuk bandwidth optimization

4. **Testing**
   - Comprehensive unit tests
   - Integration tests
   - Widget tests untuk UI

5. **Performance**
   - Pagination optimization
   - Image caching
   - Database indexing

6. **Security**
   - Authentication & authorization
   - Encrypted local storage
   - API token management

## 👨‍💻 Development Notes

### Code Generation

Setiap kali ada perubahan pada models dengan `@JsonSerializable`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Untuk watch mode saat development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Debug Network

Untuk test offline mode di emulator/simulator:
- **Android**: Airplane mode atau disable WiFi
- **iOS**: Airplane mode atau disable WiFi
- **Chrome**: DevTools > Network > Offline

### Backend Data

Untuk reset database backend:

```bash
cd merchant-backend
# Backup current data
cp db.json db.backup.json

# Edit db.json atau restore dari backup
# Restart server untuk apply changes
```

## 📄 License

This project is created for take-home test purposes.

---

**Created by**: Senior Mobile Engineer Candidate
**Date**: February 2026
**Test**: Merchant Product Management App
