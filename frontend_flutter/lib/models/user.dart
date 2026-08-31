class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'ciudadano' | 'municipal'
  final String status; // 'Activo' | 'Inactivo'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  factory User.fromApi(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['rol']?.toString() ?? 'ciudadano',
      status: 'Activo',
    );
  }

  bool get isMunicipal => role == 'municipal';

  String get roleLabel => isMunicipal ? 'Municipal' : 'Ciudadano';
}
