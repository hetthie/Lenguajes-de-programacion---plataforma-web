import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas y Analítica')),
      body: const Center(
        child: Text('Panel de Métrica por Categorías y Tiempos de Solución'),
      ),
    );
  }
}
