import 'complaint.dart';

class CategoryReportCount {
  final String category;
  final int total;

  const CategoryReportCount({required this.category, required this.total});

  factory CategoryReportCount.fromJson(Map<String, dynamic> json) {
    return CategoryReportCount(
      category: json['categoria']?.toString() ?? 'Sin categoría',
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class MunicipalReport {
  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
  final List<CategoryReportCount> byCategory;
  final List<Complaint> complaints;

  const MunicipalReport({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
    required this.byCategory,
    required this.complaints,
  });

  factory MunicipalReport.fromJson(Map<String, dynamic> json) {
    final summary =
        json['resumen'] is Map
            ? Map<String, dynamic>.from(json['resumen'] as Map)
            : <String, dynamic>{};
    final categories = json['por_categoria'];
    final complaints = json['denuncias'];

    return MunicipalReport(
      total: (summary['total'] as num?)?.toInt() ?? 0,
      pending: (summary['pendientes'] as num?)?.toInt() ?? 0,
      inProgress: (summary['en_proceso'] as num?)?.toInt() ?? 0,
      resolved: (summary['resueltas'] as num?)?.toInt() ?? 0,
      byCategory:
          (categories is List ? categories : const [])
              .whereType<Map>()
              .map(
                (item) => CategoryReportCount.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
      complaints:
          (complaints is List ? complaints : const [])
              .whereType<Map>()
              .map(
                (item) =>
                    Complaint.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
    );
  }
}
