import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

const Color kCardBorder = Color(0xFFE2E8F0);
const Color kLabelColor = Color(0xFF64748B);
const Color kTotalColor = Color(0xFF2563EB);
const Color kPendienteColor = Color(0xFFD97706);
const Color kAtendidoColor = Color(0xFF10B981);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchComplaintSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final summary = provider.complaintSummary;

    return Scaffold(
      appBar: AppBar(title: const Text('Visión General')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (provider.isLoadingSummary) const LinearProgressIndicator(),
              if (provider.errorSummary != null) ...[
                const SizedBox(height: 12),
                Text(
                  provider.errorSummary!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              if (provider.isLoadingSummary || provider.errorSummary != null)
                const SizedBox(height: 12),
              MetricsRow(
                total: summary['total'] ?? 0,
                pendientes: summary['pendientes'] ?? 0,
                atendidos: summary['aprobadas'] ?? 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetricsRow extends StatelessWidget {
  final int total;
  final int pendientes;
  final int atendidos;

  const MetricsRow({
    super.key,
    required this.total,
    required this.pendientes,
    required this.atendidos,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        final cards = [
          _MetricCard(
            label: 'Total Denuncias',
            value: total,
            valueColor: kTotalColor,
          ),
          _MetricCard(
            label: 'Pendientes',
            value: pendientes,
            valueColor: kPendienteColor,
          ),
          _MetricCard(
            label: 'Atendidos',
            value: atendidos,
            valueColor: kAtendidoColor,
          ),
        ];

        if (isNarrow) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards.map((c) => SizedBox(width: 150, child: c)).toList(),
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
            const SizedBox(width: 16),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final Color valueColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kLabelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
