import 'package:flutter/material.dart';
import 'package:fms_app/models/car.dart';
import 'package:fms_app/models/employee.dart';
import 'package:fms_app/models/tank.dart';
import 'package:fms_app/models/transaction.dart';
import 'package:fms_app/services/tank_service.dart';
import 'package:fms_app/services/transaction_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({required this.transaction, Key? key}) : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService transactionService = TransactionService();
  final TankService tankService = TankService();

  String? status;
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
      // Fetch employees, cars, and tanks
      final fetchedEmployees = await transactionService.getEmployees();
      final fetchedCars = await transactionService.getCars();
      final fetchedTanks = await tankService.fetchTanks();

      setState(() {
        employees = fetchedEmployees;
        allCars = fetchedCars;
        tanks = fetchedTanks;

        // Pre-fill the form with existing transaction data
        status = widget.transaction.status;
        selectedEmployee = employees.firstWhere((e) => e.id == widget.transaction.employee.id);
        filteredCars = allCars.where((car) => car.employee_id == selectedEmployee?.id).toList();
        selectedCar = filteredCars.firstWhere((c) => c.id == widget.transaction.car.id);
        selectedTank = tanks.firstWhere((t) => t.id == widget.transaction.tankId);
        amount = widget.transaction.amount;

        isFormLoading = false;
      });
    } catch (e) {
      _showErrorMessage('Error initializing form: $e');
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      try {
        await transactionService.updateTransaction(widget.transaction.id, {
          'status': status,
          'employee_id': selectedEmployee?.id,
          'car_id': selectedCar?.id,
          'tank_id': selectedTank?.id,
          'amount': status == 'مكتمل' ? amount : null, // Include amount only if مكتمل
        });
        _showSuccessMessage('تم تعديل المعاملة بنجاح.');
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
      appBar: AppBar(title: const Text('تعديل المعاملة')),
      body: isFormLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                onChanged: (value) => setState(() => status = value),
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

              // Tank dropdown
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
                initialValue: amount?.toString(),
                enabled: status == 'مكتمل', // Disable if status is not مكتمل
              ),
              const SizedBox(height: 20),

              // Submit button
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text('تعديل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
