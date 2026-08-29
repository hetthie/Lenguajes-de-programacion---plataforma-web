import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/complaint.dart';
import '../models/user.dart';
import '../models/categoria.dart';

class AppProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  List<Complaint> _myComplaints = [];
  List<User> _users = [];
  List<Categoria> _categorias = [];
  User? _currentUser;
  String? _token;

  bool _isLoading = false;
  String? _error;

  bool _isLoadingMine = false;
  String? _errorMine;

  bool _isLoadingCategorias = false;
  String? _errorCategorias;

  bool _isSubmitting = false;

  List<Complaint> get complaints => _complaints;
  List<Complaint> get myComplaints => _myComplaints;
  List<User> get users => _users;
  List<Categoria> get categorias => _categorias;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoadingMine => _isLoadingMine;
  String? get errorMine => _errorMine;
  bool get isLoadingCategorias => _isLoadingCategorias;
  String? get errorCategorias => _errorCategorias;
  bool get isSubmitting => _isSubmitting;

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  AppProvider() {
    fetchComplaints();
  }

  // Extrae la lista real sin importar cuántos niveles de envoltura tenga
  // la respuesta (paginador de Laravel, wrapper {success, data}, o lista plana).
  List _extractList(dynamic decoded) {
    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      final inner = decoded['data'];

      if (inner is List) return inner;

      if (inner is Map<String, dynamic>) {
        final nested = inner['data'];
        if (nested is List) return nested;
      }
    }

    return [];
  }

  Future<void> fetchComplaints() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/denuncias'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawList = _extractList(data);
        _complaints = rawList.map((item) => Complaint.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        _error = 'Debes iniciar sesión para ver las denuncias.';
      } else {
        _error = 'Error al obtener denuncias: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión con el servidor: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyComplaints() async {
    if (_token == null) return;

    _isLoadingMine = true;
    _errorMine = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/denuncias/mis-denuncias'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawList = _extractList(data);
        _myComplaints = rawList.map((item) => Complaint.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        _errorMine = 'Tu sesión expiró, vuelve a iniciar sesión.';
      } else {
        _errorMine = 'Error al obtener tus denuncias: ${response.statusCode}';
      }
    } catch (e) {
      _errorMine = 'Error de conexión con el servidor: $e';
    } finally {
      _isLoadingMine = false;
      notifyListeners();
    }
  }

  // Carga las categorías reales del backend para el formulario de creación
  Future<void> fetchCategorias() async {
    if (_categorias.isNotEmpty) return; // ya cargadas, no repetir

    _isLoadingCategorias = true;
    _errorCategorias = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categorias'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawList = _extractList(data);
        _categorias = rawList.map((item) => Categoria.fromJson(item)).toList();
      } else {
        _errorCategorias = 'No se pudieron cargar las categorías (${response.statusCode}).';
      }
    } catch (e) {
      _errorCategorias = 'Error de conexión al cargar categorías: $e';
    } finally {
      _isLoadingCategorias = false;
      notifyListeners();
    }
  }

  void setSession(User user, String token) {
    _currentUser = user;
    _token = token;
    notifyListeners();
    fetchComplaints();
    fetchMyComplaints();
  }

  void setUsers(List<User> users) {
    _users = users;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _token = null;
    _myComplaints = [];
    _categorias = [];
    notifyListeners();
  }

  void addComplaint(Complaint complaint) {
    _complaints.insert(0, complaint);
    notifyListeners();
  }

  // Crea una denuncia real en el backend.
  // Devuelve null si fue exitoso, o un mensaje de error si algo falló.
  Future<String?> createComplaint({
    required String titulo,
    required String descripcion,
    required int categoriaId,
    required String direccionReferencial,
    required double latitud,
    required double longitud,
  }) async {
    if (_token == null) {
      return 'Debes iniciar sesión para crear una denuncia.';
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/denuncias'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'titulo': titulo,
          'descripcion': descripcion,
          'categoria_id': categoriaId,
          'direccion_referencial': direccionReferencial,
          'latitud': latitud,
          'longitud': longitud,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final nuevaData = decoded is Map<String, dynamic> ? decoded['data'] : null;

        if (nuevaData is Map<String, dynamic>) {
          final nueva = Complaint.fromJson(nuevaData);
          _complaints.insert(0, nueva);
          _myComplaints.insert(0, nueva);
        } else {
          // Si el backend no devuelve la denuncia creada, recargamos de la API
          await fetchComplaints();
          await fetchMyComplaints();
        }

        notifyListeners();
        return null; // éxito
      } else if (response.statusCode == 422) {
        // Errores de validación de Laravel
        final decoded = json.decode(response.body);
        final errors = decoded['errors'];
        if (errors is Map) {
          final firstError = errors.values.first;
          return firstError is List ? firstError.first.toString() : firstError.toString();
        }
        return decoded['message']?.toString() ?? 'Datos inválidos.';
      } else {
        return 'Error al crear la denuncia: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error de conexión con el servidor: $e';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateComplaintStatus(String id, String newStatus) async {
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _complaints[index];

      if (_token != null) {
        try {
          final response = await http.patch(
            Uri.parse('$baseUrl/denuncias/$id/estado'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token',
            },
            body: json.encode({'estado': newStatus}),
          );

          if (response.statusCode == 200) {
            await fetchComplaints();
            return;
          }
        } catch (_) {
          // Si falla la red, mantenemos el cambio local como fallback
        }
      }

      old.history.add('Estado actualizado a: $newStatus');
      _complaints[index] = Complaint(
        id: old.id,
        title: old.title,
        description: old.description,
        category: old.category,
        status: newStatus,
        priority: old.priority,
        address: old.address,
        latitude: old.latitude,
        longitude: old.longitude,
        direccionRef: old.direccionRef,
        citizenName: old.citizenName,
        citizenEmail: old.citizenEmail,
        createdAt: old.createdAt,
        imageUrl: old.imageUrl,
        history: old.history,
      );
      notifyListeners();
    }
  }
}
