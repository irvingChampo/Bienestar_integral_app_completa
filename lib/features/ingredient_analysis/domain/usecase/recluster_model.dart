import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class ReclusterModel {
  final IngredientAnalysisRepository repository;
  ReclusterModel(this.repository);

  Future<String> call(int kitchenId) async {
    return await repository.recluster(kitchenId);
  }
}