import 'package:bienestar_integral_app/features/inventory/data/models/product_model.dart';
import 'package:bienestar_integral_app/features/inventory/domain/entities/inventory_item.dart';

class InventoryItemModel extends InventoryItem {
  InventoryItemModel({
    required super.inventoryId,
    required super.quantity,
    required super.product,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> productData;

    if (json['product'] != null && json['product'] is Map) {
      productData = json['product'];
    } else {

      productData = Map<String, dynamic>.from(json);

      if (json['productId'] != null) {
        productData['id'] = json['productId'];
      }
    }

    return InventoryItemModel(
      inventoryId: json['inventoryId'] ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      product: ProductModel.fromJson(productData),
    );
  }
}