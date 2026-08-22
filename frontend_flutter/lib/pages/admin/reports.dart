import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generación de Reportes')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Exportar Reportes a PDF/CSV'),
          onPressed: () {},
        ),
      ),
    );
  }
}
