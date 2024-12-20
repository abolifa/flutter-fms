import 'package:flutter/material.dart';
import 'package:fms_app/models/transaction.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final Future<void> Function(int amount)? onConfirm;


  const TransactionCard({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onCancel,
    this.onConfirm,

  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (transaction.status == 'ملغي') {
          _showEditNotAllowedMessage(context);
        } else {
          if (onEdit != null) onEdit!(); // Trigger the edit callback
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Number and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.numbers, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      transaction.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(transaction.status),
                  ),
                ],
              ),
              const Divider(thickness: 1, height: 20),

              // Amount
              Row(
                children: [
                  const Icon(color: Colors.green, PhosphorIconsBold.numpad),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'الكمية:  ${transaction.amount?.toString() ?? 'لا توجد'}',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Employee and Car
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.employee.name,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.car.model,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cancel Button

                Row(
                  children: [
                    if (transaction.status != 'مكتمل')
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.center,
                          foregroundColor: Colors.green,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _showConfirmTransaction(context),
                        child: const Text('تأكيد'),
                      ),
                    ),

                    if (transaction.status != 'ملغي')
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.center,
                          foregroundColor: Colors.red,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _showCancelConfirmation(context),
                        child: const Text('إلغاء'),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNotAllowedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'لا يمكن تعديل معاملة ملغية.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد أنك تريد إلغاء هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (onCancel != null) onCancel!(); // Trigger cancel callback
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }


  void _showConfirmTransaction(BuildContext context) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد المعاملة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال الكمية لتأكيد المعاملة'),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              int? amount = int.tryParse(amountController.text);

              if (amount != null && onConfirm != null) {
                try {
                  await onConfirm!(amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تأكيد المعاملة بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في تأكيد المعاملة: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إدخال كمية صالحة'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }




  Color _getStatusColor(String status) {
    switch (status) {
      case 'معلق':
        return Colors.orange;
      case 'مكتمل':
        return Colors.green;
      case 'ملغي':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
