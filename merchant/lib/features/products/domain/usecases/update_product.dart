import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct implements UseCase<Product, UpdateProductParams> {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(UpdateProductParams params) async {
    return await repository.updateProduct(
      id: params.id,
      name: params.name,
      description: params.description,
      price: params.price,
      stock: params.stock,
      imageUrl: params.imageUrl,
    );
  }
}

class UpdateProductParams {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;

  const UpdateProductParams({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });
}
