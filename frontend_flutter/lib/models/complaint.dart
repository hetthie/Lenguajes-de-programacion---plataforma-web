class ComplaintStatusHistory {
  final int id;
  final int complaintId;
  final String previousStatus;
  final String status;
  final String userName;
  final String? comment;
  final DateTime createdAt;

  ComplaintStatusHistory({
    required this.id,
    required this.complaintId,
    required this.previousStatus,
    required this.status,
    required this.userName,
    this.comment,
    required this.createdAt,
  });

  factory ComplaintStatusHistory.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'];
    final uName = userObj != null ? (userObj['name'] ?? '') : '';

    return ComplaintStatusHistory(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      complaintId: json['denuncia_id'] is int ? json['denuncia_id'] : int.tryParse(json['denuncia_id']?.toString() ?? '0') ?? 0,
      previousStatus: json['estado_anterior']?.toString() ?? '',
      status: json['estado_nuevo']?.toString() ?? 'pendiente',
      userName: uName.isNotEmpty ? uName : 'Sistema',
      comment: json['comentario']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }
}

class Complaint {
  final int id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String priority;
  final double latitude;
  final double longitude;
  final String address;
  final String citizenName;
  final String citizenEmail;
  final DateTime createdAt;
  final String? fotoUrl;
  final List<ComplaintStatusHistory> history;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.citizenName,
    required this.citizenEmail,
    required this.createdAt,
    this.fotoUrl,
    this.history = const [],
  });

  bool get hasValidLocation {
    final validLatitude = latitude >= -90 && latitude <= 90;
    final validLongitude = longitude >= -180 && longitude <= 180;
    final isMissingPoint = latitude == 0 && longitude == 0;
    return validLatitude && validLongitude && !isMissingPoint;
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    final catObj = json['categoria'];
    final categoryName = catObj != null ? (catObj['nombre'] ?? '') : '';

    final userObj = json['user'];
    final uName = userObj != null ? (userObj['name'] ?? '') : '';
    final uEmail = userObj != null ? (userObj['email'] ?? '') : '';

    final rawHist = json['historial_estados'] ?? json['historialEstados'];
    List<ComplaintStatusHistory> parsedHistory = [];
    if (rawHist is List) {
      parsedHistory = rawHist.map((h) => ComplaintStatusHistory.fromJson(h)).toList();
    }

    return Complaint(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['titulo']?.toString() ?? '',
      description: json['descripcion']?.toString() ?? '',
      category: categoryName.isNotEmpty ? categoryName : 'Infraestructura',
      status: json['estado']?.toString() ?? 'pendiente',
      priority: json['prioridad']?.toString() ?? 'media',
      latitude: json['latitud'] != null ? (double.tryParse(json['latitud'].toString()) ?? -2.1894) : -2.1894,
      longitude: json['longitud'] != null ? (double.tryParse(json['longitud'].toString()) ?? -79.8891) : -79.8891,
      address: json['direccion_referencial']?.toString() ?? 'Guayaquil',
      citizenName: uName.isNotEmpty ? uName : 'Ciudadano',
      citizenEmail: uEmail.isNotEmpty ? uEmail : 'ciudadano@guayaquil.gob.ec',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      fotoUrl: json['foto_url']?.toString(),
      history: parsedHistory,
    );
  }
}
