import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isSynced;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        imageUrl: json['imageUrl']?.toString(),
        createdAt:
            json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt:
            json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      log('❌ Error parsing ProductModel from JSON: $e');
      log('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt.toIso8601String(),
      updatedAt: product.updatedAt.toIso8601String(),
      isSynced: product.isSynced,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isSynced: isSynced,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory ProductModel.fromDatabase(Map<String, dynamic> map) {
    try {
      return ProductModel(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        stock: (map['stock'] as num?)?.toInt() ?? 0,
        imageUrl: map['imageUrl']?.toString(),
        createdAt:
            map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt:
            map['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
        isSynced: ((map['isSynced'] as int?) ?? 1) == 1,
      );
    } catch (e) {
      log('❌ Error parsing ProductModel from database: $e');
      log('Database data: $map');
      rethrow;
    }
  }
}
