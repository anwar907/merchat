import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProduct implements UseCase<Product, CreateProductParams> {
  final ProductRepository repository;

  CreateProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) async {
    return await repository.createProduct(
      name: params.name,
      description: params.description,
      price: params.price,
      stock: params.stock,
      imageUrl: params.imageUrl,
    );
  }
}

class CreateProductParams {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;

  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });
}
