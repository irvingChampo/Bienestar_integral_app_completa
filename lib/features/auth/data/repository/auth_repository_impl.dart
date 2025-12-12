import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/auth/data/datasource/auth_datasource.dart';
import 'package:bienestar_integral_app/features/auth/domain/entities/auth_response.dart';
import 'package:bienestar_integral_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final authResponseModel = await datasource.login(email, password);
      return authResponseModel;
    } catch (e) {
      rethrow;
    }
  }
}