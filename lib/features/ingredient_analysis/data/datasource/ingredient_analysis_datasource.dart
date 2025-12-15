import 'dart:async';
import 'dart:convert';
import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/dataset_summary_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/ingredient_history_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/ingredient_list_model.dart'; // IMPORT NUEVO
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/prediction_result_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class IngredientAnalysisDatasource {
  Future<String> trainModel(int kitchenId);
  Future<PredictionResultModel> predict(Map<String, dynamic> data);
  Future<String> recluster(int kitchenId);
  Future<DatasetSummaryModel> getDataset(int kitchenId);
  Future<IngredientHistoryModel> getHistory(int kitchenId, String ingrediente);
  // NUEVO METODO
  Future<List<IngredientItemModel>> getIngredients();
}

class IngredientAnalysisDatasourceImpl implements IngredientAnalysisDatasource {
  final http.Client client;
  final String? _clusterApiUrl = dotenv.env['CLUSTER_API_URL'];

  IngredientAnalysisDatasourceImpl({required this.client});

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  String _getUrl(String endpoint) {
    if (_clusterApiUrl == null) throw ServerException('CLUSTER_API_URL no configurada.');
    var base = _clusterApiUrl!;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base$endpoint';
  }

  // --- MÉTODOS ACTIVOS ---

  @override
  Future<PredictionResultModel> predict(Map<String, dynamic> data) async {
    return _predictInternal(data, retry: true);
  }

  Future<PredictionResultModel> _predictInternal(Map<String, dynamic> data, {required bool retry}) async {
    final url = Uri.parse(_getUrl('/predict'));
    final bodyJson = json.encode(data);

    debugPrint('🚀 [PREDICT] Enviando a: $url');

    try {
      final response = await client.post(
        url,
        headers: await _getHeaders(),
        body: bodyJson,
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return PredictionResultModel.fromJson(json.decode(response.body));
      }

      if (response.statusCode == 400 && retry) {
        final bodyString = response.body.toLowerCase();
        if (bodyString.contains("pipeline no entrenado") || bodyString.contains("not fitted")) {
          debugPrint('⚠️ [AUTO-FIX] El servidor reporta modelo no entrenado. Intentando entrenar automáticamente...');
          await trainModel(0);
          debugPrint('🔄 [AUTO-FIX] Entrenamiento completado. Reintentando predicción...');
          return _predictInternal(data, retry: false);
        }
      }

      String errorMessage = 'Error del servidor (${response.statusCode})';
      try {
        final errorJson = json.decode(response.body);
        if (errorJson is Map && errorJson.containsKey('detail')) {
          errorMessage = errorJson['detail'].toString();
        }
      } catch (_) {}

      throw ServerException(errorMessage);

    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<String> trainModel(int kitchenId) async {
    final url = Uri.parse(_getUrl('/train'));

    try {
      final response = await client.post(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        return "Entrenado";
      }
      throw ServerException("Fallo al auto-entrenar: ${response.body}");
    } catch (e) {
      throw NetworkException("Error de conexión durante el entrenamiento");
    }
  }

  @override
  Future<IngredientHistoryModel> getHistory(int kitchenId, String ingrediente) async {
    final encodedName = Uri.encodeComponent(ingrediente);
    final url = Uri.parse(_getUrl('/evolucion/ingrediente/$encodedName'));

    try {
      final response = await client.get(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return IngredientHistoryModel.fromJson(json.decode(response.body));
      }
      throw ServerException('Error historial (${response.statusCode})');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión');
    }
  }

  // --- NUEVA IMPLEMENTACIÓN: OBTENER INGREDIENTES ---
  @override
  Future<List<IngredientItemModel>> getIngredients() async {
    final url = Uri.parse(_getUrl('/ingredientes'));
    debugPrint('🚀 [GET] Obteniendo ingredientes: $url');

    try {
      final response = await client.get(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => IngredientItemModel.fromJson(e)).toList();
        }
        return [];
      }

      throw ServerException('Error al cargar ingredientes (${response.statusCode})');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión al obtener ingredientes');
    }
  }

  // --- MÉTODOS INACTIVOS ---
  @override
  Future<String> recluster(int kitchenId) async => "Deshabilitado";
  @override
  Future<DatasetSummaryModel> getDataset(int kitchenId) async => DatasetSummaryModel(nItems: 0, sample: []);
}