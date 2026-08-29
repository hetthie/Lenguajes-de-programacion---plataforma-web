import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/app_provider.dart';

const Color kScreenBg = Color(0xFFF8FAFC);
const Color kCardBorder = Color(0xFFF1F5F9);
const Color kDarkText = Color(0xFF1E293B);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);
const Color kBodyStrong = Color(0xFF334155);
const Color kSegmentBg = Color(0xFFF1F5F9);
const Color kPrimaryBlue = Color(0xFF2563EB);

enum EstadoGestion { pendiente, enProceso, atendido }

class DetailAdminPage extends StatefulWidget {
  final Complaint complaint;
  const DetailAdminPage({super.key, required this.complaint});

  @override
  State<DetailAdminPage> createState() => _DetailAdminPageState();
}

class _DetailAdminPageState extends State<DetailAdminPage> {
  bool _isSaving = false;

  Complaint get complaint => widget.complaint;

  static const _backendStatus = {
    'Pendiente': 'pendiente',
    'En proceso': 'en_proceso',
    'Atendido': 'resuelta',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestionar Denuncia #${complaint.id}')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 600 ? 600.0 : double.infinity;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: kTitleText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: kGreyText,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: kGreyText,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Reportado por: '),
                                    TextSpan(
                                      text:
                                          '${complaint.citizenName} (${complaint.citizenEmail})',
                                      style: const TextStyle(
                                        color: kBodyStrong,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(
                          color: kCardBorder,
                          thickness: 1,
                          height: 1,
                        ),
                        const SizedBox(height: 20),

                        // Selector de actualizar estado
                        const Text(
                          'ACTUALIZAR ESTADO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isSaving) ...[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          const Text('Guardando cambio de estado...'),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              [
                                'Pendiente',
                                'En revisión',
                                'En proceso',
                                'Atendido',
                                'Rechazado',
                              ].where(_backendStatus.containsKey).map((st) {
                                final backendStatus = _backendStatus[st]!;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        _isSaving
                                            ? null
                                            : () async {
                                              setState(() => _isSaving = true);
                                              final error = await context
                                                  .read<AppProvider>()
                                                  .updateComplaintStatus(
                                                    complaint.id,
                                                    backendStatus,
                                                  );
                                              if (!context.mounted) return;

                                              setState(() => _isSaving = false);
                                              if (error != null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(error),
                                                  ),
                                                );
                                                return;
                                              }
                                              Navigator.pop(context);
                                            },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            complaint.status == backendStatus
                                                ? kPrimaryBlue
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow:
                                            complaint.status == backendStatus
                                                ? [
                                                  BoxShadow(
                                                    color: kPrimaryBlue
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                      child: Text(
                                        st,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              complaint.status == backendStatus
                                                  ? Colors.white
                                                  : kGreyText,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
