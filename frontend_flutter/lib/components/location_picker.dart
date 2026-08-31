import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const LatLng kGuayaquilCenter = LatLng(-2.1894, -79.8891);

class LocationPicker extends StatelessWidget {
  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;
  final double height;

  const LocationPicker({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación exacta en el mapa',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: selectedLocation ?? kGuayaquilCenter,
                initialZoom: 12.5,
                onTap: (_, point) => onLocationSelected(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ciudad.denuncias',
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFFE11D48),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                RichAttributionWidget(
                  attributions: const [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selectedLocation == null
                  ? Icons.touch_app_outlined
                  : Icons.check_circle,
              color:
                  selectedLocation == null
                      ? const Color(0xFF64748B)
                      : const Color(0xFF16A34A),
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                selectedLocation == null
                    ? 'Haz clic sobre el lugar exacto donde ocurrió el problema.'
                    : 'Punto seleccionado: '
                        '${selectedLocation!.latitude.toStringAsFixed(6)}, '
                        '${selectedLocation!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
