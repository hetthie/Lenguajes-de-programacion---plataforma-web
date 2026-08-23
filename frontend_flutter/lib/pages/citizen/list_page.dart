import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import 'detail_page.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final complaints = provider.complaints;

    if (provider.isLoading && complaints.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && complaints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AppProvider>().fetchComplaints(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (complaints.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<AppProvider>().fetchComplaints(),
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(child: Text('No hay denuncias registradas actualmente.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppProvider>().fetchComplaints(),
      child: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final item = complaints[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${item.category} • ${item.address}'),
              trailing: StatusBadge(status: item.status),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(complaint: item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
