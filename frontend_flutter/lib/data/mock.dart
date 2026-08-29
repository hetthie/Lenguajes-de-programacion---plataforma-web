import '../models/complaint.dart';
import '../models/user.dart';

List<Complaint> mockComplaints = [
  Complaint(
    id: 'DEN-001',
    title: 'Bache peligroso en avenida principal',
    description:
        'Existe un bache de gran dimensión que está causando daños a los vehículos.',
    category: 'Vías y Tránsito',
    status: 'En proceso',
    priority: 'Alta',
    address: 'Av. Las Américas y Calle 10',
    latitude: -2.1894,
    longitude: -79.8891,
    direccionRef: 'Guayaquil',
    citizenName: 'Carlos Mendoza',
    citizenEmail: 'carlos@example.com',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    imageUrl: 'https://via.placeholder.com/400x200',
    history: [
      'Denuncia creada por el ciudadano',
      'Asignada al departamento de Obras Públicas',
    ],
  ),
  Complaint(
    id: 'DEN-002',
    title: 'Luminaria pública averiada',
    description:
        'La luminaria del parque se apaga continuamente generando inseguridad.',
    category: 'Alumbrado',
    status: 'Pendiente',
    priority: 'Media',
    address: 'Parque Central, Sector 4',
    latitude: -2.1920,
    longitude: -79.8850,
    direccionRef: 'Guayaquil',
    citizenName: 'Ana Gómez',
    citizenEmail: 'ana@example.com',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    history: ['Denuncia recibida en el sistema'],
  ),
];

List<User> mockUsers = [
  User(
    id: 'USR-1',
    name: 'Carlos Mendoza',
    email: 'carlos@example.com',
    role: 'citizen',
    status: 'Activo',
  ),
  User(
    id: 'USR-2',
    name: 'Ana Gómez',
    email: 'ana@example.com',
    role: 'citizen',
    status: 'Activo',
  ),
  User(
    id: 'USR-3',
    name: 'Admin General',
    email: 'admin@ciudad.gob',
    role: 'admin',
    status: 'Activo',
  ),
];
