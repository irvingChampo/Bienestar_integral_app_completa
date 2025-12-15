import 'package:bienestar_integral_app/features/toxicity/domain/entities/toxicity_response.dart';

abstract class ToxicityRepository {
  Future<ToxicityResponse> validateText(String text);
}