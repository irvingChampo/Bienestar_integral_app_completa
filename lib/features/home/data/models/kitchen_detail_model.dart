import 'package:bienestar_integral_app/features/home/data/models/location_model.dart';
import 'package:bienestar_integral_app/features/home/domain/entities/kitchen_detail.dart';
import 'package:flutter/foundation.dart';

class ScheduleModel extends Schedule {
  ScheduleModel({required super.day, required super.startTime, required super.endTime});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }
}

class KitchenDetailModel extends KitchenDetail {
  KitchenDetailModel({
    required super.id,
    required super.name,
    required super.description,
    required super.isActive,
    super.contactPhone,
    super.contactEmail,
    required super.location,
    required super.isSubscribed,
    required super.schedules,
    required super.ownerName,
  });

  factory KitchenDetailModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> kitchenData = {};

    if (json['kitchen'] != null && json['kitchen'] is Map) {
      kitchenData = json['kitchen'];
    } else {
      kitchenData = json;
    }

    final locationData = kitchenData['location'] is Map<String, dynamic>
        ? kitchenData['location']
        : <String, dynamic>{};

    List<dynamic> rawSchedules = [];

    if (kitchenData['schedules'] != null && kitchenData['schedules'] is List) {
      rawSchedules = kitchenData['schedules'];
    } else if (kitchenData['schedule'] != null && kitchenData['schedule'] is List) {
      rawSchedules = kitchenData['schedule'];
    } else if (json['schedules'] != null && json['schedules'] is List) {
      rawSchedules = json['schedules'];
    }


    var schedulesList = rawSchedules.map((i) => ScheduleModel.fromJson(i)).toList();

    String parsedOwnerName = 'Administrador';
    if (kitchenData['responsible'] != null && kitchenData['responsible'] is Map) {
      final resp = kitchenData['responsible'];
      final names = resp['names'] ?? '';
      final lastName = resp['firstLastName'] ?? '';
      parsedOwnerName = '$names $lastName'.trim();
    }

    return KitchenDetailModel(
      id: kitchenData['id'] ?? 0,
      name: kitchenData['name'] ?? 'Nombre no disponible',
      description: kitchenData['description'] ?? 'Sin descripción disponible.',
      isActive: kitchenData['isActive'] ?? false,
      contactPhone: kitchenData['contactPhone'],
      contactEmail: kitchenData['contactEmail'],
      location: LocationModel.fromJson(locationData),
      isSubscribed: json['isSubscribed'] ?? false,
      schedules: schedulesList,
      ownerName: parsedOwnerName,
    );
  }
}