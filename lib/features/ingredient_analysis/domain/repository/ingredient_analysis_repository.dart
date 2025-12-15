import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_list.dart'; // IMPORT NUEVO
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';

abstract class IngredientAnalysisRepository {
  Future<String> trainModel(int kitchenId);
  Future<PredictionResult> predict(Map<String, dynamic> data);
  Future<String> recluster(int kitchenId);
  Future<DatasetSummary> getDataset(int kitchenId);
  Future<IngredientHistory> getHistory(int kitchenId, String ingrediente);

  // NUEVO METODO
  Future<List<IngredientItem>> getIngredients();
}