import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fms_app/screens/home/transactions/add_transaction_screen.dart';
import 'package:fms_app/screens/home/transactions/edit_transaction.dart';
import 'package:fms_app/services/transaction_service.dart';
import 'package:fms_app/models/transaction.dart';
import 'package:fms_app/widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  final TransactionService transactionService = TransactionService();
  List<Transaction> transactions = [];
  bool isLoading = true;
  Timer? _refreshTimer;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _tabController = TabController(length: 3, vsync: this);

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchTransactions();
      }
    });
  }

  Future<void> _fetchTransactions() async {
    try {
      final fetchedTransactions = await transactionService.fetchTransactions();
      if (mounted) {
        setState(() {
          transactions = fetchedTransactions;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching transactions: $e');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();

    // Cancel the timer to prevent memory leaks
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المعاملات'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'معلق'),
            Tab(text: 'مكتمل'),
            Tab(text: 'ملغي'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList('معلق'),
          _buildTransactionList('مكتمل'),
          _buildTransactionList('ملغي'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddTransactionScreen and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );

          // If a new transaction was added, refresh the list
          if (result == true) {
            _fetchTransactions();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList(String status) {
    final filteredTransactions =
    transactions.where((t) => t.status == status).toList();

    if (filteredTransactions.isEmpty) {
      return const Center(child: Text('لاتوجد معاملات'));
    }

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return TransactionCard(
          transaction: transaction,
          onEdit: () {
            // Navigate to edit transaction screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTransactionScreen(transaction: transaction),
              ),
            ).then((result) {
              if (result == true) {
                _fetchTransactions();
              }
            });
          },
          onCancel: () async {
            try {
              await transactionService.cancelTransaction(transaction.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء المعاملة بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );

              // Refresh the transaction list after cancellation
              _fetchTransactions();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل في إلغاء المعاملة: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }

          },
          onConfirm: (amount) async {
            try {
              await transactionService.confirmTransaction(
                  transaction.id, amount);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تأكيد المعاملة بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
              _fetchTransactions();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل في تأكيد المعاملة: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }
}
