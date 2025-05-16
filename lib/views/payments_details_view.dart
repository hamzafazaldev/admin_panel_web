import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_extended_service.dart';

class PaymentsDetailsView extends StatefulWidget {
  const PaymentsDetailsView({Key? key}) : super(key: key);

  @override
  _PaymentsDetailsViewState createState() => _PaymentsDetailsViewState();
}

class _PaymentsDetailsViewState extends State<PaymentsDetailsView> {
  final FirestoreExtendedService _firestoreService = FirestoreExtendedService();
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  String newDescription = '';
  String newDate = '';
  double newAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      isLoading = true;
    });
    try {
      _firestoreService.getPayments().listen((snapshot) {
        setState(() {
          transactions = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          isLoading = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firestoreService.addPayment({
          'description': newDescription,
          'date': newDate,
          'amount': newAmount,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add transaction: $e')),
        );
      }
    }
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Transaction'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
                    onSaved: (value) => newDescription = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Date'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter date' : null,
                    onSaved: (value) => newDate = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter amount';
                      if (double.tryParse(value) == null) return 'Enter valid number';
                      return null;
                    },
                    onSaved: (value) => newAmount = double.parse(value ?? '0'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  double get totalIncome => transactions
      .where((t) => (t['amount'] ?? 0) > 0)
      .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));

  double get totalExpense => transactions
      .where((t) => (t['amount'] ?? 0) < 0)
      .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransactionDialog,
            tooltip: 'Add Transaction',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Income',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${totalIncome.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Expense',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${totalExpense.abs().toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final amount = transaction['amount'] ?? 0;
                      return ListTile(
                        onTap: () {
                          _showEditTransactionDialog(transaction, index);
                        },
                        leading: Icon(
                            amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                            color: amount >= 0 ? Colors.green : Colors.red),
                        title: Text(transaction['description'] ?? ''),
                        subtitle: Text(transaction['date'] ?? ''),
                        trailing: Text('\$${amount.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showEditTransactionDialog(Map<String, dynamic> transaction, int index) {
    final _editFormKey = GlobalKey<FormState>();
    String editDescription = transaction['description'] ?? '';
    String editDate = transaction['date'] ?? '';
    double editAmount = (transaction['amount'] ?? 0).toDouble();
    String docId = transaction['id'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: Form(
            key: _editFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: editDescription,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
                    onSaved: (value) => editDescription = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editDate,
                    decoration: const InputDecoration(labelText: 'Date'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter date' : null,
                    onSaved: (value) => editDate = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editAmount.toString(),
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter amount';
                      if (double.tryParse(value) == null) return 'Enter valid number';
                      return null;
                    },
                    onSaved: (value) => editAmount = double.parse(value ?? '0'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_editFormKey.currentState!.validate()) {
                  _editFormKey.currentState!.save();
                  try {
                    if (docId.isNotEmpty) {
                      await _firestoreService.updatePayment(docId, {
                        'description': editDescription,
                        'date': editDate,
                        'amount': editAmount,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction updated successfully')),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update transaction: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
