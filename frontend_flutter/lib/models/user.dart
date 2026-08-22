class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'citizen' | 'admin'
  final String status; // 'Activo' | 'Inactivo'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}
