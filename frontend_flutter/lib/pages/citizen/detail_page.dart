import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../components/ui.dart';
import '../../providers/app_provider.dart';

const Color kCardBorder = Color(0xFFF1F5F9);
const Color kDarkText = Color(0xFF1E293B);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);
const Color kBodyText = Color(0xFF334155);
const Color kTimelineLine = Color(0xFFE2E8F0);
const Color kTimelineDotBorder = Colors.white;
const Color kBorderColor = Color(0xFFE1E5EC);

const Color kPendienteText = Color(0xFFD97706);
const Color kEnProcesoText = Color(0xFF1D6FE0);
const Color kResueltoText = Color(0xFF1E9E5A);

class DetailPage extends StatefulWidget {
  final Complaint complaint;
  const DetailPage({super.key, required this.complaint});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Complaint _complaint;
  bool _loadingHistory = true;

  Complaint get complaint => _complaint;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final detail = await context.read<AppProvider>().fetchComplaintDetail(
      widget.complaint.id,
    );
    if (!mounted) return;

    setState(() {
      if (detail != null) _complaint = detail;
      _loadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, complaint.id.toString()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MainInfoCard(complaint: complaint),
                  const SizedBox(height: 20),
                  _HistorialCard(
                    historial: complaint.history,
                    isLoading: _loadingHistory,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String idDenuncia) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kDarkText, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        'Denuncia #$idDenuncia',
        style: const TextStyle(
          color: kDarkText,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    final location = LatLng(
      complaint.latitude != 0.0 ? complaint.latitude : -2.1894,
      complaint.longitude != 0.0 ? complaint.longitude : -79.8891,
    );

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: complaint.status),
              PriorityBadge(priority: complaint.priority),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            complaint.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kTitleText,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: kGreyText,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  complaint.address,
                  style: const TextStyle(fontSize: 13, color: kGreyText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (complaint.fotoUrl != null && complaint.fotoUrl!.isNotEmpty) ...[
            const Text(
              'FOTOGRAFÍA DE EVIDENCIA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kCardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                complaint.fotoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Center(
                  child: Icon(Icons.broken_image, size: 40, color: kGreyText),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Text(
            'UBICACIÓN REGISTRADA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kCardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
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
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Divider(color: kCardBorder, thickness: 1, height: 1),
          const SizedBox(height: 16),

          const Text(
            'DESCRIPCIÓN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            style: const TextStyle(fontSize: 14, color: kBodyText, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _HistorialCard extends StatelessWidget {
  final List<ComplaintStatusHistory> historial;
  final bool isLoading;
  const _HistorialCard({required this.historial, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Estados',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTitleText,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (historial.isEmpty)
            const Text(
              'Aún no se han registrado cambios de estado.',
              style: TextStyle(fontSize: 13, color: kGreyText),
            )
          else
            _Timeline(eventos: historial),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<ComplaintStatusHistory> eventos;
  const _Timeline({required this.eventos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(eventos.length, (index) {
        final evento = eventos[index];
        final isLast = index == eventos.length - 1;
        return _TimelineItem(evento: evento, isLast: isLast);
      }),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ComplaintStatusHistory evento;
  final bool isLast;
  const _TimelineItem({required this.evento, required this.isLast});

  Color get _dotColor {
    switch (evento.status) {
      case 'pendiente':
        return kPendienteText;
      case 'en_proceso':
        return kEnProcesoText;
      case 'resuelta':
        return kResueltoText;
      default:
        return kGreyText;
    }
  }

  String get _titulo {
    if (evento.previousStatus.isEmpty) {
      return 'Denuncia registrada';
    }
    return 'Estado actualizado a ${_estadoLabel(evento.status)}';
  }

  String get _subtitulo {
    final fecha =
        '${evento.createdAt.day.toString().padLeft(2, '0')}/'
        '${evento.createdAt.month.toString().padLeft(2, '0')}/'
        '${evento.createdAt.year}';
    final comentario = evento.comment?.trim();
    final detalle = '${evento.userName} · $fecha';
    return comentario?.isNotEmpty == true
        ? '$detalle\n$comentario'
        : '$detalle\nSin comentarios';
  }

  String _estadoLabel(String estado) => switch (estado) {
    'pendiente' => 'Pendiente',
    'en_proceso' => 'En proceso',
    'resuelta' => 'Resuelta',
    _ => estado,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: kTimelineDotBorder, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: kTimelineLine,
                      margin: const EdgeInsets.only(top: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
