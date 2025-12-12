class User {
  final int id;
  final String email;
  final String names;

  final String? firstLastName;
  final String? secondLastName;
  final String? phoneNumber;

  final String status;
  final bool verifiedEmail;
  final bool verifiedPhone;

  final String? fullName;

  User({
    required this.id,
    required this.email,
    required this.names,
    this.firstLastName,
    this.secondLastName,
    this.phoneNumber,
    required this.status,
    required this.verifiedEmail,
    required this.verifiedPhone,
    this.fullName,
  });

  String get calculatedFullName => '$names ${firstLastName ?? ''} ${secondLastName ?? ''}'.trim();
}