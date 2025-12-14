import 'dart:async';
import 'dart:convert';
import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/dataset_summary_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/ingredient_history_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/prediction_result_model.dart';
import 'package:flutter/foundation.dart'; // Importante para debugPrint
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class IngredientAnalysisDatasource {
  Future<String> trainModel(int kitchenId);
  Future<PredictionResultModel> predict(Map<String, dynamic> data);
  Future<String> recluster(int kitchenId);
  Future<DatasetSummaryModel> getDataset(int kitchenId);
  Future<IngredientHistoryModel> getHistory(int kitchenId, String ingrediente);
}

class IngredientAnalysisDatasourceImpl implements IngredientAnalysisDatasource {
  final http.Client client;
  final String? _clusterApiUrl = dotenv.env['CLUSTER_API_URL'];

  IngredientAnalysisDatasourceImpl({required this.client});

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw ServerException('Token de autenticación no encontrado.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
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
    final url = Uri.parse(_getUrl('/predict'));

    // --- LOGS DRÁSTICOS ---
    final bodyJson = json.encode(data);
    debugPrint('=============================================');
    debugPrint('🚀 [PREDICT] INICIANDO PETICIÓN');
    debugPrint('📍 URL: $url');
    debugPrint('📦 BODY (RAW JSON): $bodyJson');
    debugPrint('🧐 DATOS ENVIADOS (MAPA): $data');
    debugPrint('=============================================');

    try {
      final response = await client.post(
        url,
        headers: await _getHeaders(),
        body: bodyJson,
      ).timeout(const Duration(seconds: 60));

      debugPrint('📥 [PREDICT] RESPUESTA RECIBIDA');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return PredictionResultModel.fromJson(json.decode(response.body));
      }

      // Si llegamos aquí, el servidor respondió algo distinto a 200
      throw ServerException('Error del servidor (${response.statusCode}): ${response.body}');

    } catch (e) {
      debugPrint('❌ [PREDICT] ERROR CAPTURADO: $e');
      if (e is TimeoutException) throw NetworkException('El servidor tardó mucho en responder.');
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión en predicción: $e');
    }
  }

  @override
  Future<IngredientHistoryModel> getHistory(int kitchenId, String ingrediente) async {
    final encodedName = Uri.encodeComponent(ingrediente);
    final url = Uri.parse(_getUrl('/evolucion/ingrediente/$encodedName?kitchen_id=$kitchenId'));

    debugPrint('🚀 [HISTORY] URL: $url');

    try {
      final response = await client.get(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return IngredientHistoryModel.fromJson(json.decode(response.body));
      }
      throw ServerException('Error al obtener historial (${response.statusCode})');
    } catch (e) {
      if (e is TimeoutException) throw NetworkException('Tiempo de espera agotado.');
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión');
    }
  }

  // --- MÉTODOS INACTIVOS ---
  @override
  Future<String> trainModel(int kitchenId) async => "Deshabilitado";
  @override
  Future<String> recluster(int kitchenId) async => "Deshabilitado";
  @override
  Future<DatasetSummaryModel> getDataset(int kitchenId) async => DatasetSummaryModel(nItems: 0, sample: []);
}