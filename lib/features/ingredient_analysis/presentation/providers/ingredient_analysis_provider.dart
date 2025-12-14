import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/dataset_summary.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/prediction_result.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_analysis_dataset.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/get_ingredient_history.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/predict_ingredient_demand.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/recluster_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/domain/usecase/train_clustering_model.dart';
import 'package:flutter/material.dart';

enum AnalysisStatus { initial, loading, success, error }

class IngredientAnalysisProvider extends ChangeNotifier {
  final GetAnalysisDataset _getDataset;
  final TrainClusteringModel _trainModel;
  final ReclusterModel _reclusterModel;
  final PredictIngredientDemand _predictDemand;
  final GetIngredientHistory _getHistory;

  AnalysisStatus _status = AnalysisStatus.initial;
  String? _errorMessage;
  String? _successMessage;

  // Data
  DatasetSummary? _datasetSummary;
  PredictionResult? _predictionResult;
  IngredientHistory? _history;

  IngredientAnalysisProvider({
    required GetAnalysisDataset getDataset,
    required TrainClusteringModel trainModel,
    required ReclusterModel reclusterModel,
    required PredictIngredientDemand predictDemand,
    required GetIngredientHistory getHistory,
  })  : _getDataset = getDataset,
        _trainModel = trainModel,
        _reclusterModel = reclusterModel,
        _predictDemand = predictDemand,
        _getHistory = getHistory;

  AnalysisStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DatasetSummary? get datasetSummary => _datasetSummary;
  PredictionResult? get predictionResult => _predictionResult;
  IngredientHistory? get history => _history;

  // Cargar Dataset (Vista General)
  Future<void> loadDataset() async {
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      _datasetSummary = await _getDataset();
      _status = AnalysisStatus.success;
    } catch (e) {
      _errorMessage = _mapFailureToMessage(e);
      _status = AnalysisStatus.error;
    }
    notifyListeners();
  }

  // Entrenar Modelo
  Future<void> train() async {
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      final msg = await _trainModel();
      _successMessage = "Modelo entrenado: $msg";
      // Recargar dataset actualizado
      _datasetSummary = await _getDataset();
      _status = AnalysisStatus.success;
    } catch (e) {
      _errorMessage = _mapFailureToMessage(e);
      _status = AnalysisStatus.error;
    }
    notifyListeners();
  }

  // Re-clusterizar
  Future<void> recluster() async {
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      final msg = await _reclusterModel();
      _successMessage = "Re-clusterización exitosa: $msg";
      _datasetSummary = await _getDataset();
      _status = AnalysisStatus.success;
    } catch (e) {
      _errorMessage = _mapFailureToMessage(e);
      _status = AnalysisStatus.error;
    }
    notifyListeners();
  }

  // Predecir
  Future<void> predict({
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

  // Obtener Historial para Gráfica
  Future<void> fetchHistory(String ingredientName) async {
    if (ingredientName.isEmpty) return;
    _status = AnalysisStatus.loading;
    notifyListeners();
    try {
      _history = await _getHistory(ingredientName);
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