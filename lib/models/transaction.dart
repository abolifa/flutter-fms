import 'package:fms_app/models/car.dart';
import 'package:fms_app/models/employee.dart';

class Transaction {
  final int id;
  final String number;
  final int tankId;
  final Car car; // Non-nullable Car object
  final Employee employee; // Non-nullable Employee object
  final double? amount;
  final String status;
  final String? approvedBy;

  Transaction({
    required this.id,
    required this.number,
    required this.tankId,
    required this.car,
    required this.employee,
    this.amount,
    required this.status,
    this.approvedBy,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      number: json['number'],
      tankId: json['tank_id'],
      car: Car.fromJson(json['car']),
      employee: Employee.fromJson(json['employee']),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      status: json['status'],
      approvedBy: json['approved_by'],
    );
  }
}
