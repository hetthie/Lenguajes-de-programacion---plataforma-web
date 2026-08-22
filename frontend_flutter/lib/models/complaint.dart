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
}
