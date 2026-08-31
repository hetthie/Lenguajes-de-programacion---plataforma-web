import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/municipal_report.dart';
import '../../providers/app_provider.dart';
import '../../services/report_service.dart';

const Color kCardBorder = Color(0xFFE2E8F0);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);
const Color kPrimaryBlue = Color(0xFF2563EB);

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  MunicipalReport? _report;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AppProvider>().token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'La sesión ha expirado.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final report = await ReportService(
        token,
      ).fetchReport(const ReportFilters());
      if (!mounted) return;
      setState(() => _report = report);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final denuncias = provider.complaints;

    final total = denuncias.length;
    final resueltas =
        denuncias
            .where(
              (d) =>
                  d.status.toLowerCase().contains('resuel') ||
                  d.status.toLowerCase().contains('atend'),
            )
            .length;
    final enProceso =
        denuncias.where((d) => d.status.toLowerCase().contains('proc')).length;
    final pendientes = total - resueltas - enProceso;

    final porcentajeResolucion =
        total > 0 ? ((resueltas / total) * 100).toStringAsFixed(1) : '0.0';

    final Map<String, int> categoriaCounts = {};
    for (var d in denuncias) {
      final cat = d.category.isEmpty ? 'General' : d.category;
      categoriaCounts[cat] = (categoriaCounts[cat] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas y Analítica')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kCardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TASA DE RESOLUCIÓN MUNICIPAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kGreyText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '$porcentajeResolucion%',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '$resueltas de $total denuncias atendidas exitosamente',
                                style: const TextStyle(
                                  color: kGreyText,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: total > 0 ? (resueltas / total) : 0,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Distribución por Estado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTitleText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _StatBadgeCard(
                        label: 'Pendientes',
                        count: pendientes,
                        color: const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 12),
                      _StatBadgeCard(
                        label: 'En Proceso',
                        count: enProceso,
                        color: const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 12),
                      _StatBadgeCard(
                        label: 'Resueltas',
                        count: resueltas,
                        color: const Color(0xFF16A34A),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Reportes por Categoría de Infraestructura',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTitleText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (categoriaCounts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No hay suficientes datos para generar estadísticas.',
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kCardBorder),
                      ),
                      child: Column(
                        children:
                            categoriaCounts.entries.map((entry) {
                              final pct =
                                  total > 0 ? (entry.value / total) : 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: kTitleText,
                                          ),
                                        ),
                                        Text(
                                          '${entry.value} (${(pct * 100).toStringAsFixed(0)}%)',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: kGreyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 8,
                                        backgroundColor: const Color(
                                          0xFFF1F5F9,
                                        ),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              kPrimaryBlue,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBadgeCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadgeCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kGreyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
