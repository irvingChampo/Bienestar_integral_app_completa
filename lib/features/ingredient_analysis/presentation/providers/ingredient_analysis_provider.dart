import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_list.dart'; // IMPORT NUEVO
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_analysis_dataset.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_stored_ingredients.dart'; // IMPORT NUEVO
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/predict_ingredient_demand.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/recluster_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/train_clustering_model.dart';
import 'package:flutter/material.dart';

enum AnalysisStatus { initial, loading, success, error }

class IngredientAnalysisProvider extends ChangeNotifier {
  // Mantenemos las referencias aunque no las usemos todas
  final GetAnalysisDataset _getDataset;
  final TrainClusteringModel _trainModel;
  final ReclusterModel _reclusterModel;
  final PredictIngredientDemand _predictDemand;
  final GetIngredientHistory _getHistory;
  // NUEVO USECASE
  final GetStoredIngredients _getStoredIngredients;

  AnalysisStatus _status = AnalysisStatus.initial;
  String? _errorMessage;
  String? _successMessage;

  PredictionResult? _predictionResult;
  IngredientHistory? _history;

  // NUEVA LISTA
  List<IngredientItem> _ingredients = [];

  // DatasetSummary lo dejamos nulo siempre, ya no lo usamos
  DatasetSummary? get datasetSummary => null;

  IngredientAnalysisProvider({
    required GetAnalysisDataset getDataset,
    required TrainClusteringModel trainModel,
    required ReclusterModel reclusterModel,
    required PredictIngredientDemand predictDemand,
    required GetIngredientHistory getHistory,
    required GetStoredIngredients getStoredIngredients, // Inyectado
  })  : _getDataset = getDataset,
        _trainModel = trainModel,
        _reclusterModel = reclusterModel,
        _predictDemand = predictDemand,
        _getHistory = getHistory,
        _getStoredIngredients = getStoredIngredients;

  AnalysisStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  PredictionResult? get predictionResult => _predictionResult;
  IngredientHistory? get history => _history;
  List<IngredientItem> get ingredients => _ingredients; // Getter

  // --- MÉTODOS ACTIVOS ---

  // 1. Predecir
  Future<void> predict({
    required int kitchenId,
    required String ingrediente,
    required int categoriaId,
    required String unidadMedida,
    required double cantidadUnidad,
    required int cantidadCompras,
    required double tasaRecompra,
    required int diasPromedio,
  }) async {
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      final input = {
        "ingrediente": ingrediente,
        "categoria_id": categoriaId,
        "unidad_medida": unidadMedida,
        "cantidad_unidad": cantidadUnidad,
        "cantidad_compras": cantidadCompras,
        "tasa_recompra": tasaRecompra,
        "dias_promedio": diasPromedio,
      };

      _predictionResult = await _predictDemand(input);
      _status = AnalysisStatus.success;
    } catch (e) {
      _errorMessage = _mapFailureToMessage(e);
      _status = AnalysisStatus.error;
    }
    notifyListeners();
  }

  // 2. Obtener Historial
  Future<void> fetchHistory(int kitchenId, String ingredientName) async {
    if (ingredientName.isEmpty) return;
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      _history = await _getHistory(kitchenId, ingredientName);
      _status = AnalysisStatus.success;
    } catch (e) {
      _errorMessage = _mapFailureToMessage(e);
      _status = AnalysisStatus.error;
    }
    notifyListeners();
  }

  // 3. NUEVO: OBTENER LISTA DE INGREDIENTES
  Future<void> fetchStoredIngredients() async {
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      _ingredients = await _getStoredIngredients();
      _status = AnalysisStatus.success;
    } catch (e) {
      _errorMessage = _mapFailureToMessage(e);
      _status = AnalysisStatus.error;
    }
    notifyListeners();
  }

  // Método auxiliar que antes estaba en datasource (solo para entrenamiento si es necesario reintentar desde UI)
  Future<void> trainModel(int kitchenId) async {
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      await _trainModel(kitchenId);
      _successMessage = "Modelo re-entrenado exitosamente";
      _status = AnalysisStatus.success;
    } catch (e) {
      _errorMessage = _mapFailureToMessage(e);
      _status = AnalysisStatus.error;
    }
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _mapFailureToMessage(dynamic e) {
    if (e is ServerException) return e.message;
    if (e is NetworkException) return e.message;
    return "Error inesperado: $e";
  }
}