import 'package:bienestar_integral_app/features/ingredient_analysis/data/datasource/ingredient_analysis_datasource.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_list.dart'; // IMPORT NUEVO
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/repository/ingredient_analysis_repository.dart';

class IngredientAnalysisRepositoryImpl implements IngredientAnalysisRepository {
  final IngredientAnalysisDatasource datasource;

  IngredientAnalysisRepositoryImpl({required this.datasource});

  @override
  Future<DatasetSummary> getDataset(int kitchenId) async {
    return await datasource.getDataset(kitchenId);
  }

  @override
  Future<IngredientHistory> getHistory(int kitchenId, String ingrediente) async {
    return await datasource.getHistory(kitchenId, ingrediente);
  }

  @override
  Future<PredictionResult> predict(Map<String, dynamic> data) async {
    return await datasource.predict(data);
  }

  @override
  Future<String> recluster(int kitchenId) async {
    return await datasource.recluster(kitchenId);
  }

  @override
  Future<String> trainModel(int kitchenId) async {
    return await datasource.trainModel(kitchenId);
  }

  // NUEVA IMPLEMENTACIÓN
  @override
  Future<List<IngredientItem>> getIngredients() async {
    return await datasource.getIngredients();
  }
}