import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/complaint.dart';

class CityMap extends StatelessWidget {
  final List<Complaint> complaints;
  final ValueChanged<Complaint>? onMarkerTap;
  final bool showLegend;

  const CityMap({
    super.key,
    required this.complaints,
    this.onMarkerTap,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    final validComplaints =
        complaints.where((item) => item.hasValidLocation).toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(-2.1894, -79.8891),
            initialZoom: 12.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ciudad.denuncias',
            ),
            MarkerLayer(
              markers:
                  validComplaints.map((item) {
                    return Marker(
                      point: LatLng(item.latitude, item.longitude),
                      width: 46,
                      height: 46,
                      child: Semantics(
                        button: onMarkerTap != null,
                        label: '${item.title}, ${item.direccionRef}',
                        child: Tooltip(
                          message: '${item.title}\n${item.direccionRef}',
                          child: GestureDetector(
                            onTap: () => onMarkerTap?.call(item),
                            child: Icon(
                              Icons.location_on,
                              color: _statusColor(item.status),
                              size: 42,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            RichAttributionWidget(
              attributions: const [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        if (showLegend)
          const Positioned(top: 12, right: 12, child: _StatusLegend()),
        if (validComplaints.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: const Text(
                'No hay denuncias con ubicación para mostrar.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resuelta':
        return const Color(0xFF16A34A);
      case 'en_proceso':
        return const Color(0xFF2563EB);
      case 'pendiente':
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendItem(color: Color(0xFFF59E0B), label: 'Pendiente'),
          SizedBox(height: 5),
          _LegendItem(color: Color(0xFF2563EB), label: 'En proceso'),
          SizedBox(height: 5),
          _LegendItem(color: Color(0xFF16A34A), label: 'Resuelta'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 17),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
