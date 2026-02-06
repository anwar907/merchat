import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final bool refresh;

  const LoadProducts({this.page = 1, this.refresh = false});

  @override
  List<Object?> get props => [page, refresh];
}

class LoadProductById extends ProductEvent {
  final String id;

  const LoadProductById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateProductEvent extends ProductEvent {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;

  const CreateProductEvent({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, price, stock, imageUrl];
}

class UpdateProductEvent extends ProductEvent {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;

  const UpdateProductEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, description, price, stock, imageUrl];
}

class SyncProducts extends ProductEvent {
  const SyncProducts();
}
