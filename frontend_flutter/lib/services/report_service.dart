import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/municipal_report.dart';
import '../providers/app_provider.dart';

class ReportFilters {
  final DateTime? from;
  final DateTime? to;
  final String? status;
  final int? categoryId;

  const ReportFilters({this.from, this.to, this.status, this.categoryId});

  Map<String, String> toQueryParameters() {
    return {
      if (from != null) 'desde': _date(from!),
      if (to != null) 'hasta': _date(to!),
      if (status != null && status!.isNotEmpty) 'estado': status!,
      if (categoryId != null) 'categoria_id': categoryId.toString(),
    };
  }

  static String _date(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class ReportService {
  final String token;

  const ReportService(this.token);

  Future<MunicipalReport> fetchReport(ReportFilters filters) async {
    final response = await http.get(
      _uri('/reportes/denuncias', filters),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }

    final decoded = json.decode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is! Map) throw Exception('El reporte recibido no es válido.');

    return MunicipalReport.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Uint8List> fetchCsv(ReportFilters filters) async {
    final response = await http.get(
      _uri('/reportes/denuncias/csv', filters),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }

    return response.bodyBytes;
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Uri _uri(String path, ReportFilters filters) {
    return Uri.parse('${AppProvider.baseUrl}$path').replace(
      queryParameters: filters.toQueryParameters(),
    );
  }

  String _message(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      // Si no es JSON, se usa el mensaje por codigo HTTP.
    }

    return 'No se pudo generar el reporte (${response.statusCode}).';
  }
}
