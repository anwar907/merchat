# 📂 Complete Project Structure

## Flutter Application Structure

```
merchant/
├── android/                           # Android native configuration
├── ios/                               # iOS native configuration  
├── lib/
│   ├── core/
│   │   ├── error/
│   │   │   ├── exceptions.dart       # Custom exceptions
│   │   │   └── failures.dart         # Failure types untuk Either
│   │   ├── network/
│   │   │   └── network_info.dart     # Network connectivity detection
│   │   ├── usecases/
│   │   │   └── usecase.dart          # Base UseCase class
│   │   └── utils/
│   │       └── constants.dart        # App constants
│   │
│   ├── features/
│   │   └── products/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   ├── product_local_data_source.dart    # SQLite operations
│   │       │   │   └── product_remote_data_source.dart   # API calls
│   │       │   ├── models/
│   │       │   │   ├── product_model.dart               # Data model
│   │       │   │   └── product_model.g.dart             # Generated JSON code
│   │       │   └── repositories/
│   │       │       └── product_repository_impl.dart     # Repository implementation
│   │       │
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   ├── pending_action.dart              # Pending sync entity
│   │       │   │   └── product.dart                     # Product entity
│   │       │   ├── repositories/
│   │       │   │   └── product_repository.dart          # Repository interface
│   │       │   └── usecases/
│   │       │       ├── create_product.dart              # Create product use case
│   │       │       ├── get_product_by_id.dart           # Get single product
│   │       │       ├── get_products.dart                # Get products list
│   │       │       ├── sync_pending_actions.dart        # Sync offline actions
│   │       │       └── update_product.dart              # Update product
│   │       │
│   │       └── presentation/
│   │           ├── bloc/
│   │           │   ├── product_bloc.dart                # Main Bloc
│   │           │   ├── product_event.dart               # Events
│   │           │   └── product_state.dart               # States
│   │           ├── pages/
│   │           │   ├── product_detail_page.dart         # Detail screen
│   │           │   ├── product_form_page.dart           # Create/Edit screen
│   │           │   └── product_list_page.dart           # List screen
│   │           └── widgets/
│   │               # (Currently empty, dapat ditambahkan shared widgets)
│   │
│   ├── injection_container/
│   │   └── injection_container.dart   # Dependency injection setup
│   │
│   └── main.dart                      # App entry point
│
├── test/
│   └── widget_test.dart               # Sample test
│
├── linux/                             # Linux native configuration
├── macos/                             # macOS native configuration
├── web/                               # Web configuration
├── windows/                           # Windows native configuration
│
├── .gitignore                         # Git ignore file
├── analysis_options.yaml              # Linter rules
├── pubspec.yaml                       # Dependencies
├── README.md                          # Main documentation
├── QUICKSTART.md                      # Quick start guide
└── PROJECT_SUMMARY.md                 # Project summary

```

## Backend Structure

```
merchant-backend/
├── db.json                            # JSON database (10 products)
├── package.json                       # NPM dependencies
├── README.md                          # Backend documentation
└── .gitignore                         # Git ignore
```

## Key Files Explanation

### Core Layer Files

**exceptions.dart**
- ServerException
- CacheException
- NetworkException
- ConflictException

**failures.dart**
- ServerFailure
- CacheFailure
- NetworkFailure
- ConflictFailure

**network_info.dart**
- NetworkInfo interface
- NetworkInfoImpl dengan connectivity checking
- Stream untuk listen network changes

**usecase.dart**
- Base UseCase abstract class
- NoParams class untuk use cases tanpa parameter

**constants.dart**
- Base URL
- Page size
- Database name & version
- Sync retry configuration

### Data Layer Files

**product_local_data_source.dart**
- SQLite database initialization
- CRUD operations untuk products
- Pending actions queue management
- Cache operations

**product_remote_data_source.dart**
- Dio HTTP client setup
- GET /products (paginated)
- GET /products/:id
- POST /products
- PUT /products/:id
- Error handling & exceptions

**product_model.dart & .g.dart**
- ProductModel class
- JSON serialization/deserialization
- Database conversion
- Entity conversion

**product_repository_impl.dart**
- Repository pattern implementation
- Offline-first logic
- Network checking
- Pending actions management
- Sync mechanism

### Domain Layer Files

**product.dart**
- Product entity (pure Dart)
- Business model
- Equatable implementation

**pending_action.dart**
- PendingAction entity
- ActionType enum (create, update)
- Sync queue model

