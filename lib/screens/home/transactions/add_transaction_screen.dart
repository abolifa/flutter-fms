import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fms_app/models/tank.dart';
import 'package:fms_app/services/tank_service.dart';
import 'package:fms_app/services/transaction_service.dart';
import 'package:fms_app/models/employee.dart';
import 'package:fms_app/models/car.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService transactionService = TransactionService();
  final TankService tankService = TankService();

  late String generatedNumber; // For auto-generated transaction number
  String? status = 'معلق';
  Employee? selectedEmployee;
  Car? selectedCar;
  Tank? selectedTank;
  double? amount;

  List<Employee> employees = [];
  List<Car> allCars = [];
  List<Car> filteredCars = [];
  List<Tank> tanks = [];

  bool isLoading = false;
  bool isFormLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    try {
      // Generate random transaction number locally
      generatedNumber = _generateTransactionNumber();

      // Fetch employees, cars, and tanks
      final fetchedEmployees = await transactionService.getEmployees();
      final fetchedCars = await transactionService.getCars();
      final fetchedTanks = await tankService.fetchTanks();

      setState(() {
        employees = fetchedEmployees;
        allCars = fetchedCars;
        filteredCars = []; // Initially empty as no employee is selected
        tanks = fetchedTanks;
        isFormLoading = false;
      });
    } catch (e) {
      _showErrorMessage('Error initializing form: $e');
    }
  }

  String _generateTransactionNumber() {
    final random = Random();
    return List.generate(5, (_) => random.nextInt(10)).join();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if the employee's quota is less than the amount
      if (status == 'مكتمل' && selectedEmployee != null && amount != null) {
        if (selectedEmployee!.quota < amount!) {
          final proceed = await _showQuotaWarning();
          if (!proceed) return; // Abort submission if the user selects "No"
        }
      }

      setState(() {
        isLoading = true;
      });

      try {
        await transactionService.addTransaction({
          'number': generatedNumber,
          'status': status,
          'employee_id': selectedEmployee?.id,
          'car_id': selectedCar?.id,
          'tank_id': selectedTank?.id,
          'amount': status == 'مكتمل' ? amount : null, // Include amount only if مكتمل
        });
        _showSuccessMessage('تم إظافة المعاملة بنجاح.');
        Navigator.pop(context, true); // Return to the previous screen
      } catch (e) {
        _showErrorMessage('حدث خطأ ما: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _filterCars() {
    setState(() {
      filteredCars = allCars.where((car) => car.employee_id == selectedEmployee?.id).toList();
      selectedCar = null; // Reset the selected car when filtering
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<bool> _showQuotaWarning() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحذير'),
        content: const Text(
          'الموظف قد تجاوز الحد الشهري المسموح به. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // User selects "No"
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // User selects "Yes"
            child: const Text('نعم'),
          ),
        ],
      ),
    ) ??
        false; // Return false if the dialog is dismissed without selection
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة معاملة')),
      body: isFormLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Auto-generated number display
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'رقم المعاملة',
                  border: OutlineInputBorder(),
                ),
                initialValue: generatedNumber,
                enabled: false,
              ),
              const SizedBox(height: 10),

              // Status dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(),
                ),
                value: status,
                items: const [
                  DropdownMenuItem(value: 'معلق', child: Text('معلق')),
                  DropdownMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Employee dropdown
              DropdownButtonFormField<Employee>(
                decoration: const InputDecoration(
                  labelText: 'الموظف',
                  border: OutlineInputBorder(),
                ),
                value: selectedEmployee,
                items: employees.map((employee) {
                  return DropdownMenuItem(
                    value: employee,
                    child: Text(employee.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value;
                  });
                  _filterCars();
                },
                validator: (value) => value == null ? 'يرجى اختيار الموظف' : null,
              ),
              const SizedBox(height: 10),

              // Car dropdown
              DropdownButtonFormField<Car>(
                decoration: const InputDecoration(
                  labelText: 'السيارة',
                  border: OutlineInputBorder(),
                ),
                value: selectedCar,
                items: filteredCars.map((car) {
                  return DropdownMenuItem(
                    value: car,
                    child: Text('${car.model} - ${car.plate}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCar = value),
                validator: (value) => value == null ? 'يرجى اختيار السيارة' : null,
              ),
              const SizedBox(height: 10),

              // Tank
              DropdownButtonFormField<Tank>(
                decoration: const InputDecoration(
                  labelText: 'الخزان',
                  border: OutlineInputBorder(),
                ),
                value: selectedTank,
                items: tanks.map((tank) {
                  return DropdownMenuItem(
                    value: tank,
                    child: Text('${tank.name} - ${tank.fuelType}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedTank = value),
                validator: (value) => value == null ? 'يرجى اختيار الخزان' : null,
              ),
              const SizedBox(height: 10),

              // Amount field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'الكمية',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => amount = value != null && value.isNotEmpty ? double.tryParse(value) : null,
                enabled: status == 'مكتمل', // Disable if status is not مكتمل
              ),
              const SizedBox(height: 20),

              // Submit button
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
