import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/complaint.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import 'detail_admin.dart';

const Color kScreenBg = Color(0xFFF8FAFC);
const Color kCardBorder = Color(0xFFE2E8F0);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);

const Color kEnProcesoBg = Color(0xFFE0F2FE);
const Color kEnProcesoText = Color(0xFF0284C7);
const Color kResueltaBg = Color(0xFFDCFCE7);
const Color kResueltaText = Color(0xFF15803D);
const Color kPendienteBg = Color(0xFFFEF3C7);
const Color kPendienteText = Color(0xFFD97706);

class ComplaintsAdminPage extends StatelessWidget {
  const ComplaintsAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<AppProvider>().complaints;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Gestión de Denuncias',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 600 ? 600.0 : double.infinity;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxWidth),
                child: DenunciasGestionList(denuncias: complaints),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DenunciasGestionList extends StatelessWidget {
  final List<Complaint> denuncias;
  final ValueChanged<Complaint>? onItemTap;

  const DenunciasGestionList({
    super.key,
    required this.denuncias,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (denuncias.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: denuncias.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final denuncia = denuncias[index];
        return _DenunciaGestionItem(
          denuncia: denuncia,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailAdminPage(complaint: denuncia),
                ),
              ),
        );
      },
    );
  }
}

class _DenunciaGestionItem extends StatelessWidget {
  final Complaint denuncia;
  final VoidCallback? onTap;

  const _DenunciaGestionItem({required this.denuncia, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kCardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      denuncia.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTitleText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${denuncia.citizenName} • ${denuncia.category}',
                      style: const TextStyle(fontSize: 13, color: kGreyText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _EstadoBadge(estado: denuncia.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;

    String status = '';

    switch (estado.toLowerCase()) {
      case 'en_proceso':
        bg = kEnProcesoBg;
        fg = kEnProcesoText;
        status = 'En proceso';
        break;
      case 'resuelta':
        bg = kResueltaBg;
        fg = kResueltaText;
        status = 'Resuelto';
        break;
      case 'pendiente':
      default:
        bg = kPendienteBg;
        fg = kPendienteText;
        status = 'Pendiente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
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
          Icon(Icons.inbox_outlined, size: 44, color: kGreyText),
          SizedBox(height: 12),
          Text(
            'No hay denuncias para gestionar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kGreyText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
