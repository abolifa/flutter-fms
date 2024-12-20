import 'dart:convert';
import 'dart:math';
import 'package:fms_app/helpers/api_service.dart';
import 'package:fms_app/helpers/params.dart';
import 'package:fms_app/models/car.dart';
import 'package:fms_app/models/employee.dart';
import '../models/transaction.dart';

class TransactionService {
  final ApiService apiService = ApiService(baseUrl: Constant.transactions);

  Future<List<Transaction>> fetchTransactions() async {
    final response = await apiService.get('/');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['data'] as List<dynamic>;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  // Generate a random 5-digit transaction number
  String generateTransactionNumber() {
    final random = Random();
    return List.generate(5, (_) => random.nextInt(10)).join();
  }

  Future<List<Employee>> getEmployees() async {
    final response = await apiService.get('/employees');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((employee) => Employee.fromJson(employee))
          .toList();
    } else {
      throw Exception('Failed to fetch employees');
    }
  }

  Future<List<Car>> getCars() async {
    final response = await apiService.get('/cars');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((car) => Car.fromJson(car))
          .toList();
    } else {
      throw Exception('Failed to fetch cars');
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    final response = await apiService.post('/', transactionData);
    if (response.statusCode != 201) {
      print(response.body);
      throw Exception('Failed to add transaction');
    }
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> transactionData) async {
    final response = await apiService.put('/$id', transactionData);
    if (response.statusCode != 200) {
      print(response.body);
      throw Exception('Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await apiService.delete('/$id');
    if (response.statusCode != 200) {
      print(response.body);
      throw Exception('Failed to delete transaction');
    }
  }

  Future<void> cancelTransaction(int transactionId) async {
    final response = await apiService.put('/$transactionId', {
      'status': 'ملغي',
      'amount': 0,
    });
    if (response.statusCode != 200) {
      print(response.body);
      throw Exception('Failed to cancel transaction');
    }
  }

  Future<void> confirmTransaction(int transactionId, int amount) async {
    final response = await apiService.put('/$transactionId', {
      'status': 'مكتمل',
      'amount': amount,
    });
    if (response.statusCode != 200) {
      print(response.body);
      throw Exception('Failed to confirm transaction');
    }
  }
}
