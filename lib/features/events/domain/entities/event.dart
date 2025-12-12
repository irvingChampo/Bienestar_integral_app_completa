class Event {
  final int id;
  final int kitchenId;
  final String name;
  final String description;
  final String eventDate;
  final String startTime;
  final String endTime;
  final int maxCapacity;

  final String? eventType;
  final int? expectedDiners;
  final String? status;

  Event({
    required this.id,
    required this.kitchenId,
    required this.name,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    this.eventType,
    this.expectedDiners,
    this.status,
  });
}