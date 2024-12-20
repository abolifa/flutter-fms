class Employee {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String team;
  final String major;
  final double quota;

  Employee({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.team,
    required this.major,
    required this.quota,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      team: json['team'],
      major: json['major'],
      quota: json['quota'].toDouble(),
    );
  }
}
