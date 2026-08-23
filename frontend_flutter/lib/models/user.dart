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

  factory User.fromApi(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      // El backend usa "ciudadano" y "municipal"; la interfaz usa
      // "citizen" y "admin" para decidir qué panel mostrar.
      role: json['rol'] == 'municipal' ? 'admin' : 'citizen',
      status: 'Activo',
    );
  }
}
