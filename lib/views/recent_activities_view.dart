import 'package:flutter/material.dart';

class RecentActivitiesView extends StatefulWidget {
  const RecentActivitiesView({Key? key}) : super(key: key);

  @override
  _RecentActivitiesViewState createState() => _RecentActivitiesViewState();
}

class _RecentActivitiesViewState extends State<RecentActivitiesView> {
  final TextEditingController activity1Controller = TextEditingController(text: 'John updated profile');
  final TextEditingController activity2Controller = TextEditingController(text: 'Payment of \$500 received');

  @override
  void dispose() {
    activity1Controller.dispose();
    activity2Controller.dispose();
    super.dispose();
  }

  void _saveDetails() {
    // Implement save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recent activities saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Activities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDetails,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: activity1Controller,
              decoration: const InputDecoration(labelText: 'Activity 1'),
            ),
            TextField(
              controller: activity2Controller,
              decoration: const InputDecoration(labelText: 'Activity 2'),
            ),
          ],
        ),
      ),
    );
  }
}
