import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/city_map.dart';
import '../../components/map_filter_bar.dart';
import '../../models/complaint.dart';
import '../../providers/app_provider.dart';
import 'detail_admin.dart';

class MapAdminPage extends StatefulWidget {
  const MapAdminPage({super.key});

  @override
  State<MapAdminPage> createState() => _MapAdminPageState();
}

class _MapAdminPageState extends State<MapAdminPage> {
  String _status = MapFilterBar.allValue;
  String _category = MapFilterBar.allValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (provider.mapComplaints.isEmpty && !provider.isLoadingMap) {
        provider.fetchMapComplaints();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories =
        provider.mapComplaints.map((item) => item.category).toSet().toList()
          ..sort();
    final visible = _applyFilters(provider.mapComplaints);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de incidencias')),
      body: Column(
        children: [
          if (provider.errorMap != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFFEF2F2),
              padding: const EdgeInsets.all(8),
              child: Text(
                provider.errorMap!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB91C1C)),
              ),
            ),
          MapFilterBar(
            categories: categories,
            selectedStatus: _status,
            selectedCategory: _category,
            onStatusChanged: (value) => setState(() => _status = value),
            onCategoryChanged: (value) => setState(() => _category = value),
            onRefresh: provider.fetchMapComplaints,
            isRefreshing: provider.isLoadingMap,
            visibleCount: visible.length,
          ),
          Expanded(
            child:
                provider.isLoadingMap && provider.mapComplaints.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : CityMap(complaints: visible, onMarkerTap: _openComplaint),
          ),
        ],
      ),
    );
  }

  Future<void> _openComplaint(Complaint complaint) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailAdminPage(denuncia: complaint)),
    );

    if (mounted) context.read<AppProvider>().fetchMapComplaints();
  }

  List<Complaint> _applyFilters(List<Complaint> complaints) {
    return complaints.where((item) {
      final matchesStatus =
          _status == MapFilterBar.allValue || item.status == _status;
      final matchesCategory =
          _category == MapFilterBar.allValue || item.category == _category;
      return matchesStatus && matchesCategory && item.hasValidLocation;
    }).toList();
  }
}
