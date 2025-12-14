import 'dart:convert';
import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/dataset_summary_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/ingredient_history_model.dart';
import 'package:bienestar_integral_app/features/ingredient_analysis/data/models/prediction_result_model.dart';
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

  @override
  Future<String> trainModel(int kitchenId) async {
    final url = Uri.parse(_getUrl('/train'));
    try {
      final body = json.encode({'kitchen_id': kitchenId});
      final response = await client.post(url, headers: await _getHeaders(), body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] ?? 'Entrenado exitosamente';
      }
      throw ServerException('Error al entrenar modelo: ${response.statusCode}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión al entrenar');
    }
  }

  @override
  Future<PredictionResultModel> predict(Map<String, dynamic> data) async {
    final url = Uri.parse(_getUrl('/predict'));
    try {
      // El kitchen_id ya debe venir dentro del mapa 'data' desde el provider
      final response = await client.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return PredictionResultModel.fromJson(json.decode(response.body));
      }
      throw ServerException('Error en la predicción: ${response.statusCode}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión en predicción');
    }
  }

  @override
  Future<String> recluster(int kitchenId) async {
    final url = Uri.parse(_getUrl('/recluster?kitchen_id=$kitchenId'));
    try {
      final response = await client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] ?? 'Re-clusterizado exitosamente';
      }
      throw ServerException('Error al re-clusterizar');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión');
    }
  }

  @override
  Future<DatasetSummaryModel> getDataset(int kitchenId) async {
    final url = Uri.parse(_getUrl('/dataset?kitchen_id=$kitchenId'));
    try {
      final response = await client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return DatasetSummaryModel.fromJson(json.decode(response.body));
      }
      throw ServerException('Error al obtener dataset');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión');
    }
  }

  @override
  Future<IngredientHistoryModel> getHistory(int kitchenId, String ingrediente) async {
    final encodedName = Uri.encodeComponent(ingrediente);
    // Se agrega kitchen_id como query param para filtrar historial por cocina
    final url = Uri.parse(_getUrl('/evolucion/ingrediente/$encodedName?kitchen_id=$kitchenId'));
    try {
      final response = await client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return IngredientHistoryModel.fromJson(json.decode(response.body));
      }
      throw ServerException('Error al obtener historial');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión');
    }
  }
}