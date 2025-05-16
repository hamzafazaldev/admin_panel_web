import 'package:admin_panel_web/views/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'views/settings_view.dart';
import 'views/residents_details_view.dart';
import 'views/complaints_details_view.dart';
import 'views/payments_details_view.dart';
import 'views/recent_activities_view.dart';
import 'views/upcoming_events_view.dart';
import 'views/properties_view.dart';
import 'views/announcements_view.dart';
import 'widgets/sidebar.dart';
import 'widgets/topbar.dart';

// rest of the file content unchanged




class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const AdminDashboard(),
      routes: {
        '/residentsDetails': (context) => const ResidentsDetailsView(),
        '/complaintsDetails': (context) => const ComplaintsDetailsView(),
        '/paymentsDetails': (context) => const PaymentsDetailsView(),
        '/recentActivities': (context) => const RecentActivitiesView(),
        '/upcomingEvents': (context) => const UpcomingEventsView(),
        '/announcements': (context) => const AnnouncementsView(),
      },
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<Widget> views = [
    const DashboardView(),
    // Placeholder for AnnouncementsView
    const AnnouncementsView(),
    const UpcomingEventsView(),
    const ComplaintsDetailsView(),
    const ResidentsDetailsView(),
    // Placeholder for FinancesView
    const FinancesView(),
    const SettingsView(),
    const PropertiesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() => selectedIndex = index);
            },
          ),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(child: views[selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Removed duplicate AnnouncementsView class declaration

class FinancesView extends StatelessWidget {
  const FinancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentsDetailsView();
  }
}
