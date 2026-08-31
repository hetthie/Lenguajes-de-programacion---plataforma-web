import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/city_map.dart';
import '../../components/map_filter_bar.dart';
import '../../models/complaint.dart';
import '../../providers/app_provider.dart';
import 'detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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

    if (provider.errorMap != null && provider.mapComplaints.isEmpty) {
      return _MapError(
        message: provider.errorMap!,
        onRetry: provider.fetchMapComplaints,
      );
    }

    return Column(
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
                  : CityMap(
                    complaints: visible,
                    onMarkerTap: (item) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(complaint: item),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
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

class _MapError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MapError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
