import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';

class IngredientHistoryModel extends IngredientHistory {
  IngredientHistoryModel({required super.ingrediente, required super.historial});

  factory IngredientHistoryModel.fromJson(Map<String, dynamic> json) {
    return IngredientHistoryModel(
      ingrediente: json['ingrediente'] ?? '',
      historial: (json['historial'] as List? ?? [])
          .map((e) => HistoryPointModel.fromJson(e))
          .toList(),
    );
  }
}

class HistoryPointModel extends HistoryPoint {
  HistoryPointModel({
    required super.fecha,
    required super.cluster,
    required super.cantidadCompras,
    required super.cantidadNormalizada,
  });

  factory HistoryPointModel.fromJson(Map<String, dynamic> json) {
    return HistoryPointModel(
      fecha: json['fecha'] ?? '',
      cluster: json['cluster'] ?? 0,
      cantidadCompras: json['cantidad_compras'] ?? 0,
      cantidadNormalizada: (json['cantidad_normalizada'] as num?)?.toDouble() ?? 0.0,
    );
  }
}