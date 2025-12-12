class Kitchen {
  final int id;
  final String name;
  final String description;
  final int stateId;
  final int municipalityId;
  final String imageUrl;

  Kitchen({
    required this.id,
    required this.name,
    required this.description,
    required this.stateId,
    required this.municipalityId,
    required this.imageUrl,
  });

  Map<String, String> toDisplayData() {
    return {
      'title': name,
      'location': description,
      'image': imageUrl,
      'description': description,
    };
  }
}