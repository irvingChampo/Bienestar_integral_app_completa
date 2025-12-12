import 'package:bienestar_integral_app/features/auth/data/models/user_model.dart';
import 'package:bienestar_integral_app/features/profile/domain/entities/user_profile.dart';
import 'package:bienestar_integral_app/features/register/data/models/skill_model.dart';

class AvailabilitySlotModel extends AvailabilitySlot {
  AvailabilitySlotModel({
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
  });

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotModel(
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.user,
    required super.skills,
    required super.availability,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {

    var userSkills = (json['skills'] as List)
        .map((skillJson) => SkillModel(id: skillJson['skillId'], name: ''))
        .toList();

    return UserProfileModel(
      user: UserModel.fromJson(json['user']),
      skills: userSkills,
      availability: (json['availability'] as List)
          .map((slotJson) => AvailabilitySlotModel.fromJson(slotJson))
          .toList(),
    );
  }
}