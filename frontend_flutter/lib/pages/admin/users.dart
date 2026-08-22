import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AppProvider>().users;

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios Registrados')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(u.name),
            subtitle: Text(u.email),
            trailing: Chip(label: Text(u.role)),
          );
        },
      ),
    );
  }
}
