import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';

class PredictionResultModel extends PredictionResult {
  PredictionResultModel({
    required super.ingrediente,
    required super.cluster,
    required super.etiqueta,
    required super.sugerido,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    return PredictionResultModel(
      ingrediente: json['ingrediente'] ?? '',
      cluster: json['cluster'] ?? 0,
      etiqueta: json['etiqueta'] ?? 'Desconocido',
      sugerido: json['sugerido'] ?? '',
    );
  }
}