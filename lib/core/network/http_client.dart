import 'package:http/http.dart' as http;

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();

  late final http.Client client;

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal() {
    client = http.Client();
  }

  void dispose() {
    client.close();
  }
}