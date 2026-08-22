import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../../components/ui.dart';

class DetailPage extends StatelessWidget {
  final Complaint complaint;
  const DetailPage({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(complaint.id)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: complaint.status),
                PriorityBadge(priority: complaint.priority),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              complaint.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(complaint.address, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(complaint.description),
            const Divider(height: 32),
            const Text(
              'Historial de Estados',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...complaint.history.map(
              (h) => ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.indigo,
                ),
                title: Text(h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
