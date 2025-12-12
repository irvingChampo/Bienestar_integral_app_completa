import 'package:bienestar_integral_app/features/auth/domain/entities/user.dart';
import 'package:bienestar_integral_app/features/register/domain/entities/skill.dart';

class AvailabilitySlot {
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  AvailabilitySlot({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}

class UserProfile {
  final User user;
  final List<Skill> skills;
  final List<AvailabilitySlot> availability;

  UserProfile({
    required this.user,
    required this.skills,
    required this.availability,
  });
}