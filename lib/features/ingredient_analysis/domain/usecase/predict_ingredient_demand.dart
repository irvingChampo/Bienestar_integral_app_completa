import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class PredictIngredientDemand {
  final IngredientAnalysisRepository repository;

  PredictIngredientDemand(this.repository);

  Future<PredictionResult> call(Map<String, dynamic> data) async {
    return await repository.predict(data);
  }
}