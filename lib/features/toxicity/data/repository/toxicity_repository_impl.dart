import 'package:bienestar_integral_app/features/toxicity/data/datasource/toxicity_datasource.dart';
import 'package:bienestar_integral_app/features/toxicity/domain/entities/toxicity_response.dart';
import 'package:bienestar_integral_app/features/toxicity/domain/repository/toxicity_repository.dart';

class ToxicityRepositoryImpl implements ToxicityRepository {
  final ToxicityDatasource datasource;

  ToxicityRepositoryImpl({required this.datasource});

  @override
  Future<ToxicityResponse> validateText(String text) async {
    return await datasource.predict(text);
  }
}