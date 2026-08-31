import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import '../../utils/status_utils.dart';
import 'detail_admin.dart';

const Color kCardBorder = Color(0xFFE2E8F0);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);
const Color kPrimaryBlue = Color(0xFF2563EB);

class ComplaintsAdminPage extends StatefulWidget {
  const ComplaintsAdminPage({super.key});

  @override
  State<ComplaintsAdminPage> createState() => _ComplaintsAdminPageState();
}

class _ComplaintsAdminPageState extends State<ComplaintsAdminPage> {
  // 'todos' o un valor canónico: pendiente | en_proceso | resuelta
  String _selectedFilter = 'todos';

  static const List<MapEntry<String, String>> _filterOptions = [
    MapEntry('todos', 'Todos'),
    MapEntry('pendiente', 'Pendiente'),
    MapEntry('en_proceso', 'En proceso'),
    MapEntry('resuelta', 'Resuelta'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final denuncias = provider.complaints;

    final filteredList = denuncias.where((d) {
      if (_selectedFilter == 'todos') return true;
      return normalizeStatus(d.status) == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Denuncias', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().fetchComplaints(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtro rápido de estado
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: _filterOptions.map((opt) {
                      final isSelected = _selectedFilter == opt.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(opt.value),
                          selected: isSelected,
                          selectedColor: kPrimaryBlue.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? kPrimaryBlue : kTitleText,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = opt.key);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Lista de denuncias
                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay denuncias en esta categoría.',
                            style: TextStyle(color: kGreyText, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final denuncia = filteredList[index];
                            final fotoUrl = denuncia.fotoUrl;
                            final hasFoto = fotoUrl != null && fotoUrl.trim().isNotEmpty;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: kCardBorder),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailAdminPage(denuncia: denuncia),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hasFoto) ...[
                                      Container(
                                        height: 180,
                                        width: double.infinity,
                                        color: const Color(0xFFF1F5F9),
                                        child: Image.network(
                                          fotoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: const Color(0xFFF1F5F9),
                                            child: const Center(
                                              child: Icon(Icons.broken_image, size: 40, color: kGreyText),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  denuncia.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: kTitleText,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              StatusBadge(status: denuncia.status),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            denuncia.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: kGreyText, fontSize: 14, height: 1.3),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              if (denuncia.address.isNotEmpty) ...[
                                                const Icon(Icons.location_on_outlined, size: 15, color: kPrimaryBlue),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    denuncia.address,
                                                    style: const TextStyle(fontSize: 12, color: kGreyText),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ] else
                                                const Spacer(),
                                              const Icon(Icons.chevron_right, size: 18, color: kGreyText),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
