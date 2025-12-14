import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class GetAnalysisDataset {
  final IngredientAnalysisRepository repository;

  GetAnalysisDataset(this.repository);

  Future<DatasetSummary> call() async {
    return await repository.getDataset();
  }
}