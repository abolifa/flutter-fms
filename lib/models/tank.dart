class Tank {
  final int id;
  final String name;
  final double capacity;
  final double level;
  final String? fuelType;

  Tank({
    required this.id,
    required this.name,
    required this.capacity,
    required this.level,
    this.fuelType,
  });

  factory Tank.fromJson(Map<String, dynamic> json) {
    return Tank(
      id: json['id'],
      name: json['name'],
      capacity: (json['capacity'] as num).toDouble(),
      level: (json['level'] as num).toDouble(),
      fuelType: json['fuel']?['type'],
    );
  }
}
