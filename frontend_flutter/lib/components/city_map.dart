import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/complaint.dart';

class CityMap extends StatelessWidget {
  final List<Complaint> complaints;
  final Function(Complaint)? onMarkerTap;

  const CityMap({super.key, required this.complaints, this.onMarkerTap});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(-2.1894, -79.8891),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ciudad.denuncias',
        ),
        MarkerLayer(
          markers:
              complaints.map((item) {
                return Marker(
                  point: LatLng(item.latitude, item.longitude),
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    onTap: () => onMarkerTap?.call(item),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 36,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
