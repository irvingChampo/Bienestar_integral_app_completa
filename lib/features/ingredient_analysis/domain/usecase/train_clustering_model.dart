import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class TrainClusteringModel {
  final IngredientAnalysisRepository repository;
  TrainClusteringModel(this.repository);

  Future<String> call(int kitchenId) async {
    return await repository.trainModel(kitchenId);
  }
}