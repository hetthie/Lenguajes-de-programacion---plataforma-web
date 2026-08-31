import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import '../../utils/status_utils.dart';

const Color kCardBorder = Color(0xFFE2E8F0);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);
const Color kPrimaryBlue = Color(0xFF2563EB);

class DetailAdminPage extends StatefulWidget {
  final Complaint denuncia;

  const DetailAdminPage({super.key, required this.denuncia});

  @override
  State<DetailAdminPage> createState() => _DetailAdminPageState();
}

class _DetailAdminPageState extends State<DetailAdminPage> {
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.denuncia.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final error = await context.read<AppProvider>().updateComplaintStatus(widget.denuncia.id, newStatus);
    if (mounted) {
      setState(() {
        _isUpdating = false;
        if (error == null) _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Estado actualizado a ${getStatusInfo(newStatus).label}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.denuncia;
    final LatLng location = LatLng(
      d.latitude != 0.0 ? d.latitude : -2.1894,
      d.longitude != 0.0 ? d.longitude : -79.8891,
    );

    final fotoUrl = d.fotoUrl;
    final hasFoto = fotoUrl != null && fotoUrl.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Denuncia', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------------------
                  // 1. DATOS DE LA DENUNCIA (Incluye actualización de estado)
                  // -----------------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kCardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                d.title,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTitleText),
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: _currentStatus),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          'DESCRIPCIÓN',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGreyText, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.description,
                          style: const TextStyle(fontSize: 15, color: kTitleText, height: 1.5),
                        ),
                        const SizedBox(height: 16),

                        if (d.address.isNotEmpty) ...[
                          const Text(
                            'DIRECCIÓN REFERENCIAL',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGreyText, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: kPrimaryBlue),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  d.address,
                                  style: const TextStyle(fontSize: 14, color: kTitleText),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        const Divider(height: 1, color: kCardBorder),
                        const SizedBox(height: 16),

                        // Sección Cambiar Estado integrada en el mismo recuadro
                        const Text(
                          'CAMBIAR ESTADO DE LA DENUNCIA',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGreyText, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        _isUpdating
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                children: kAllStatuses.map((info) {
                                  final isLast = info.value == kAllStatuses.last.value;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: isLast ? 0 : 8),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: info.backgroundColor,
                                          foregroundColor: info.textColor,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        // Se envía el valor canónico exacto que
                                        // espera el backend (pendiente | en_proceso | resuelta).
                                        onPressed: () => _updateStatus(info.value),
                                        child: Text(
                                          info.label.toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // -----------------------------------------------------------
                  // 2. UBICACIÓN MOSTRADA EN EL MAPA
                  // -----------------------------------------------------------
                  const Text(
                    'UBICACIÓN EN EL MAPA',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTitleText, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kCardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: location,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.frontend_flutter',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: location,
                              width: 44,
                              height: 44,
                              child: const Icon(Icons.location_on, size: 44, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // -----------------------------------------------------------
                  // 3. FOTO (SI ESTÁ DISPONIBLE) O 'Imagen no proporcionada'
                  // -----------------------------------------------------------
                  const Text(
                    'EVIDENCIA FOTOGRÁFICA',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTitleText, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kCardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasFoto
                        ? Image.network(
                            fotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildNoImageWidget(),
                          )
                        : _buildNoImageWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoImageWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.hide_image_outlined, size: 56, color: kGreyText),
        SizedBox(height: 10),
        Text(
          'Imagen no proporcionada',
          style: TextStyle(color: kGreyText, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ],
    );
  }
}
