import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';

class DatasetSummaryModel extends DatasetSummary {
  DatasetSummaryModel({required super.nItems, required super.sample});

  factory DatasetSummaryModel.fromJson(Map<String, dynamic> json) {
    return DatasetSummaryModel(
      nItems: json['n_items'] ?? 0,
      sample: (json['sample'] as List? ?? [])
          .map((e) => DatasetItemModel.fromJson(e))
          .toList(),
    );
  }
}

class DatasetItemModel extends DatasetItem {
  DatasetItemModel({
    required super.ingrediente,
    required super.categoriaId,
    required super.unidadMedida,
    required super.cantidadUnidad,
    required super.cantidadCompras,
    required super.tasaRecompra,
    required super.diasPromedio,
    required super.cluster,
  });

  factory DatasetItemModel.fromJson(Map<String, dynamic> json) {
    return DatasetItemModel(
      ingrediente: json['ingrediente'] ?? '',
      categoriaId: int.tryParse(json['categoria_id'].toString()) ?? 0,
      unidadMedida: json['unidad_medida'] ?? '',
      cantidadUnidad: (json['cantidad_unidad'] as num?)?.toDouble() ?? 0.0,
      cantidadCompras: json['cantidad_compras'] ?? 0,
      tasaRecompra: (json['tasa_recompra'] as num?)?.toDouble() ?? 0.0,
      diasPromedio: json['dias_promedio'] ?? 0,
      cluster: json['cluster'] ?? 0,
    );
  }
}