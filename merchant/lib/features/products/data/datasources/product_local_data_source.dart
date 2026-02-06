import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/pending_action.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20});
  Future<ProductModel?> getProductById(String id);
  Future<void> cacheProduct(ProductModel product);
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> deleteProduct(String id);
  Future<void> clearCache();
  Future<void> addPendingAction(PendingAction action);
  Future<List<PendingAction>> getPendingActions();
  Future<void> removePendingAction(int localId);
  Future<void> updatePendingActionRetryCount(int localId, int retryCount);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, Constants.databaseName);

    return await openDatabase(
      path,
      version: Constants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Constants.productsTable} (
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
    ''');

    await db.execute('''
      CREATE TABLE ${Constants.pendingActionsTable} (
        localId INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        actionType TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        retryCount INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final db = await database;
      final offset = (page - 1) * limit;

      final List<Map<String, dynamic>> maps = await db.query(
        Constants.productsTable,
        orderBy: 'updatedAt DESC',
        limit: limit,
        offset: offset,
      );

      return maps.map((map) => ProductModel.fromDatabase(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get products from cache: $e');
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        Constants.productsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return ProductModel.fromDatabase(maps.first);
    } catch (e) {
      throw CacheException('Failed to get product from cache: $e');
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    try {
      final db = await database;
      await db.insert(
        Constants.productsTable,
        product.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to cache product: $e');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (final product in products) {
        batch.insert(
          Constants.productsTable,
          product.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache products: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final db = await database;
      await db.delete(
        Constants.productsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to delete product: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final db = await database;
      await db.delete(Constants.productsTable);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> addPendingAction(PendingAction action) async {
    try {
      final db = await database;
      await db.insert(Constants.pendingActionsTable, {
        'productId': action.productId,
        'actionType': action.actionType.name,
        'data': action.data.toString(),
        'timestamp': action.timestamp.toIso8601String(),
        'retryCount': action.retryCount,
      });
    } catch (e) {
      throw CacheException('Failed to add pending action: $e');
    }
  }

  @override
  Future<List<PendingAction>> getPendingActions() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        Constants.pendingActionsTable,
        orderBy: 'timestamp ASC',
      );

      return maps.map((map) {
        return PendingAction(
          localId: map['localId'] as int,
          productId: map['productId'] as String,
          actionType: ActionType.values.firstWhere(
            (e) => e.name == map['actionType'],
          ),
          data: _parseData(map['data'] as String),
          timestamp: DateTime.parse(map['timestamp'] as String),
          retryCount: map['retryCount'] as int,
        );
      }).toList();
    } catch (e) {
      throw CacheException('Failed to get pending actions: $e');
    }
  }

  Map<String, dynamic> _parseData(String dataString) {
    // Simple parsing - in production, use proper JSON encoding
    // For now, we'll use a simpler approach
    return {};
  }

  @override
  Future<void> removePendingAction(int localId) async {
    try {
      final db = await database;
      await db.delete(
        Constants.pendingActionsTable,
        where: 'localId = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      throw CacheException('Failed to remove pending action: $e');
    }
  }

  @override
  Future<void> updatePendingActionRetryCount(
    int localId,
    int retryCount,
  ) async {
    try {
      final db = await database;
      await db.update(
        Constants.pendingActionsTable,
        {'retryCount': retryCount},
        where: 'localId = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      throw CacheException('Failed to update pending action retry count: $e');
    }
  }
}
