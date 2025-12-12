class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class InvalidCredentialsException extends ServerException {
  InvalidCredentialsException(super.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}