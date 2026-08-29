import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
/// Detalle de la Denuncia
/// Adaptación a Flutter del maquetado HTML/CSS proporcionado.
/// Responsive: contenido centrado con ancho máximo de 540px (igual que el
/// `max-width: 540px` del div original), a todo el ancho en móvil.
/// -----------------------------------------------------------------------
///
/// Cómo integrar con tu proyecto real (el que usa AppProvider):
///   1. Reemplaza el modelo `ComplaintDetail` de este archivo por tu clase
///      real `Complaint` (la misma que usas en `DetailPage(complaint: item)`).
///   2. El historial de estados (`HistorialEvento`) probablemente venga del
///      mismo objeto complaint (ej. `item.historial`) o de un endpoint
///      aparte (`GET /api/reclamos/:id/historial`) — aquí lo dejo como una
///      lista independiente fácil de conectar a cualquiera de las dos.
///   3. Si ya tienes un widget `StatusBadge`, puedes usarlo en vez de
///      `_EstadoBadge` para no duplicar lógica de colores.
///
/// Paleta de colores usada (tomada directamente del HTML/CSS entregado):
///   - Fondo de pantalla:            #F8FAFC (kScreenBg)
///   - Fondo de tarjetas:            #FFFFFF
///   - Borde de tarjetas:            #F1F5F9 (kCardBorder)
///   - Título / texto principal:     #1E293B / #0F172A (kDarkText / kTitleText)
///   - Texto secundario:             #64748B (kGreyText)
///   - Texto de descripción:         #334155 (kBodyText)
///   - Línea de la línea de tiempo:  #E2E8F0 (kTimelineLine)
///   - Punto del timeline / badge
///     "Pendiente":                  #D97706 sobre #FEF3C7
///   - Badge "Prioridad":            #475569 sobre #F1F5F9
/// -----------------------------------------------------------------------

const Color kScreenBg = Color(0xFFF8FAFC);
const Color kCardBorder = Color(0xFFF1F5F9);
const Color kDarkText = Color(0xFF1E293B);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);
const Color kBodyText = Color(0xFF334155);
const Color kTimelineLine = Color(0xFFE2E8F0);
const Color kTimelineDotBorder = Colors.white;

// Colores de badges de estado
const Color kPendienteBg = Color(0xFFFEF3C7);
const Color kPendienteText = Color(0xFFD97706);
const Color kEnProcesoBg = Color(0xFFDCEBFF);
const Color kEnProcesoText = Color(0xFF1D6FE0);
const Color kResueltoBg = Color(0xFFDFF7E6);
const Color kResueltoText = Color(0xFF1E9E5A);

// Colores de badge de prioridad
const Color kPrioridadBg = Color(0xFFF1F5F9);
const Color kPrioridadText = Color(0xFF475569);

void main() {
  runApp(const DetalleDenunciaApp());
}

class DetalleDenunciaApp extends StatelessWidget {
  const DetalleDenunciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detalle de la Denuncia',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: kScreenBg,
        useMaterial3: true,
      ),
      home: ComplaintDetailPage(complaint: _mockComplaint),
    );
  }
}

/// -------------------------------------------------------------------
/// Modelos de datos (reemplázalos por tu clase `Complaint` real)
/// -------------------------------------------------------------------
enum EstadoDenuncia { pendiente, enProceso, resuelto }

class HistorialEvento {
  final String titulo;
  final String subtitulo;
  final EstadoDenuncia estado;

  const HistorialEvento({
    required this.titulo,
    required this.subtitulo,
    required this.estado,
  });
}

class ComplaintDetail {
  final int id;
  final EstadoDenuncia estado;
  final String prioridad;
  final String titulo;
  final String direccion;
  final String descripcion;
  final List<HistorialEvento> historial;

  const ComplaintDetail({
    required this.id,
    required this.estado,
    required this.prioridad,
    required this.titulo,
    required this.direccion,
    required this.descripcion,
    required this.historial,
  });
}

