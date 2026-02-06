import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductById implements UseCase<Product, String> {
  final ProductRepository repository;

  GetProductById(this.repository);

  @override
  Future<Either<Failure, Product>> call(String id) async {
    return await repository.getProductById(id);
  }
}
