import 'package:bienestar_integral_app/features/profile/domain/repository/profile_repository.dart';

class CreateAvailabilitySlot {
  final ProfileRepository repository;

  CreateAvailabilitySlot(this.repository);

  Future<void> call(Map<String, dynamic> slotData) async {
    await repository.createAvailabilitySlot(slotData);
  }
}

class UpdateAvailabilitySlot {
  final ProfileRepository repository;

  UpdateAvailabilitySlot(this.repository);

  Future<void> call(String dayOfWeek, Map<String, dynamic> slotData) async {
    await repository.updateAvailabilitySlot(dayOfWeek, slotData);
  }
}

class RemoveAvailabilitySlot {
  final ProfileRepository repository;

  RemoveAvailabilitySlot(this.repository);

  Future<void> call(String dayOfWeek) async {
    await repository.removeAvailabilitySlot(dayOfWeek);
  }
}