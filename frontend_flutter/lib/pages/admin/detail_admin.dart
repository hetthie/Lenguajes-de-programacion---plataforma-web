import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/app_provider.dart';

class DetailAdminPage extends StatelessWidget {
  final Complaint complaint;
  const DetailAdminPage({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestionar ${complaint.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Reportado por: ${complaint.citizenName} (${complaint.citizenEmail})',
            ),
            const SizedBox(height: 16),
            const Text(
              'Actualizar Estado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children:
                  [
                    'Pendiente',
                    'En revisión',
                    'En proceso',
                    'Atendido',
                    'Rechazado',
                  ].map((st) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            complaint.status == st ? Colors.indigo : null,
                      ),
                      onPressed: () {
                        context.read<AppProvider>().updateComplaintStatus(
                          complaint.id,
                          st,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(st),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
