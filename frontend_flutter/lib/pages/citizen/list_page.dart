import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../components/ui.dart';
import 'detail_page.dart';

const Color kScreenBg = Color(0xFFF4F6FA);
const Color kPrimaryDark = Color(0xFF1B2A56);
const Color kAccentOrange = Color(0xFFF5A623);
const Color kDarkText = Color(0xFF16192B);
const Color kGreyText = Color(0xFF64748B);
const Color kCardBorder = Color(0xFFEEF1F6);

const Color kPendienteBg = Color(0xFFFFF1D6);
const Color kPendienteText = Color(0xFFC77A0A);
const Color kEnProcesoBg = Color(0xFFDCEBFF);
const Color kEnProcesoText = Color(0xFF1D6FE0);
const Color kResueltoBg = Color(0xFFDFF7E6);
const Color kResueltoText = Color(0xFF1E9E5A);

enum EstadoReclamo { pendiente, enProceso, resuelto }

enum FiltroEstado { todos, pendiente, enProceso, resuelto }

final Map<String, IconData> reportIcons = {
  'Bache': Icons.construction,
  'Alumbrado público dañado': Icons.lightbulb,
  'Acumulación de basura': Icons.delete,
  'Daño en espacio público': Icons.location_city,
  'Semáforo dañado': Icons.traffic,
  'Señalización vial dañada': Icons.signpost,
  'Fuga de agua': Icons.water_drop,
  'Otro': Icons.more_horiz,
};

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  FiltroEstado _filtroActual = FiltroEstado.todos;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final complaints = provider.complaints;

    if (provider.isLoading && complaints.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && complaints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AppProvider>().fetchComplaints(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final filtrados = _filtrarPorEstado(complaints, _filtroActual);

    return Scaffold(
      backgroundColor: kScreenBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => context.read<AppProvider>().fetchComplaints(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        children: [
                          const _LogoHeader(),
                          const SizedBox(height: 18),
                          const Text(
                            'Todos los Reclamos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: kDarkText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FiltrosRow(
                            filtroActual: _filtroActual,
                            onChanged: (nuevo) {
                              setState(() => _filtroActual = nuevo);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (complaints.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyState())
                  else if (filtrados.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyStateFiltro())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = filtrados[index];
                        final date = formatDate(item.createdAt.toString());

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kCardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  reportIcons[item.category] ??
                                      Icons.help_outline,
                                  color: kPrimaryDark,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${item.title} - ${item.direccionRef}',
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: kDarkText,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Text(
                                    'Reportado: $date',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: kGreyText,
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 22,
                                      color: kGreyText,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: kDarkText,
                                            height: 1.35,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Descripción: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(text: item.description),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: StatusBadge(status: item.status),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(complaint: item),
                              ),
                            ),
                          ),
                        );
                      }, childCount: filtrados.length),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<dynamic> _filtrarPorEstado(List<dynamic> complaints, FiltroEstado f) {
    if (f == FiltroEstado.todos) return complaints;
    final estadoTexto = switch (f) {
      FiltroEstado.pendiente => 'pendiente',
      FiltroEstado.enProceso => 'en_proceso',
      FiltroEstado.resuelto => 'resuelta',
      FiltroEstado.todos => '',
    };
    return complaints
        .where((c) => c.status.toString().toLowerCase().contains(estadoTexto))
        .toList();
  }
}

String formatDate(String date) {
  final dateTime = DateTime.parse(date);

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LogoPlaceholder(),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
            children: [
              TextSpan(text: 'Ciudad\n', style: TextStyle(color: kPrimaryDark)),
              TextSpan(
                text: 'Resuelve',
                style: TextStyle(color: kAccentOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Icon(
            Icons.location_city,
            size: 40,
            color: kPrimaryDark.withOpacity(0.85),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle,
              size: 18,
              color: kAccentOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltrosRow extends StatelessWidget {
  final FiltroEstado filtroActual;
  final ValueChanged<FiltroEstado> onChanged;

  const _FiltrosRow({required this.filtroActual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final opciones = <FiltroEstado, String>{
      FiltroEstado.todos: 'Todos',
      FiltroEstado.pendiente: 'Pendiente',
      FiltroEstado.enProceso: 'En Proceso',
      FiltroEstado.resuelto: 'Resuelto',
    };

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = opciones.entries.elementAt(index);
          final seleccionado = entry.key == filtroActual;
          return ChoiceChip(
            label: Text(entry.value),
            selected: seleccionado,
            onSelected: (_) => onChanged(entry.key),
            selectedColor: kPrimaryDark,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: seleccionado ? Colors.white : kDarkText,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
            side: BorderSide(color: seleccionado ? kPrimaryDark : kCardBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 44, color: kGreyText),
          const SizedBox(height: 12),
          const Text(
            'Aún no hay reclamos registrados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kGreyText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateFiltro extends StatelessWidget {
  const _EmptyStateFiltro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.filter_alt_off_outlined, size: 44, color: kGreyText),
          const SizedBox(height: 12),
          const Text(
            'No hay reclamos para este filtro.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kGreyText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}