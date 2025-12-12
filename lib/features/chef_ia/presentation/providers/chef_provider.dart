import 'package:bienestar_integral_app/core/error/exception.dart';
import 'package:bienestar_integral_app/features/chef_ia/domain/usecase/ask_chef.dart';
import 'package:flutter/material.dart';

enum ChefStatus { idle, loading, success, error }

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChefProvider extends ChangeNotifier {
  final AskChef _askChef;

  ChefStatus _status = ChefStatus.idle;
  String? _errorMessage;

  final List<ChatMessage> _messages = [];

  ChefProvider(this._askChef) {
    _messages.add(ChatMessage(
      text: "¡Hola! Soy tu Chef IA. 🧑‍🍳\nPregúntame qué podemos cocinar con el inventario actual.",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  ChefStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<ChatMessage> get messages => _messages;

  Future<void> sendMessage(String question, int kitchenId) async {
    if (question.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: question,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _status = ChefStatus.loading;
    notifyListeners();

    try {
      final answer = await _askChef(kitchenId, question);

      _messages.add(ChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _status = ChefStatus.success;

    } on ServerException catch (e) {
      _errorMessage = e.message;
      _status = ChefStatus.error;
      _addSystemMessage("Error: ${e.message}");
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _status = ChefStatus.error;
      _addSystemMessage("Error de conexión: Verifica tu internet.");
    } catch (e) {
      _errorMessage = "Ocurrió un error inesperado.";
      _status = ChefStatus.error;
      _addSystemMessage("Error inesperado al consultar al Chef.");
    } finally {
      notifyListeners();
    }
  }

  void _addSystemMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      text: "¡Hola! Soy tu Chef IA. 🧑‍🍳\nPregúntame qué podemos cocinar con el inventario actual.",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}