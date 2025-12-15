import 'package:bienestar_integral_app/features/toxicity/domain/entities/toxicity_response.dart';
import 'package:bienestar_integral_app/features/toxicity/domain/repository/toxicity_repository.dart';

class ValidateText {
  final ToxicityRepository repository;

  ValidateText(this.repository);

  Future<ToxicityResponse> call(String text) async {
    return await repository.validateText(text);
  }
}