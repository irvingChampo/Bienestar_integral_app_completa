import 'package:bienestar_integral_app/features/ingredient_analysis/data/datasource/ingredient_analysis_datasource.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class IngredientAnalysisRepositoryImpl implements IngredientAnalysisRepository {
  final IngredientAnalysisDatasource datasource;

  IngredientAnalysisRepositoryImpl({required this.datasource});

  @override
  Future<DatasetSummary> getDataset() async {
    return await datasource.getDataset();
  }

  @override
  Future<IngredientHistory> getHistory(String ingrediente) async {
    return await datasource.getHistory(ingrediente);
  }

  @override
  Future<PredictionResult> predict(Map<String, dynamic> data) async {
    return await datasource.predict(data);
  }

  @override
  Future<String> recluster() async {
    return await datasource.recluster();
  }

  @override
  Future<String> trainModel() async {
    return await datasource.trainModel();
  }
}