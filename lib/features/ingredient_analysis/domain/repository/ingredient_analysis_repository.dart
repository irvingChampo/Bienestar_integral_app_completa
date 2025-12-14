import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';

abstract class IngredientAnalysisRepository {
  Future<String> trainModel();
  Future<PredictionResult> predict(Map<String, dynamic> data);
  Future<String> recluster();
  Future<DatasetSummary> getDataset();
  Future<IngredientHistory> getHistory(String ingrediente);
}