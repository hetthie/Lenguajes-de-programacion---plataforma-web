import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import 'detail_page.dart';

class MyComplaintsPage extends StatelessWidget {
  const MyComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final myItems =
        provider.complaints
            .where((c) => c.citizenEmail == provider.currentUser?.email)
            .toList();

    return myItems.isEmpty
        ? const Center(child: Text('No has realizado denuncias aún.'))
        : ListView.builder(
          itemCount: myItems.length,
          itemBuilder: (context, index) {
            final item = myItems[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.createdAt.toString().split(' ')[0]),
                trailing: StatusBadge(status: item.status),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(complaint: item),
                      ),
                    ),
              ),
            );
          },
        );
  }
}
