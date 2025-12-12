import 'package:bienestar_integral_app/core/error/exception.dart';
// Imports de Entidades
import 'package:bienestar_integral_app/features/events/domain/entities/event_registration.dart';
import 'package:bienestar_integral_app/features/home/domain/entities/kitchen_subscription.dart';
// Imports de UseCases
import 'package:bienestar_integral_app/features/events/domain/usecase/get_my_event_registrations.dart';
import 'package:bienestar_integral_app/features/events/domain/usecase/unregister_from_event.dart';
import 'package:bienestar_integral_app/features/home/domain/usecase/get_my_kitchen_subscriptions.dart';
import 'package:flutter/material.dart';

enum MyEventsStatus { initial, loading, success, error }

class MyEventsProvider extends ChangeNotifier {
  final GetMyKitchenSubscriptions _getMyKitchenSubscriptions;
  final GetMyEventRegistrations _getMyEventRegistrations;
  final UnregisterFromEvent _unregisterFromEvent;

  MyEventsStatus _status = MyEventsStatus.initial;
  String? _errorMessage;

  List<KitchenSubscription> _subscriptions = [];
  List<EventRegistration> _registrations = [];

  int? _processingRegistrationId;

  MyEventsProvider({
    required GetMyKitchenSubscriptions getMyKitchenSubscriptions,
    required GetMyEventRegistrations getMyEventRegistrations,
    required UnregisterFromEvent unregisterFromEvent,
  })  : _getMyKitchenSubscriptions = getMyKitchenSubscriptions,
        _getMyEventRegistrations = getMyEventRegistrations,
        _unregisterFromEvent = unregisterFromEvent;

  MyEventsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<KitchenSubscription> get subscriptions => _subscriptions;
  List<EventRegistration> get registrations => _registrations;
  int? get processingRegistrationId => _processingRegistrationId;

  Future<void> fetchMySubscriptions() async {
    _status = MyEventsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscriptions = await _getMyKitchenSubscriptions();
      _status = MyEventsStatus.success;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      _status = MyEventsStatus.error;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _status = MyEventsStatus.error;
    } catch (e) {
      _errorMessage = 'Error al cargar suscripciones.';
      _status = MyEventsStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchMyRegistrations() async {
    _status = MyEventsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _registrations = await _getMyEventRegistrations();
      _status = MyEventsStatus.success;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      _status = MyEventsStatus.error;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _status = MyEventsStatus.error;
    } catch (e) {
      _errorMessage = 'Error al cargar eventos.';
      _status = MyEventsStatus.error;
    }
    notifyListeners();
  }

  Future<bool> cancelEventRegistration(int eventId) async {
    _processingRegistrationId = eventId;
    notifyListeners();

    try {
      await _unregisterFromEvent(eventId);
      _registrations.removeWhere((reg) => reg.eventId == eventId);
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error al cancelar asistencia.';
    } finally {
      _processingRegistrationId = null;
      notifyListeners();
    }
    return false;
  }
}