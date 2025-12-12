class Location {
  final int id;
  final String streetAddress;
  final String neighborhood;
  final int stateId;
  final int municipalityId;
  final String postalCode;
  Location({
    required this.id,
    required this.streetAddress,
    required this.neighborhood,
    required this.stateId,
    required this.municipalityId,
    required this.postalCode,
  });
}