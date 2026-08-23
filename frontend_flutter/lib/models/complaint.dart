class Complaint {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status; // 'Pendiente', 'En revisión', 'En proceso', 'Atendido', 'Rechazado'
  final String priority; // 'Alta', 'Media', 'Baja'
  final String address;
  final double latitude;
  final double longitude;
  final String citizenName;
  final String citizenEmail;
  final DateTime createdAt;
  final String? imageUrl;
  final List<String> history;

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
    required this.citizenName,
    required this.citizenEmail,
    required this.createdAt,
    this.imageUrl,
    required this.history,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id']?.toString() ?? '',
      title: json['titulo'] ?? json['title'] ?? '',
      description: json['descripcion'] ?? json['description'] ?? '',
      category: json['categoria'] is Map 
          ? (json['categoria']['nombre'] ?? 'General')
          : (json['categoria']?.toString() ?? 'General'),
      status: json['estado'] ?? 'Pendiente',
      priority: json['prioridad'] ?? 'Media',
      address: json['direccion'] ?? json['address'] ?? 'Sin dirección',
      latitude: double.tryParse(json['latitud']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitud']?.toString() ?? '0.0') ?? 0.0,
      citizenName: json['usuario']?['name'] ?? json['citizenName'] ?? 'Ciudadano',
      citizenEmail: json['usuario']?['email'] ?? json['citizenEmail'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      imageUrl: json['foto_url'] ?? json['imageUrl'],
      history: json['historial'] != null 
          ? List<String>.from(json['historial']) 
          : [],
    );
  }
}
