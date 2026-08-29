import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/user.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';

const Color kScreenBg = Color(0xFFF8FAFC);
const Color kOuterBorder = Color(0xFFE2E8F0);
const Color kRowDivider = Color(0xFFF1F5F9);
const Color kDarkText = Color(0xFF1E293B);
const Color kGreyText = Color(0xFF64748B);

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
              : LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth =
                      constraints.maxWidth > 600 ? 600.0 : double.infinity;

                  return RefreshIndicator(
                    onRefresh: _loadUsers,
                    child:
                        users.isEmpty
                            ? const Center(
                              child: Text('No hay usuarios registrados.'),
                            )
                            : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: maxWidth,
                                  ),
                                  child: UsuariosRegistradosCard(
                                    usuarios: users,
                                  ),
                                ),
                              ),
                            ),
                  );
                },
              ),
    );
  }
}

class UsuariosRegistradosCard extends StatelessWidget {
  final List<User> usuarios;

  const UsuariosRegistradosCard({super.key, required this.usuarios});

  @override
  Widget build(BuildContext context) {
    if (usuarios.isEmpty) {
      return const _EmptyState();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOuterBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        // Construcción dinámica: una fila por cada usuario de la lista,
        // con línea divisoria salvo en el último elemento (como en el HTML).
        children: List.generate(usuarios.length, (index) {
          final usuario = usuarios[index];
          final isLast = index == usuarios.length - 1;
          return _UsuarioRow(usuario: usuario, showDivider: !isLast);
        }),
      ),
    );
  }
}

class _UsuarioRow extends StatelessWidget {
  final User usuario;
  final bool showDivider;

  const _UsuarioRow({required this.usuario, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    bool isMunicipal = usuario.role == 'municipal';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border:
            showDivider
                ? const Border(bottom: BorderSide(color: kRowDivider, width: 1))
                : null,
      ),
      child: Row(
        children: [
          // Avatar circular con inicial
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMunicipal ? Color(0xFFEFF6FF) : Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              usuario.name[0],
              style: TextStyle(
                color: isMunicipal ? Color(0xFF2563EB) : Color(0xFF475569),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nombre + correo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kDarkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  usuario.email,
                  style: const TextStyle(fontSize: 12, color: kGreyText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isMunicipal ? Color(0xFFFEF3C7) : Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isMunicipal ? 'Municipal' : 'Ciudadano',
              style: TextStyle(
                color: isMunicipal ? Color(0xFFB45309) : Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 44, color: kGreyText),
          SizedBox(height: 12),
          Text(
            'No hay usuarios registrados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kGreyText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
