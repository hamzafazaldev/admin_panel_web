import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Resident {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String propertyAddress;
  final String role;
  final String propertyType;
  final double size;
  final double value;
  final DateTime? lastPaymentDate;
  final String paymentMethod;
  final double totalPayments;
  final double remainingPayments;

  Resident({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.propertyAddress,
    required this.role,
    required this.propertyType,
    required this.size,
    required this.value,
    required this.lastPaymentDate,
    required this.paymentMethod,
    required this.totalPayments,
    required this.remainingPayments,
  });

  factory Resident.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Resident(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      propertyAddress: data['propertyAddress'] ?? '',
      role: data['role'] ?? '',
      propertyType: data['propertyType'] ?? '',
      size: (data['size'] ?? 0).toDouble(),
      value: (data['value'] ?? 0).toDouble(),
      lastPaymentDate: data['lastPaymentDate'] != null
          ? (data['lastPaymentDate'] as Timestamp).toDate()
          : null,
      paymentMethod: data['paymentMethod'] ?? '',
      totalPayments: (data['totalPayments'] ?? 0).toDouble(),
      remainingPayments: (data['remainingPayments'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'propertyAddress': propertyAddress,
      'role': role,
      'propertyType': propertyType,
      'size': size,
      'value': value,
      'lastPaymentDate': lastPaymentDate,
      'paymentMethod': paymentMethod,
      'totalPayments': totalPayments,
      'remainingPayments': remainingPayments,
    };
  }
}

class ResidentsDetailsView extends StatefulWidget {
  const ResidentsDetailsView({Key? key}) : super(key: key);

  @override
  _ResidentsDetailsViewState createState() => _ResidentsDetailsViewState();
}

class _ResidentsDetailsViewState extends State<ResidentsDetailsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Resident> residents = [];
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  String newName = '';
  String newEmail = '';
  String newPhone = '';
  String newPropertyAddress = '';
  String newRole = '';
  String newPropertyType = '';
  double newSize = 0;
  double newValue = 0;
  String newLastPaymentDate = '';
  String newPaymentMethod = '';
  double newTotalPayments = 0;
  double newRemainingPayments = 0;

  @override
  void initState() {
    super.initState();
    _fetchResidents();
  }

  Future<void> _fetchResidents() async {
    setState(() {
      isLoading = true;
    });
    try {
      _firestore.collection('users').snapshots().listen((snapshot) {
        setState(() {
          residents = snapshot.docs
              .map((doc) => Resident.fromFirestore(doc))
              .toList();
          isLoading = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load residents: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addResident() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      DateTime? parsedLastPaymentDate;
      if (newLastPaymentDate.isNotEmpty) {
        try {
          parsedLastPaymentDate = DateTime.parse(newLastPaymentDate);
        } catch (_) {
          parsedLastPaymentDate = null;
        }
      }
      try {
        await _firestore.collection('users').add({
          'name': newName,
          'email': newEmail,
          'phone': newPhone,
          'propertyAddress': newPropertyAddress,
          'role': newRole,
          'propertyType': newPropertyType,
          'size': newSize,
          'value': newValue,
          'lastPaymentDate': parsedLastPaymentDate,
          'paymentMethod': newPaymentMethod,
          'totalPayments': newTotalPayments,
          'remainingPayments': newRemainingPayments,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resident added successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add resident: $e')),
        );
      }
    }
  }

  void _showAddResidentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Resident'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
                    onSaved: (value) => newName = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter email' : null,
                    onSaved: (value) => newEmail = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter phone' : null,
                    onSaved: (value) => newPhone = value ?? '',
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Property Address'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter property address'
                        : null,
                    onSaved: (value) => newPropertyAddress = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Role'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter role' : null,
                    onSaved: (value) => newRole = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Property Type'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter property type' : null,
                    onSaved: (value) => newPropertyType = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Size (sq ft)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) => newSize = double.tryParse(value ?? '0') ?? 0,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Value'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) => newValue = double.tryParse(value ?? '0') ?? 0,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Last Payment Date (YYYY-MM-DD)'),
                    onSaved: (value) => newLastPaymentDate = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Payment Method'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter payment method' : null,
                    onSaved: (value) => newPaymentMethod = value ?? '',
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Total Payments'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) =>
                        newTotalPayments = double.tryParse(value ?? '0') ?? 0,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Remaining Payments'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) =>
                        newRemainingPayments = double.tryParse(value ?? '0') ?? 0,
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
              onPressed: _addResident,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResidentCard(Resident resident) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => _showEditResidentDialog(resident),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resident.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _infoRow(Icons.home_work, 'Type: ${resident.propertyType}'),
              _infoRow(Icons.square_foot, 'Size: ${resident.size} sq ft'),
              _infoRow(Icons.attach_money, 'Value: \$${resident.value}'),
              _infoRow(Icons.calendar_today,
                  'Last Payment: ${resident.lastPaymentDate != null ? resident.lastPaymentDate!.toLocal().toString().split(" ")[0] : "N/A"}'),
              _infoRow(Icons.payment, 'Payment Method: ${resident.paymentMethod}'),
              const SizedBox(height: 8),
              _infoRow(Icons.email, resident.email),
              _infoRow(Icons.phone, resident.phone),
              _infoRow(Icons.home, resident.propertyAddress),
              _infoRow(Icons.badge, resident.role),
              const SizedBox(height: 8),
              _infoRow(Icons.attach_money, 'Total: \$${resident.totalPayments}'),
              _infoRow(Icons.money_off, 'Remaining: \$${resident.remainingPayments}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }

  void _showEditResidentDialog(Resident resident) {
    final _editFormKey = GlobalKey<FormState>();
    String editName = resident.name;
    String editEmail = resident.email;
    String editPhone = resident.phone;
    String editPropertyAddress = resident.propertyAddress;
    String editRole = resident.role;
    String editPropertyType = resident.propertyType;
    double editSize = resident.size;
    double editValue = resident.value;
    String editLastPaymentDate = resident.lastPaymentDate != null
        ? resident.lastPaymentDate!.toLocal().toString().split(" ")[0]
        : '';
    String editPaymentMethod = resident.paymentMethod;
    double editTotalPayments = resident.totalPayments;
    double editRemainingPayments = resident.remainingPayments;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Resident'),
          content: Form(
            key: _editFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: editName,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
                    onSaved: (value) => editName = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editEmail,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter email' : null,
                    onSaved: (value) => editEmail = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editPhone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter phone' : null,
                    onSaved: (value) => editPhone = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editPropertyAddress,
                    decoration:
                        const InputDecoration(labelText: 'Property Address'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter property address'
                        : null,
                    onSaved: (value) => editPropertyAddress = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter role' : null,
                    onSaved: (value) => editRole = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editPropertyType,
                    decoration: const InputDecoration(labelText: 'Property Type'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter property type' : null,
                    onSaved: (value) => editPropertyType = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editSize.toString(),
                    decoration: const InputDecoration(labelText: 'Size (sq ft)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) => editSize = double.tryParse(value ?? '0') ?? 0,
                  ),
                  TextFormField(
                    initialValue: editValue.toString(),
                    decoration: const InputDecoration(labelText: 'Value'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) => editValue = double.tryParse(value ?? '0') ?? 0,
                  ),
                  TextFormField(
                    initialValue: editLastPaymentDate,
                    decoration: const InputDecoration(labelText: 'Last Payment Date (YYYY-MM-DD)'),
                    onSaved: (value) => editLastPaymentDate = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editPaymentMethod,
                    decoration: const InputDecoration(labelText: 'Payment Method'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter payment method' : null,
                    onSaved: (value) => editPaymentMethod = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editTotalPayments.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Total Payments'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) => editTotalPayments =
                        double.tryParse(value ?? '0') ?? 0,
                  ),
                  TextFormField(
                    initialValue: editRemainingPayments.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Remaining Payments'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) => editRemainingPayments =
                        double.tryParse(value ?? '0') ?? 0,
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
                  DateTime? parsedLastPaymentDate;
                  if (editLastPaymentDate.isNotEmpty) {
                    try {
                      parsedLastPaymentDate = DateTime.parse(editLastPaymentDate);
                    } catch (_) {
                      parsedLastPaymentDate = null;
                    }
                  }
                  try {
                    await _firestore
                        .collection('users')
                        .doc(resident.id)
                        .update({
                      'name': editName,
                      'email': editEmail,
                      'phone': editPhone,
                      'propertyAddress': editPropertyAddress,
                      'role': editRole,
                      'propertyType': editPropertyType,
                      'size': editSize,
                      'value': editValue,
                      'lastPaymentDate': parsedLastPaymentDate,
                      'paymentMethod': editPaymentMethod,
                      'totalPayments': editTotalPayments,
                      'remainingPayments': editRemainingPayments,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resident updated')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Residents Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddResidentDialog,
            tooltip: 'Add Resident',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: residents.length,
              itemBuilder: (context, index) =>
                  _buildResidentCard(residents[index]),
            ),
    );
  }
}
