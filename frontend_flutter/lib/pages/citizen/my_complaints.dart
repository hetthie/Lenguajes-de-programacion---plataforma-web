import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import 'detail_page.dart';

class MyComplaintsPage extends StatefulWidget {
  const MyComplaintsPage({super.key});

  @override
  State<MyComplaintsPage> createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends State<MyComplaintsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchMyComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.isLoadingMine && provider.myComplaints.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMine != null && provider.myComplaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMine!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.fetchMyComplaints(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final myItems = provider.myComplaints;

    return RefreshIndicator(
      onRefresh: () => provider.fetchMyComplaints(),
      child: myItems.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No has realizado denuncias aún.')),
              ],
            )
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
