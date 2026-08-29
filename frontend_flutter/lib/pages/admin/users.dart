import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final token = context.read<AppProvider>().token;

    if (token == null) {
      setState(() {
        _error = 'La sesión ha expirado. Inicia sesión nuevamente.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await AuthService().getUsers(token);
      if (!mounted) return;
      context.read<AppProvider>().setUsers(users);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AppProvider>().users;

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios Registrados')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadUsers,
                child:
                    users.isEmpty
                        ? const Center(
                          child: Text('No hay usuarios registrados.'),
                        )
                        : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                              trailing: Chip(
                                label: Text(
                                  user.role == 'admin'
                                      ? 'Municipal'
                                      : 'Ciudadano',
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
