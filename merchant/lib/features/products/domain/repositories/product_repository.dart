import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
  });
  Future<Either<Failure, Product>> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
  });
  Future<Either<Failure, void>> syncPendingActions();
}
