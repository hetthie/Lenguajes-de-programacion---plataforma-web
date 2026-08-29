class ComplaintStatusHistory {
  final String previousStatus;
  final String status;
  final String? comment;
  final String userName;
  final DateTime createdAt;

  const ComplaintStatusHistory({
    required this.previousStatus,
    required this.status,
    this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory ComplaintStatusHistory.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json['usuario'];
    return ComplaintStatusHistory(
      previousStatus: json['estado_anterior']?.toString() ?? '',
      status: json['estado_nuevo']?.toString() ?? 'pendiente',
      comment: json['comentario']?.toString(),
      userName:
          user is Map<String, dynamic>
              ? user['name']?.toString() ?? 'Sistema'
              : 'Sistema',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class Complaint {
  final String id;
  final String title;
  final String description;
  final String category;
  final String
  status; // 'Pendiente', 'En revisión', 'En proceso', 'Atendido', 'Rechazado'
  final String priority; // 'Alta', 'Media', 'Baja'
  final String address;
  final double latitude;
  final double longitude;
  final String direccionRef;
  final String citizenName;
  final String citizenEmail;
  final DateTime createdAt;
  final String? imageUrl;
  // dynamic mantiene compatibilidad temporal con los datos mock heredados.
  // Las respuestas del backend se convierten a ComplaintStatusHistory.
  final List<dynamic> history;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.direccionRef,
    required this.citizenName,
    required this.citizenEmail,
    required this.createdAt,
    this.imageUrl,
    required this.history,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['historial_estados'] ?? json['historial'];
    return Complaint(
      id: json['id']?.toString() ?? '',
      title: json['titulo'] ?? json['title'] ?? '',
      description: json['descripcion'] ?? json['description'] ?? '',
      category:
          json['categoria'] is Map
              ? (json['categoria']['nombre'] ?? 'General')
              : (json['categoria']?.toString() ?? 'General'),
      status: json['estado'] ?? 'Pendiente',
      priority: json['prioridad'] ?? 'Media',
      address:
          json['direccion_referencial'] ??
          json['direccion'] ??
          json['address'] ??
          'Sin dirección',
      latitude: double.tryParse(json['latitud']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitud']?.toString() ?? '0.0') ?? 0.0,
      direccionRef: json['direccion_referencial'] ?? 'Guayaquil',
      citizenName:
          json['user']?['name'] ??
          json['usuario']?['name'] ??
          json['citizenName'] ??
          'Ciudadano',
      citizenEmail:
          json['user']?['email'] ??
          json['usuario']?['email'] ??
          json['citizenEmail'] ??
          '',
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      imageUrl: json['foto_url'] ?? json['imageUrl'],
      history:
          (rawHistory is List ? rawHistory : const [])
              .whereType<Map>()
              .map(
                (item) => ComplaintStatusHistory.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
    );
  }
}
