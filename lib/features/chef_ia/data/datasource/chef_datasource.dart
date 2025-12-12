import 'dart:convert';
import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class ChefDatasource {
  Future<String> askChef(int kitchenId, String question);
}

class ChefDatasourceImpl implements ChefDatasource {
  final http.Client client;
  final String? _apiUrl = dotenv.env['API_URL'];

  ChefDatasourceImpl({required this.client});

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

  @override
  Future<String> askChef(int kitchenId, String question) async {
    var baseUrl = _apiUrl;
    if (baseUrl == null) throw ServerException('API_URL no configurada.');
    if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);

    final url = Uri.parse('$baseUrl/chef/kitchens/$kitchenId/ask');

    debugPrint(' [CHEF IA] Preguntando: "$question" a Cocina ID: $kitchenId');

    try {
      final headers = await _getHeaders();
      final body = json.encode({'question': question});

      final response = await client.post(url, headers: headers, body: body);

      debugPrint(' [CHEF IA] Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data']['answer'] ?? 'No pude generar una respuesta.';
        } else {
          throw ServerException('La respuesta del Chef no tuvo el formato esperado.');
        }
      } else {
        if (response.statusCode == 403) {
          throw ServerException('No tienes permisos para consultar esta cocina.');
        }
        final error = json.decode(response.body);
        throw ServerException(error['message'] ?? 'Error al consultar al Chef IA.');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión con el Chef IA.');
    }
  }
}