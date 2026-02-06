import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductsLoaded({
    required this.products,
    required this.currentPage,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [products, currentPage, hasMore, isLoadingMore];
}

class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductOperationSuccess extends ProductState {
  final Product product;
  final String message;

  const ProductOperationSuccess({required this.product, required this.message});

  @override
  List<Object?> get props => [product, message];
}

class ProductError extends ProductState {
  final String message;
  final bool isOffline;

  const ProductError({required this.message, this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}

class ProductConflict extends ProductState {
  final String message;
  final Map<String, dynamic>? serverData;

  const ProductConflict({required this.message, this.serverData});

  @override
  List<Object?> get props => [message, serverData];
}

class SyncInProgress extends ProductState {}

class SyncCompleted extends ProductState {}
