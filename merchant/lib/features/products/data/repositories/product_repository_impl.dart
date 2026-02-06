import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/pending_action.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteProducts = await remoteDataSource.getProducts(
            page: page,
            limit: limit,
          );

          // Cache the products
          await localDataSource.cacheProducts(remoteProducts);

          return Right(
            remoteProducts.map((model) => model.toEntity()).toList(),
          );
        } on NetworkException catch (e) {
          // Fall back to cache if network fails
          return await _getProductsFromCache(page, limit);
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        }
      } else {
        // Get from cache when offline
        return await _getProductsFromCache(page, limit);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, List<Product>>> _getProductsFromCache(
    int page,
    int limit,
  ) async {
    try {
      final localProducts = await localDataSource.getProducts(
        page: page,
        limit: limit,
      );
      return Right(localProducts.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteProduct = await remoteDataSource.getProductById(id);
          await localDataSource.cacheProduct(remoteProduct);
          return Right(remoteProduct.toEntity());
        } on NetworkException catch (e) {
          return await _getProductByIdFromCache(id);
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        }
      } else {
        return await _getProductByIdFromCache(id);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, Product>> _getProductByIdFromCache(String id) async {
    try {
      final localProduct = await localDataSource.getProductById(id);
      if (localProduct == null) {
        return const Left(CacheFailure('Product not found in cache'));
      }
      return Right(localProduct.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final tempId = 'temp_${now.millisecondsSinceEpoch}';

      final productData = {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Create local product immediately
      final localProduct = ProductModel(
        id: tempId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        isSynced: false,
      );

      await localDataSource.cacheProduct(localProduct);

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteProduct = await remoteDataSource.createProduct(
            productData,
          );

          // Replace temp product with real one
          await localDataSource.deleteProduct(tempId);
          await localDataSource.cacheProduct(
            ProductModel.fromEntity(
              remoteProduct.toEntity().copyWith(isSynced: true),
            ),
          );

          return Right(remoteProduct.toEntity());
        } on NetworkException catch (e) {
          // Add to pending actions
          await _addPendingCreateAction(tempId, productData);
          return Right(localProduct.toEntity());
        } on ServerException catch (e) {
          await _addPendingCreateAction(tempId, productData);
          return Right(localProduct.toEntity());
        }
      } else {
        // Add to pending actions
        await _addPendingCreateAction(tempId, productData);
        return Right(localProduct.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<void> _addPendingCreateAction(
    String productId,
    Map<String, dynamic> data,
  ) async {
    final action = PendingAction(
      productId: productId,
      actionType: ActionType.create,
      data: data,
      timestamp: DateTime.now(),
    );
    await localDataSource.addPendingAction(action);
  }

  @override
  Future<Either<Failure, Product>> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    try {
      final now = DateTime.now();

      final productData = {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'updatedAt': now.toIso8601String(),
      };

      // Update local product immediately
      final existingProduct = await localDataSource.getProductById(id);
      if (existingProduct == null) {
        return const Left(CacheFailure('Product not found'));
      }

      final updatedLocalProduct = ProductModel(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        createdAt: existingProduct.createdAt,
        updatedAt: now.toIso8601String(),
        isSynced: false,
      );

      await localDataSource.cacheProduct(updatedLocalProduct);

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteProduct = await remoteDataSource.updateProduct(
            id,
            productData,
          );

          await localDataSource.cacheProduct(
            ProductModel.fromEntity(
              remoteProduct.toEntity().copyWith(isSynced: true),
            ),
          );

          return Right(remoteProduct.toEntity());
        } on ConflictException catch (e) {
          return Left(ConflictFailure(e.message, serverData: e.serverData));
        } on NetworkException catch (e) {
          await _addPendingUpdateAction(id, productData);
          return Right(updatedLocalProduct.toEntity());
        } on ServerException catch (e) {
          await _addPendingUpdateAction(id, productData);
          return Right(updatedLocalProduct.toEntity());
        }
      } else {
        await _addPendingUpdateAction(id, productData);
        return Right(updatedLocalProduct.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<void> _addPendingUpdateAction(
    String productId,
    Map<String, dynamic> data,
  ) async {
    final action = PendingAction(
      productId: productId,
      actionType: ActionType.update,
      data: data,
      timestamp: DateTime.now(),
    );
    await localDataSource.addPendingAction(action);
  }

  @override
  Future<Either<Failure, void>> syncPendingActions() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final pendingActions = await localDataSource.getPendingActions();

      for (final action in pendingActions) {
        try {
          if (action.actionType == ActionType.create) {
            final remoteProduct = await remoteDataSource.createProduct(
              action.data,
            );

            // Replace temp product with real one
            await localDataSource.deleteProduct(action.productId);
            await localDataSource.cacheProduct(
              ProductModel.fromEntity(
                remoteProduct.toEntity().copyWith(isSynced: true),
              ),
            );

            await localDataSource.removePendingAction(action.localId!);
          } else if (action.actionType == ActionType.update) {
            final remoteProduct = await remoteDataSource.updateProduct(
              action.productId,
              action.data,
            );

            await localDataSource.cacheProduct(
              ProductModel.fromEntity(
                remoteProduct.toEntity().copyWith(isSynced: true),
              ),
            );

            await localDataSource.removePendingAction(action.localId!);
          }
        } on ConflictException catch (e) {
          // Handle conflict - for now, just remove the action
          // In production, you'd want to notify the user
          await localDataSource.removePendingAction(action.localId!);
        } on ServerException catch (e) {
          // Retry later
          final newRetryCount = action.retryCount + 1;
          await localDataSource.updatePendingActionRetryCount(
            action.localId!,
            newRetryCount,
          );
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Sync error: $e'));
    }
  }
}
