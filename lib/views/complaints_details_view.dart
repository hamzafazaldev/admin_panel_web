import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_extended_service.dart';

class Complaint {
  final String id;
  final String title;
  final String description;
  final String status;
  final String date;
  final String residentName;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    required this.residentName,
  });

  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      date: data['date'] ?? '',
      residentName: data['residentName'] ?? '',
    );
  }
}

class ComplaintsDetailsView extends StatefulWidget {
  const ComplaintsDetailsView({Key? key}) : super(key: key);

  @override
  _ComplaintsDetailsViewState createState() => _ComplaintsDetailsViewState();
}

class _ComplaintsDetailsViewState extends State<ComplaintsDetailsView> {
  final FirestoreExtendedService _firestoreService = FirestoreExtendedService();
  List<Complaint> complaints = [];
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  String newTitle = '';
  String newDescription = '';
  String newStatus = '';
  String newDate = '';
  String newResidentName = '';

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() {
      isLoading = true;
    });
    try {
      _firestoreService.getComplaints().listen((snapshot) {
        setState(() {
          complaints = snapshot.docs.map((doc) => Complaint.fromFirestore(doc)).toList();
          isLoading = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addComplaint() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firestoreService.addComplaint({
          'title': newTitle,
          'description': newDescription,
          'status': newStatus,
          'date': newDate,
          'residentName': newResidentName,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint added successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add complaint: $e')),
        );
      }
    }
  }

  void _showAddComplaintDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Complaint'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                    onSaved: (value) => newTitle = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
                    onSaved: (value) => newDescription = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Status'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter status' : null,
                    onSaved: (value) => newStatus = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Date'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter date' : null,
                    onSaved: (value) => newDate = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Resident Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter resident name' : null,
                    onSaved: (value) => newResidentName = value ?? '',
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
              onPressed: _addComplaint,
              child: const Text('Add'),
            ),
          ],
        );
      });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'pending':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildComplaintCard(Complaint complaint) {
    Color statusColor = _getStatusColor(complaint.status);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              complaint.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(complaint.residentName),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(complaint.date),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.info, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  complaint.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddComplaintDialog,
            tooltip: 'Add Complaint',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      _showEditComplaintDialog(complaints[index]);
                    },
                    child: _buildComplaintCard(complaints[index]),
                  );
                },
              ),
            ),
    );
  }

  void _showEditComplaintDialog(Complaint complaint) {
    final _editFormKey = GlobalKey<FormState>();
    String editTitle = complaint.title;
    String editDescription = complaint.description;
    String editStatus = complaint.status;
    String editDate = complaint.date;
    String editResidentName = complaint.residentName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Complaint'),
          content: Form(
            key: _editFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: editTitle,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                    onSaved: (value) => editTitle = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editDescription,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
                    onSaved: (value) => editDescription = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter status' : null,
                    onSaved: (value) => editStatus = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editDate,
                    decoration: const InputDecoration(labelText: 'Date'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter date' : null,
                    onSaved: (value) => editDate = value ?? '',
                  ),
                  TextFormField(
                    initialValue: editResidentName,
                    decoration: const InputDecoration(labelText: 'Resident Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter resident name' : null,
                    onSaved: (value) => editResidentName = value ?? '',
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
                    await _firestoreService.updateComplaint(complaint.id, {
                      'title': editTitle,
                      'description': editDescription,
                      'status': editStatus,
                      'date': editDate,
                      'residentName': editResidentName,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Complaint updated successfully')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update complaint: $e')),
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
