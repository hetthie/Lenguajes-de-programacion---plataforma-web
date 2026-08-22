import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import 'detail_admin.dart';

class ComplaintsAdminPage extends StatelessWidget {
  const ComplaintsAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<AppProvider>().complaints;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Denuncias')),
      body: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final item = complaints[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text('${item.citizenName} • ${item.category}'),
            trailing: StatusBadge(status: item.status),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailAdminPage(complaint: item),
                  ),
                ),
          );
        },
      ),
    );
  }
}
