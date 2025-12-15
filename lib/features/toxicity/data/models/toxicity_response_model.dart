import 'package:bienestar_integral_app/features/toxicity/domain/entities/toxicity_response.dart';

class ToxicityResponseModel extends ToxicityResponse {
  ToxicityResponseModel({
    required super.permitido,
    required super.probOfensivo,
    required super.mensaje,
  });

  factory ToxicityResponseModel.fromJson(Map<String, dynamic> json) {
    return ToxicityResponseModel(
      permitido: json['permitido'] ?? false,
      probOfensivo: (json['prob_ofensivo'] as num?)?.toDouble() ?? 0.0,
      mensaje: json['mensaje'] ?? '',
    );
  }
}