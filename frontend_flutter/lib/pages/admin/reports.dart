import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

const Color kCardBorder = Color(0xFFE2E8F0);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _filtroEstado = 'todos';

  void _exportarCSV(BuildContext context) {
    final denuncias = context.read<AppProvider>().complaints;

    final filtradas = denuncias.where((d) {
      if (_filtroEstado == 'todos') return true;
      return d.status.toLowerCase().contains(_filtroEstado);
    }).toList();

    if (filtradas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay denuncias para exportar con el filtro seleccionado.')),
      );
      return;
    }

    final StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln('ID,Título,Categoría,Estado,Prioridad,Dirección,Ciudadano,Email,Fecha');

    for (var d in filtradas) {
      final fecha = '${d.createdAt.day}/${d.createdAt.month}/${d.createdAt.year}';
      final titulo = '"${d.title.replaceAll('"', '""')}"';
      final direccion = '"${d.address.replaceAll('"', '""')}"';
      final ciudadano = '"${d.citizenName.replaceAll('"', '""')}"';

      csvBuffer.writeln('${d.id},$titulo,${d.category},${d.status},${d.priority},$direccion,$ciudadano,${d.citizenEmail},$fecha');
    }

    final bytes = utf8.encode(csvBuffer.toString());
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    html.AnchorElement(href: url)
      ..setAttribute('download', 'reporte_denuncias_guayaquil_${DateTime.now().millisecondsSinceEpoch}.csv')
      ..click();

    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte descargado exitosamente en formato CSV.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final denuncias = context.watch<AppProvider>().complaints;

    return Scaffold(
      appBar: AppBar(title: const Text('Generación de Reportes')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kCardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EXPORTAR DATOS DE DENUNCIAS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kGreyText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Selecciona los criterios para generar un archivo descargable en CSV para auditoría o gestión municipal:',
                          style: TextStyle(fontSize: 13, color: kTitleText),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _filtroEstado,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por Estado',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'todos', child: Text('Todas las denuncias')),
                            DropdownMenuItem(value: 'pendiente', child: Text('Solo Pendientes')),
                            DropdownMenuItem(value: 'proceso', child: Text('Solo En Proceso')),
                            DropdownMenuItem(value: 'resuel', child: Text('Solo Resueltas')),
                          ],
                          onChanged: (val) => setState(() => _filtroEstado = val ?? 'todos'),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.download),
                            label: const Text('Descargar Reporte (CSV)', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _exportarCSV(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kCardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen de Registros Disponibles',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTitleText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Actualmente hay ${denuncias.length} denuncias registradas en la base de datos de Guayaquil listas para exportación.',
                          style: const TextStyle(fontSize: 13, color: kGreyText),
                        ),
                      ],
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
