import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20});
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(Map<String, dynamic> productData);
  Future<ProductModel> updateProduct(
    String id,
    Map<String, dynamic> productData,
  );
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final url = '${Constants.baseUrl}/products';
      log('🌐 Fetching: $url?_page=$page&_limit=$limit');

      final response = await dio.get(
        url,
        queryParameters: {'_page': page, '_limit': limit},
      );

      log('✅ Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        log('✅ Received ${data.length} products');
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load products');
      }
    } on DioException catch (e) {
      log('❌ DioException: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else if (e.response?.statusCode == 409) {
        throw ConflictException(
          'Product data conflict',
          serverData: e.response?.data,
        );
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
      log('❌ Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await dio.get('${Constants.baseUrl}/products/$id');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to load product');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('Product not found');
      } else if (e.response?.statusCode == 409) {
        throw ConflictException(
          'Product data conflict',
          serverData: e.response?.data,
        );
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await dio.post(
        '${Constants.baseUrl}/products',
        data: productData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to create product');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else if (e.response?.statusCode == 409) {
        throw ConflictException(
          'Product data conflict',
          serverData: e.response?.data,
        );
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await dio.put(
        '${Constants.baseUrl}/products/$id',
        data: productData,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to update product');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('Product not found');
      } else if (e.response?.statusCode == 409) {
        throw ConflictException(
          'Product data conflict',
          serverData: e.response?.data,
        );
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
