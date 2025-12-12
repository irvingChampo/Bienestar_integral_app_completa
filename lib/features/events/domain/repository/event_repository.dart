import 'package:bienestar_integral_app/features/events/domain/entities/event.dart';
import 'package:bienestar_integral_app/features/events/domain/entities/event_participant.dart';
import 'package:bienestar_integral_app/features/events/domain/entities/event_registration.dart';

abstract class EventRepository {
  Future<List<Event>> getEventsByKitchen(int kitchenId);
  Future<void> registerToEvent(int eventId);
  Future<List<EventRegistration>> getMyRegistrations();
  Future<void> unregisterFromEvent(int eventId);

  Future<void> createEvent(Map<String, dynamic> eventData);
  Future<void> updateEvent(int eventId, Map<String, dynamic> eventData);
  Future<void> deleteEvent(int eventId);
  Future<List<EventParticipant>> getEventParticipants(int eventId);
  Future<List<EventParticipant>> getKitchenSubscribers(int kitchenId);
}