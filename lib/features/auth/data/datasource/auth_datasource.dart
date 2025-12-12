import 'dart:convert';
import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/core/network/http_client.dart';
import 'package:bienestar_integral_app/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class AuthDatasource {
  Future<AuthResponseModel> login(String email, String password);
}

class AuthDatasourceImpl implements AuthDatasource {
  final http.Client client;
  final String? _apiUrl = dotenv.env['API_URL'];

  AuthDatasourceImpl({http.Client? client})
      : client = client ?? HttpClient().client;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    if (_apiUrl == null) {
      throw ServerException('API_URL no encontrada en .env');
    }

    final url = Uri.parse('$_apiUrl/auth/login');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return AuthResponseModel.fromJson(jsonResponse['data']);
      } else {
        if (response.statusCode == 401) {
          throw InvalidCredentialsException('Correo o contraseña incorrectos.');
        } else {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          final errorMessage = errorResponse['message'] ?? 'Error desconocido del servidor';
          throw ServerException(errorMessage);
        }
      }
    } on InvalidCredentialsException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw NetworkException('No se pudo conectar al servidor. Revisa tu conexión a internet.');
    }
  }
}