/// Dato de ejemplo, simulando lo que vendría de tu API / provider.
const ComplaintDetail _mockComplaint = ComplaintDetail(
  id: 1,
  estado: EstadoDenuncia.pendiente,
  prioridad: 'Media',
  titulo: 'Bache peligroso',
  direccion: 'Sin dirección',
  descripcion: 'Hay un bache grande en la calle.',
  historial: [
    HistorialEvento(
      titulo: 'Registrada como "Pendiente"',
      subtitulo: 'Estado inicial asignado',
      estado: EstadoDenuncia.pendiente,
    ),
  ],
);

class ComplaintDetailPage extends StatelessWidget {
  final ComplaintDetail complaint;

  const ComplaintDetailPage({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 540 ? 540.0 : double.infinity;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado con ID de la denuncia
                      _HeaderRow(
                        title: 'Denuncia #${complaint.id}',
                        onBack: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(height: 20),

                      // Tarjeta principal de la denuncia
                      _MainInfoCard(complaint: complaint),
                      const SizedBox(height: 20),

                      // Tarjeta de historial de estados
                      _HistorialCard(historial: complaint.historial),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// -------------------------------------------------------------------
/// Encabezado: botón "←" + "Denuncia #N"
/// -------------------------------------------------------------------
class _HeaderRow extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _HeaderRow({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: kDarkText, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDarkText,
          ),
        ),
      ],
    );
  }
}

/// -------------------------------------------------------------------
/// Tarjeta principal: badges, título, dirección, descripción
/// -------------------------------------------------------------------
class _MainInfoCard extends StatelessWidget {
  final ComplaintDetail complaint;
  const _MainInfoCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges de estado y prioridad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _EstadoBadge(estado: complaint.estado),
              _PrioridadBadge(prioridad: complaint.prioridad),
            ],
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            complaint.titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kTitleText,
            ),
          ),
          const SizedBox(height: 6),

          // Dirección
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: kGreyText),
              const SizedBox(width: 4),
              Text(
                complaint.direccion,
                style: const TextStyle(fontSize: 13, color: kGreyText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: kCardBorder, thickness: 1, height: 1),
          const SizedBox(height: 16),

          // Sección de descripción
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
            complaint.descripcion,
            style: const TextStyle(fontSize: 14, color: kBodyText, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// -------------------------------------------------------------------
/// Tarjeta de historial de estados (timeline vertical)
/// -------------------------------------------------------------------
class _HistorialCard extends StatelessWidget {
  final List<HistorialEvento> historial;
  const _HistorialCard({required this.historial});

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
          _Timeline(eventos: historial),
        ],
      ),
    );
  }
}

/// Línea de tiempo vertical: una barra continua a la izquierda con un
/// punto de color por cada evento.
class _Timeline extends StatelessWidget {
  final List<HistorialEvento> eventos;
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
  final HistorialEvento evento;
  final bool isLast;
  const _TimelineItem({required this.evento, required this.isLast});

  Color get _dotColor {
    switch (evento.estado) {
      case EstadoDenuncia.pendiente:
        return kPendienteText;
      case EstadoDenuncia.enProceso:
        return kEnProcesoText;
      case EstadoDenuncia.resuelto:
        return kResueltoText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna con la línea vertical + punto
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

          // Texto del evento
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    evento.subtitulo,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
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

/// -------------------------------------------------------------------
/// Contenedor reutilizable de tarjeta blanca
/// -------------------------------------------------------------------
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// -------------------------------------------------------------------
/// Badge de estado (Pendiente / En Proceso / Resuelto)
/// -------------------------------------------------------------------
class _EstadoBadge extends StatelessWidget {
  final EstadoDenuncia estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (estado) {
      case EstadoDenuncia.pendiente:
        bg = kPendienteBg;
        fg = kPendienteText;
        label = 'Pendiente';
        break;
      case EstadoDenuncia.enProceso:
        bg = kEnProcesoBg;
        fg = kEnProcesoText;
        label = 'En Proceso';
        break;
      case EstadoDenuncia.resuelto:
        bg = kResueltoBg;
        fg = kResueltoText;
        label = 'Resuelto';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// -------------------------------------------------------------------
/// Badge de prioridad
/// -------------------------------------------------------------------
class _PrioridadBadge extends StatelessWidget {
  final String prioridad;
  const _PrioridadBadge({required this.prioridad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kPrioridadBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Prioridad: $prioridad',
        style: const TextStyle(
          color: kPrioridadText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}