**product_repository.dart**
- Repository interface
- Method contracts

**Use Cases:**
- Each use case: Single responsibility
- Input: Parameters
- Output: Either<Failure, Result>

### Presentation Layer Files

**product_bloc.dart**
- Event handlers
- State emitters
- Network listener
- Business logic coordination

**product_event.dart**
- LoadProducts
- LoadProductById
- CreateProductEvent
- UpdateProductEvent
- SyncProducts

**product_state.dart**
- ProductInitial
- ProductLoading
- ProductsLoaded
- ProductDetailLoaded
- ProductOperationSuccess
- ProductError
- ProductConflict
- SyncInProgress
- SyncCompleted

**Pages:**
- ProductListPage: Infinite scroll, pull-to-refresh
- ProductDetailPage: Product details, edit navigation
- ProductFormPage: Form validation, create/update

### Dependency Injection

**injection_container.dart**
- GetIt setup
- Singleton registrations
- Factory registrations
- Dependency graph

### Main Entry Point

**main.dart**
- App initialization
- Dependency injection init
- BlocProvider setup
- MaterialApp configuration

## Database Schema

### Products Table
```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price REAL NOT NULL,
  stock INTEGER NOT NULL,
  imageUrl TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL,
  isSynced INTEGER NOT NULL DEFAULT 1
)
```

### Pending Actions Table
```sql
CREATE TABLE pending_actions (
  localId INTEGER PRIMARY KEY AUTOINCREMENT,
  productId TEXT NOT NULL,
  actionType TEXT NOT NULL,
  data TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  retryCount INTEGER NOT NULL DEFAULT 0
)
```

## Dependencies Overview

### Production Dependencies
- flutter_bloc: State management
- equatable: Value equality
- get_it: Service locator
- dio: HTTP client
- sqflite: SQLite database
- connectivity_plus: Network detection
- internet_connection_checker_plus: Internet verification
- dartz: Functional programming (Either)
- intl: Date formatting
- path & path_provider: File system

### Development Dependencies
- build_runner: Code generation runner
- json_serializable: JSON serialization generator
- mockito: Mocking framework
- bloc_test: Bloc testing utilities
- flutter_test: Testing framework
- flutter_lints: Linter rules

## Generated Files

Files dengan `.g.dart` extension adalah auto-generated oleh build_runner:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Generated:**
- product_model.g.dart

## Configuration Files

- **pubspec.yaml**: Dependencies & assets
- **analysis_options.yaml**: Linter configuration
- **.gitignore**: Files to ignore in git
- **README.md**: Main documentation
- **QUICKSTART.md**: Quick start instructions
- **PROJECT_SUMMARY.md**: Project overview

## Total Files Created

- **Dart Files**: ~25 files
- **Documentation**: 4 files (README, QUICKSTART, SUMMARY, STRUCTURE)
- **Configuration**: pubspec.yaml, analysis_options.yaml
- **Backend**: 3 files (package.json, db.json, README.md)

## Lines of Code (Approximate)

- Core: ~200 lines
- Data Layer: ~800 lines
- Domain Layer: ~300 lines
- Presentation Layer: ~700 lines
- DI & Main: ~100 lines
- **Total: ~2100 lines of Dart code**

Plus documentation: ~1500 lines

## Architecture Visualization

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  ┌─────────┐  ┌────────┐  ┌─────────────────┐  │
│  │  Bloc   │  │ Pages  │  │    Widgets      │  │
│  └─────────┘  └────────┘  └─────────────────┘  │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│               Domain Layer                       │
│  ┌──────────┐  ┌────────────┐  ┌────────────┐  │
│  │ Entities │  │ Use Cases  │  │ Repository │  │
│  │          │  │            │  │ Interfaces │  │
│  └──────────┘  └────────────┘  └────────────┘  │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│                Data Layer                        │
│  ┌──────────┐  ┌─────────────┐  ┌───────────┐  │
│  │  Models  │  │ Data Sources│  │Repository │  │
│  │          │  │ Local/Remote│  │   Impl    │  │
│  └──────────┘  └─────────────┘  └───────────┘  │
└─────────────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
┌───────▼────────┐    ┌───────▼────────┐
│  SQLite DB     │    │   REST API     │
│  (Local Cache) │    │  (JSON Server) │
└────────────────┘    └────────────────┘
```

---

**All files are production-ready and follow Flutter best practices!** ✅
