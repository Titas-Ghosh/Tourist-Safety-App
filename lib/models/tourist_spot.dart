class TouristSpot {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;

  TouristSpot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory TouristSpot.fromFirestore(String id, Map<String, dynamic> data) {
    return TouristSpot(
      id: id,
      name: data['name'] ?? "Unknown",
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      description: data['description'] ?? "",
    );
  }
}
