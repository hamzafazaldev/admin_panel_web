import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UsersView extends StatelessWidget {
  UsersView({super.key});

  final List<UserModel> dummyUsers = [
    UserModel(id: '1', name: 'Hamza Ali', email: 'hamza@example.com', role: 'Admin'),
    UserModel(id: '2', name: 'Awais Fazal', email: 'awais@example.com', role: 'Resident'),
    UserModel(id: '3', name: 'Zain Raza', email: 'zain@example.com', role: 'Visitor'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyUsers.length,
      itemBuilder: (context, index) {
        final user = dummyUsers[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(user.name),
            subtitle: Text('${user.email} • ${user.role}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Open edit dialog
              },
            ),
          ),
        );
      },
    );
  }
}
