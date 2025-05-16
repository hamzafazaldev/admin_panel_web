import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int totalResidents = 0;
  int activeResidents = 0;
  int pendingApprovals = 0;

  int totalComplaints = 0;
  int resolvedComplaints = 0;
  int pendingComplaints = 0;

  double totalReceivedPayments = 0.0;
  double pendingPayments = 0.0;

  List<Map<String, String>> recentActivities = [];
  List<Map<String, String>> upcomingEvents = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenDashboardData();
  }

  void _listenDashboardData() async {
    setState(() {
      isLoading = true;
    });

    // Listen to users collection
    _firestore.collection('users').snapshots().listen((snapshot) {
      final docs = snapshot.docs;
      int total = docs.length;
      int active = docs.where((doc) => doc.data().containsKey('status') && doc['status'] == 'active').length;
int pending = docs.where((doc) => doc.data().containsKey('status') && doc['status'] == 'pending').length;


      setState(() {
        totalResidents = total;
        activeResidents = active;
        pendingApprovals = pending;
      });
    });

    // Listen to complaints collection
    _firestore.collection('complaints').snapshots().listen((complaintsSnapshot) {
      setState(() {
        totalComplaints = complaintsSnapshot.size;
        resolvedComplaints = (totalComplaints * 2 / 3).round(); // For demo
        pendingComplaints = totalComplaints - resolvedComplaints;
      });
    });

    // Listen to payments summary document
    _firestore.collection('payments').doc('summary').snapshots().listen((paymentsDoc) {
      if (paymentsDoc.exists) {
        Map<String, dynamic> data = paymentsDoc.data() as Map<String, dynamic>;
        setState(() {
          totalReceivedPayments = data['totalReceived']?.toDouble() ?? 0;
          pendingPayments = data['pendingPayments']?.toDouble() ?? 0;
        });
      }
    });

    // Listen to recent activities
    _firestore.collection('activities').orderBy('timestamp', descending: true).limit(5).snapshots().listen((activitiesSnapshot) {
      setState(() {
        recentActivities = activitiesSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'description': data['description']?.toString() ?? '',
            'details': data['details']?.toString() ?? '',
          };
        }).toList();
      });
    });

    // Listen to upcoming events
    _firestore.collection('events').orderBy('date').limit(5).snapshots().listen((eventsSnapshot) {
      setState(() {
        upcomingEvents = eventsSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'title': data['title']?.toString() ?? '',
            'date': data['date']?.toString() ?? '',
          };
        }).toList();
      });
    });

    setState(() {
      isLoading = false;
    });
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      );

  Widget _statItem(String label, String value, IconData icon, Color color) => Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )
        ],
      );

  Widget _barChart() => SizedBox(
        height: 150,
        child: BarChart(
          BarChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(show: false),
            barGroups: [
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: Colors.indigo)]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 7, color: Colors.indigo)]),
              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3, color: Colors.indigo)]),
              BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6, color: Colors.indigo)]),
            ],
          ),
        ),
      );

  Widget _buildSection(String title, List<Widget> content, {Widget? chart}) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          ...content,
          if (chart != null) ...[
            const SizedBox(height: 15),
            chart,
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 60) / 3;
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              SizedBox(
                width: width,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/residentsDetails');
                  },
                  child: _buildSection('Residents Details', [
                    _statItem('Total Residents', totalResidents.toString(), Icons.group, Colors.indigo),
                    _statItem('Active Residents', activeResidents.toString(), Icons.verified, Colors.green),
                    _statItem('Pending Approvals', pendingApprovals.toString(), Icons.hourglass_top, Colors.orange),
                  ], chart: _barChart()),
                ),
              ),
              SizedBox(
                width: width,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/complaintsDetails');
                  },
                  child: _buildSection('Complaints Overview', [
                    _statItem('Total Complaints', totalComplaints.toString(), Icons.report, Colors.red),
                    _statItem('Resolved', resolvedComplaints.toString(), Icons.check_circle, Colors.green),
                    _statItem('Pending', pendingComplaints.toString(), Icons.warning, Colors.amber),
                  ], chart: _barChart()),
                ),
              ),
              SizedBox(
                width: width,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/paymentsDetails');
                  },
                  child: _buildSection('Payments Summary', [
                    _statItem('Total Received', '\Rs.${totalReceivedPayments.toStringAsFixed(2)}', Icons.money, Colors.green),
                    _statItem('Pending Payments', '\Rs.${pendingPayments.toStringAsFixed(2)}', Icons.pending, Colors.orange),
                  ], chart: _barChart()),
                ),
              ),
              SizedBox(
                width: width,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/recentActivities');
                  },
                  child: _buildSection('Recent Activities', recentActivities.map((activity) {
                    return _statItem(activity['description'] ?? '', activity['details'] ?? '', Icons.edit, Colors.indigo);
                  }).toList()),
                ),
              ),
              SizedBox(
                width: width,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/upcomingEvents');
                  },
                  child: _buildSection('Upcoming Events', upcomingEvents.map((event) {
                    return _statItem(event['title'] ?? '', event['date'] ?? '', Icons.event, Colors.blueAccent);
                  }).toList()),
                ),
              ),
              SizedBox(
                width: width,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/announcements');
                  },
                  child: _buildSection('Announcements', [
                    const Icon(Icons.announcement, size: 40, color: Colors.deepPurple),
                    const SizedBox(height: 10),
                    const Text('View and add announcements', style: TextStyle(fontSize: 16)),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
