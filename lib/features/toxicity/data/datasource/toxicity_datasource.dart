import 'dart:convert';
import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/toxicity/data/models/toxicity_response_model.dart';
import 'package:http/http.dart' as http;

abstract class ToxicityDatasource {
  Future<ToxicityResponseModel> predict(String text);
}

class ToxicityDatasourceImpl implements ToxicityDatasource {
  final http.Client client;
  final String _apiUrl = "https://api-toxicidad.bim2.xyz/predict";

  ToxicityDatasourceImpl({required this.client});

  @override
  Future<ToxicityResponseModel> predict(String text) async {
    try {
      print('--- [TOXICITY] INICIANDO PETICIÓN ---');
      print('URL: $_apiUrl');
      print('Texto a evaluar: $text');

      final response = await client.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"texto": text}),
      );

      print('--- [TOXICITY] RESPUESTA RECIBIDA ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      // CASO 1: Texto limpio (La API suele devolver 200 si todo está bien)
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ToxicityResponseModel.fromJson(jsonResponse);
      }

      // CASO 2: Texto TÓXICO (La API devuelve 403 cuando bloquea el contenido)
      else if (response.statusCode == 403) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes)); // utf8 para acentos

        // Creamos manualmente la respuesta indicando que NO está permitido
        return ToxicityResponseModel(
          permitido: false,
          probOfensivo: 1.0, // Asumimos 100% ofensivo si la API lo bloqueó
          mensaje: jsonResponse['detail'] ?? 'Lenguaje inapropiado detectado.',
        );
      }

      // CASO 3: Error real del servidor (500, 404, etc.)
      else {
        print('--- [TOXICITY] ERROR DEL SERVIDOR ---');
        throw ServerException('Error del servidor: ${response.statusCode}');
      }

    } catch (e) {
      print('--- [TOXICITY] EXCEPCIÓN DETECTADA ---');
      print('Mensaje de error: $e');

      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión al validar el texto.');
    }
  }
}