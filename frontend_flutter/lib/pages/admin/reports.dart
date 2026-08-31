import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/categoria.dart';
import '../../models/complaint.dart';
import '../../models/municipal_report.dart';
import '../../providers/app_provider.dart';
import '../../services/file_download.dart';
import '../../services/report_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const _all = 'todos';

  MunicipalReport? _report;
  DateTimeRange? _dateRange;
  String _status = _all;
  int _categoryId = 0;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AppProvider>().fetchCategorias();
      if (mounted) await _loadReport();
    });
  }

  ReportFilters get _filters => ReportFilters(
    from: _dateRange?.start,
    to: _dateRange?.end,
    status: _status == _all ? null : _status,
    categoryId: _categoryId == 0 ? null : _categoryId,
  );

  Future<void> _loadReport() async {
    final token = context.read<AppProvider>().token;
    if (token == null) {
      setState(() => _error = 'La sesión ha expirado.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final report = await ReportService(token).fetchReport(_filters);
      if (!mounted) return;
      setState(() => _report = report);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadCsv() async {
    final token = context.read<AppProvider>().token;
    if (token == null) return;

    setState(() => _isExporting = true);
    try {
      final bytes = await ReportService(token).fetchCsv(_filters);
      final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      downloadBytes(bytes, 'reporte_denuncias_$stamp.csv', 'text/csv');
      _showMessage('Reporte CSV descargado correctamente.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _openPdfView() {
    final report = _report;
    if (report == null) return;

    try {
      openPrintableHtml(_buildPrintableHtml(report));
      _showMessage(
        'Se abrió la vista imprimible. En Chrome elige “Guardar como PDF”.',
      );
    } catch (error) {
      _showMessage(error.toString(), error: true);
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _dateRange,
      helpText: 'Rango del reporte',
      saveText: 'Aplicar',
    );

    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
    }
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _status = _all;
      _categoryId = 0;
    });
    _loadReport();
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().categorias;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Reportes municipales')),
      body: LayoutBuilder(
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FilterPanel(
                      categories: categories,
                      status: _status,
                      categoryId: _categoryId,
                      dateRange: _dateRange,
                      isLoading: _isLoading,
                      onStatusChanged:
                          (value) => setState(() => _status = value),
                      onCategoryChanged:
                          (value) => setState(() => _categoryId = value),
                      onSelectDates: _selectDateRange,
                      onApply: _loadReport,
                      onClear: _clearFilters,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _ErrorCard(message: _error!, onRetry: _loadReport),
                    ],
                    if (_report != null) ...[
                      const SizedBox(height: 20),
                      _SummaryCards(report: _report!),
                      const SizedBox(height: 20),
                      _ExportCard(
                        isExporting: _isExporting,
                        enabled: !_isLoading,
                        onCsv: _downloadCsv,
                        onPdf: _openPdfView,
                      ),
                      const SizedBox(height: 20),
                      _CategoryBreakdown(items: _report!.byCategory),
                      const SizedBox(height: 20),
                      _ComplaintsPreview(complaints: _report!.complaints),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _buildPrintableHtml(MunicipalReport report) {
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final period =
        _dateRange == null
            ? 'Todos los registros'
            : '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - '
                '${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}';
    final rows = report.complaints.map((complaint) {
      return '''
        <tr>
          <td>${_escape(complaint.id)}</td>
          <td>${_escape(DateFormat('dd/MM/yyyy').format(complaint.createdAt))}</td>
          <td>${_escape(complaint.title)}</td>
          <td>${_escape(complaint.category)}</td>
          <td>${_escape(_statusLabel(complaint.status))}</td>
          <td>${_escape(complaint.direccionRef)}</td>
          <td>${_escape(complaint.citizenName)}</td>
        </tr>
      ''';
    }).join();

    return '''<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Reporte municipal de denuncias</title>
  <style>
    body { font-family: Arial, sans-serif; color: #0f172a; margin: 32px; }
    h1 { color: #1b2a56; margin-bottom: 4px; }
    .meta { color: #64748b; margin-bottom: 20px; }
    .summary { display: flex; gap: 10px; margin: 18px 0; }
    .metric { border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px 14px; }
    .metric b { display: block; font-size: 20px; }
    table { width: 100%; border-collapse: collapse; font-size: 11px; }
    th, td { border: 1px solid #cbd5e1; padding: 7px; text-align: left; }
    th { background: #e2e8f0; }
    .print { margin-bottom: 16px; padding: 10px 16px; cursor: pointer; }
    @media print { .print { display: none; } body { margin: 10mm; } }
  </style>
</head>
<body>
  <button class="print" onclick="window.print()">Imprimir / Guardar como PDF</button>
  <h1>Reporte municipal de denuncias</h1>
  <div class="meta">Periodo: ${_escape(period)} · Generado: ${_escape(generatedAt)}</div>
  <div class="summary">
    <div class="metric"><b>${report.total}</b>Total</div>
    <div class="metric"><b>${report.pending}</b>Pendientes</div>
    <div class="metric"><b>${report.inProgress}</b>En proceso</div>
    <div class="metric"><b>${report.resolved}</b>Resueltas</div>
  </div>
  <table>
    <thead><tr><th>ID</th><th>Fecha</th><th>Título</th><th>Categoría</th><th>Estado</th><th>Dirección</th><th>Ciudadano</th></tr></thead>
    <tbody>$rows</tbody>
  </table>
</body>
</html>''';
  }

  String _escape(Object? value) {
    return const HtmlEscape(HtmlEscapeMode.element).convert(value?.toString() ?? '');
  }
}

class _FilterPanel extends StatelessWidget {
  final List<Categoria> categories;
  final String status;
  final int categoryId;
  final DateTimeRange? dateRange;
  final bool isLoading;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<int> onCategoryChanged;
  final VoidCallback onSelectDates;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _FilterPanel({
    required this.categories,
    required this.status,
    required this.categoryId,
    required this.dateRange,
    required this.isLoading,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onSelectDates,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros del reporte',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: status,
                    decoration: _inputDecoration('Estado'),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'en_proceso',
                        child: Text('En proceso'),
                      ),
                      DropdownMenuItem(
                        value: 'resuelta',
                        child: Text('Resuelta'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) onStatusChanged(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<int>(
                    value: categoryId,
                    isExpanded: true,
                    decoration: _inputDecoration('Categoría'),
                    items: [
                      const DropdownMenuItem(
                        value: 0,
                        child: Text('Todas'),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(
                            category.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) onCategoryChanged(value);
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSelectDates,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(
                    dateRange == null
                        ? 'Seleccionar fechas'
                        : '${DateFormat('dd/MM/yy').format(dateRange!.start)} - '
                            '${DateFormat('dd/MM/yy').format(dateRange!.end)}',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onApply,
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text('Aplicar'),
                ),
                TextButton(
                  onPressed: isLoading ? null : onClear,
                  child: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final MunicipalReport report;

  const _SummaryCards({required this.report});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricCard(label: 'Total', value: report.total, color: const Color(0xFF2563EB)),
        _MetricCard(label: 'Pendientes', value: report.pending, color: const Color(0xFFF59E0B)),
        _MetricCard(label: 'En proceso', value: report.inProgress, color: const Color(0xFF0EA5E9)),
        _MetricCard(label: 'Resueltas', value: report.resolved, color: const Color(0xFF16A34A)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final bool isExporting;
  final bool enabled;
  final VoidCallback onCsv;
  final VoidCallback onPdf;

  const _ExportCard({
    required this.isExporting,
    required this.enabled,
    required this.onCsv,
    required this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Exportar resultados:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            ElevatedButton.icon(
              onPressed: enabled && !isExporting ? onCsv : null,
              icon:
                  isExporting
                      ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.table_view_outlined),
              label: const Text('Descargar CSV'),
            ),
            OutlinedButton.icon(
              onPressed: enabled ? onPdf : null,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Imprimir / Guardar PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<CategoryReportCount> items;

  const _CategoryBreakdown({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución por categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('No hay datos para los filtros seleccionados.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    items
                        .map(
                          (item) => Chip(
                            label: Text('${item.category}: ${item.total}'),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintsPreview extends StatelessWidget {
  final List<Complaint> complaints;

  const _ComplaintsPreview({required this.complaints});

  @override
  Widget build(BuildContext context) {
    final visible = complaints.take(50).toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vista previa (${complaints.length} registros)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (complaints.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No existen denuncias para estos filtros.'),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Título')),
                    DataColumn(label: Text('Categoría')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Dirección')),
                  ],
                  rows:
                      visible.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item.id)),
                            DataCell(Text(DateFormat('dd/MM/yyyy').format(item.createdAt))),
                            DataCell(SizedBox(width: 220, child: Text(item.title))),
                            DataCell(Text(item.category)),
                            DataCell(Text(_statusLabel(item.status))),
                            DataCell(SizedBox(width: 240, child: Text(item.direccionRef))),
                          ],
                        );
                      }).toList(),
                ),
              ),
            if (complaints.length > 50)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'La vista muestra 50 registros; el archivo exportado incluye todos.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFEF2F2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'en_proceso':
      return 'En proceso';
    case 'resuelta':
      return 'Resuelta';
    case 'pendiente':
    default:
      return 'Pendiente';
  }
}
