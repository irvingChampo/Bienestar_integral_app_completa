import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class GetIngredientHistory {
  final IngredientAnalysisRepository repository;

  GetIngredientHistory(this.repository);

  Future<IngredientHistory> call(String ingrediente) async {
    return await repository.getHistory(ingrediente);
  }
}