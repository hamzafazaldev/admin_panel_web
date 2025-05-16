import 'package:flutter/material.dart';

class UpcomingEventsView extends StatefulWidget {
  const UpcomingEventsView({Key? key}) : super(key: key);

  @override
  _UpcomingEventsViewState createState() => _UpcomingEventsViewState();
}

class _UpcomingEventsViewState extends State<UpcomingEventsView> {
  final TextEditingController event1Controller = TextEditingController(text: 'Community Meeting - 12 May');
  final TextEditingController event2Controller = TextEditingController(text: 'Annual Maintenance - 20 May');

  @override
  void dispose() {
    event1Controller.dispose();
    event2Controller.dispose();
    super.dispose();
  }

  void _saveDetails() {
    // Implement save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upcoming events saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
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
              controller: event1Controller,
              decoration: const InputDecoration(labelText: 'Event 1'),
            ),
            TextField(
              controller: event2Controller,
              decoration: const InputDecoration(labelText: 'Event 2'),
            ),
          ],
        ),
      ),
    );
  }
}
