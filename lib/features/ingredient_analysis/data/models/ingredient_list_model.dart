import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_list.dart';

class IngredientItemModel extends IngredientItem {
  IngredientItemModel({
    required super.id,
    required super.ingrediente,
    required super.categoriaId,
    required super.unidadMedida,
    required super.fechaCreacion,
    required super.etiqueta,
  });

  factory IngredientItemModel.fromJson(Map<String, dynamic> json) {
    return IngredientItemModel(
      id: json['id'] ?? 0,
      ingrediente: json['ingrediente'] ?? 'Desconocido',
      categoriaId: json['categoria_id'] ?? 0,
      unidadMedida: json['unidad_medida'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
      // Mapeamos la etiqueta. Si viene nula, ponemos "PENDIENTE"
      etiqueta: json['etiqueta'] ?? 'PENDIENTE',
    );
  }
}