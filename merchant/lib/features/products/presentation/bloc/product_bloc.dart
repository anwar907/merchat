import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/sync_pending_actions.dart';
import '../../domain/usecases/update_product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final GetProductById getProductById;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final SyncPendingActions syncPendingActions;
  final NetworkInfo networkInfo;

  ProductBloc({
    required this.getProducts,
    required this.getProductById,
    required this.createProduct,
    required this.updateProduct,
    required this.syncPendingActions,
    required this.networkInfo,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductById>(_onLoadProductById);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<SyncProducts>(_onSyncProducts);

    // Listen to network changes and trigger sync
    networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        add(const SyncProducts());
      }
    });
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    log('🔄 Loading products - Page: ${event.page}, Refresh: ${event.refresh}');

    if (event.refresh) {
      emit(ProductLoading());
    } else if (state is ProductsLoaded) {
      emit((state as ProductsLoaded).copyWith(isLoadingMore: true));
    } else {
      emit(ProductLoading());
    }

    final failureOrProducts = await getProducts(
      GetProductsParams(page: event.page, limit: Constants.pageSize),
    );

    failureOrProducts.fold(
      (failure) {
        log('❌ Error loading products: ${failure.message}');
        emit(
          ProductError(
            message: _mapFailureToMessage(failure),
            isOffline: failure is NetworkFailure,
          ),
        );
      },
      (products) {
        log('✅ Products loaded: ${products.length} items');
        if (state is ProductsLoaded && !event.refresh) {
          final currentState = state as ProductsLoaded;
          final allProducts = [...currentState.products, ...products];
          emit(
            ProductsLoaded(
              products: allProducts,
              currentPage: event.page,
              hasMore: products.length == Constants.pageSize,
            ),
          );
        } else {
          emit(
            ProductsLoaded(
              products: products,
              currentPage: event.page,
              hasMore: products.length == Constants.pageSize,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final failureOrProduct = await getProductById(event.id);

    failureOrProduct.fold(
      (failure) {
        emit(
          ProductError(
            message: _mapFailureToMessage(failure),
            isOffline: failure is NetworkFailure,
          ),
        );
      },
      (product) {
        emit(ProductDetailLoaded(product));
      },
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final failureOrProduct = await createProduct(
      CreateProductParams(
        name: event.name,
        description: event.description,
        price: event.price,
        stock: event.stock,
        imageUrl: event.imageUrl,
      ),
    );

    failureOrProduct.fold(
      (failure) {
        log('❌ Error creating product: ${failure.message}');
        emit(
          ProductError(
            message: _mapFailureToMessage(failure),
            isOffline: failure is NetworkFailure,
          ),
        );
      },
      (product) {
        emit(
          ProductOperationSuccess(
            product: product,
            message: product.isSynced
                ? 'Product created successfully'
                : 'Product created and will sync when online',
          ),
        );
      },
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final failureOrProduct = await updateProduct(
      UpdateProductParams(
        id: event.id,
        name: event.name,
        description: event.description,
        price: event.price,
        stock: event.stock,
        imageUrl: event.imageUrl,
      ),
    );

    failureOrProduct.fold(
      (failure) {
        if (failure is ConflictFailure) {
          emit(
            ProductConflict(
              message: failure.message,
              serverData: failure.serverData,
            ),
          );
        } else {
          emit(
            ProductError(
              message: _mapFailureToMessage(failure),
              isOffline: failure is NetworkFailure,
            ),
          );
        }
      },
      (product) {
        emit(
          ProductOperationSuccess(
            product: product,
            message: product.isSynced
                ? 'Product updated successfully'
                : 'Product updated and will sync when online',
          ),
        );
      },
    );
  }

  Future<void> _onSyncProducts(
    SyncProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    emit(SyncInProgress());

    final failureOrSuccess = await syncPendingActions(const NoParams());

    failureOrSuccess.fold(
      (failure) {
        log('❌ Error syncing products: ${failure.message}');
        // Return to previous state if sync fails
        emit(currentState);
      },
      (_) {
        emit(SyncCompleted());
        // Reload products after sync
        add(const LoadProducts(refresh: true));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      case NetworkFailure:
        return 'No internet connection. Working offline.';
      case ConflictFailure:
        return failure.message;
      default:
        return 'Unexpected error occurred';
    }
  }
}
