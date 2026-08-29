import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<AppProvider>().complaints;

    return Scaffold(
      appBar: AppBar(title: const Text('Visión General')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _card('Total', '${complaints.length}', Colors.blue),
                _card(
                  'Pendientes',
                  '${complaints.where((c) => c.status == 'Pendiente').length}',
                  Colors.orange,
                ),
                _card(
                  'Atendidos',
                  '${complaints.where((c) => c.status == 'Atendido').length}',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String label, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
