import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

const Color kAvatarBg = Color(0xFFE2E8F0);
const Color kAvatarText = Color(0xFF3B82F6);
const Color kDarkText = Color(0xFF1E293B);
const Color kGreyText = Color(0xFF64748B);
const Color kCardBorder = Color(0xFFF1F5F9);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kFailureGreen = Color(0xFFB91010);
const Color kDangerBg = Color(0xFFFEF2F2);
const Color kDangerText = Color(0xFFEF4444);
const Color kDangerBorder = Color(0xFFFCA5A5);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;

    final String userInitial = user?.name[0] ?? 'U';
    final String userName = user?.name ?? 'Usuario';
    final String userEmail = user?.email ?? '';
    final String userRole = user?.role ?? 'Ciudadano';
    final String accountStatus = user?.status ?? 'Inactivo';

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 480 ? 480.0 : double.infinity;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(
                      initial: userInitial,
                      name: userName,
                      email: userEmail,
                    ),
                    const SizedBox(height: 32),

                    _InfoCard(role: userRole, status: accountStatus),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<AppProvider>().logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: kDangerBg,
                          foregroundColor: kDangerText,
                          side: const BorderSide(color: kDangerBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String initial;
  final String name;
  final String email;

  const _ProfileHeader({
    required this.initial,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reemplaza este Container por:
        // CircleAvatar(radius: 48, backgroundImage: NetworkImage('...'))
        // si el usuario tiene foto de perfil.
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: kAvatarBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: kAvatarText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: kDarkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(fontSize: 14, color: kGreyText)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String role;
  final String status;

  const _InfoCard({required this.role, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Rol',
            value: role,
            valueColor: kDarkText,
            showDivider: true,
          ),
          _InfoRow(
            label: 'Estado de cuenta',
            value: status,
            valueColor: status == 'Inactivo' ? kFailureGreen : kSuccessGreen,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration:
          showDivider
              ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kCardBorder, width: 1),
                ),
              )
              : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kGreyText, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
