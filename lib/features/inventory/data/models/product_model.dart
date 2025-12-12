import 'package:bienestar_integral_app/features/inventory/domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.unit,
    required super.perishable,
    super.shelfLifeDays,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      unit: json['unit'] ?? 'pza',
      perishable: json['perishable'] ?? false,
      shelfLifeDays: json['shelfLifeDays'] != null
          ? int.tryParse(json['shelfLifeDays'].toString())
          : null,
    );
  }
}