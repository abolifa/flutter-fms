class Car {
  final int id;
  final int employee_id;
  final String model;
  final String plate;
  final bool isEAA;

  Car({
    required this.id,
    required this.employee_id,
    required this.model,
    required this.plate,
    required this.isEAA,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      employee_id: json['employee_id'],
      model: json['model'],
      plate: json['plate'],
      isEAA: json['is_eaa'] == 1, // Convert integer to boolean
    );
  }
}
