import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_list.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class GetStoredIngredients {
  final IngredientAnalysisRepository repository;

  GetStoredIngredients(this.repository);

  Future<List<IngredientItem>> call() async {
    return await repository.getIngredients();
  }
}