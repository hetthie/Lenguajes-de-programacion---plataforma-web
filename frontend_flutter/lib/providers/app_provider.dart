import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint.dart';
import '../models/user.dart';
import '../models/categoria.dart';
import '../utils/status_utils.dart';

class AppProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  List<Complaint> _mapComplaints = [];
  List<Complaint> _myComplaints = [];
  List<User> _users = [];
  List<Categoria> _categorias = [];
  User? _currentUser;
  String? _token;

  bool _isLoading = false;
  String? _error;

  bool _isLoadingMine = false;
  String? _errorMine;

  bool _isLoadingMap = false;
  String? _errorMap;

  bool _isLoadingCategorias = false;
  String? _errorCategorias;

  bool _isSubmitting = false;
  bool _isLoadingSummary = false;
  String? _errorSummary;
  Map<String, int> _complaintSummary = const {
    'total': 0,
    'pendientes': 0,
    'aprobadas': 0,
  };

  List<Complaint> get complaints => _complaints;
  List<Complaint> get mapComplaints => _mapComplaints;
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
  bool get isLoadingMap => _isLoadingMap;
  String? get errorMap => _errorMap;
  bool get isLoadingCategorias => _isLoadingCategorias;
  String? get errorCategorias => _errorCategorias;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingSummary => _isLoadingSummary;
  String? get errorSummary => _errorSummary;
  Map<String, int> get complaintSummary => _complaintSummary;

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  AppProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('jwt_token') || !prefs.containsKey('user_data')) {
        await fetchComplaints();
        return;
      }

      _token = prefs.getString('jwt_token');
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        _currentUser = User.fromApi(json.decode(userJson));
      }
      notifyListeners();

      await fetchComplaints();
      await fetchMyComplaints();
    } catch (_) {
      await fetchComplaints();
    }
  }

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
    if (_token == null) return;

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
        _myComplaints =
            rawList.map((item) => Complaint.fromJson(item)).toList();
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

  /// Carga todas las denuncias georreferenciadas sin la paginacion de la lista.
  Future<void> fetchMapComplaints() async {
    if (_token == null) return;

    _isLoadingMap = true;
    _errorMap = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/denuncias/mapa'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawList = _extractList(data);
        _mapComplaints =
            rawList.map((item) => Complaint.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        _errorMap = 'Tu sesion expiro, vuelve a iniciar sesion.';
      } else {
        _errorMap = 'No se pudo cargar el mapa (${response.statusCode}).';
      }
    } catch (e) {
      _errorMap = 'Error de conexion al cargar el mapa: $e';
    } finally {
      _isLoadingMap = false;
      notifyListeners();
    }
  }

  Future<void> fetchComplaintSummary() async {
    if (_token == null) return;

    _isLoadingSummary = true;
    _errorSummary = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/denuncias/estadisticas'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      final decoded = json.decode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;

      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        _complaintSummary = {
          'total': (data['total'] as num?)?.toInt() ?? 0,
          'pendientes': (data['pendientes'] as num?)?.toInt() ?? 0,
          'aprobadas': (data['aprobadas'] as num?)?.toInt() ?? 0,
        };
      } else {
        _errorSummary = 'No se pudieron cargar los indicadores.';
      }
    } catch (e) {
      _errorSummary = 'Error de conexión con el servidor: $e';
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<Complaint?> fetchComplaintDetail(dynamic id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/denuncias/$id'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      return data is Map<String, dynamic> ? Complaint.fromJson(data) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchCategorias() async {
    if (_categorias.isNotEmpty) return;

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
        _errorCategorias =
            'No se pudieron cargar las categorías (${response.statusCode}).';
      }
    } catch (e) {
      _errorCategorias = 'Error de conexión al cargar categorías: $e';
    } finally {
      _isLoadingCategorias = false;
      notifyListeners();
    }
  }

  Future<void> setSession(User user, String token, {Map<String, dynamic>? rawUserJson}) async {
    _currentUser = user;
    _token = token;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    if (rawUserJson != null) {
      await prefs.setString('user_data', json.encode(rawUserJson));
    }

    fetchComplaints();
    fetchMapComplaints();
    fetchMyComplaints();
  }

  void setUsers(List<User> users) {
    _users = users;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _complaints = [];
    _myComplaints = [];
    _mapComplaints = [];
    _users = [];
    _categorias = [];
    _complaintSummary = const {
      'total': 0,
      'pendientes': 0,
      'aprobadas': 0,
    };
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
  }

  void addComplaint(Complaint complaint) {
    _complaints.insert(0, complaint);
    _mapComplaints.insert(0, complaint);
    notifyListeners();
  }

  Future<String?> createComplaint({
    required String titulo,
    required String descripcion,
    required int categoriaId,
    required String direccionReferencial,
    required double latitud,
    required double longitud,
    String? fotoUrl,
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
          if (fotoUrl != null && fotoUrl.isNotEmpty) 'foto_url': fotoUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final nuevaData =
            decoded is Map<String, dynamic> ? decoded['data'] : null;

        if (nuevaData is Map<String, dynamic>) {
          final nueva = Complaint.fromJson(nuevaData);
          _complaints.insert(0, nueva);
          _mapComplaints.insert(0, nueva);
          _myComplaints.insert(0, nueva);
        } else {
          await fetchComplaints();
          await fetchMapComplaints();
          await fetchMyComplaints();
        }

        notifyListeners();
        return null;
      } else if (response.statusCode == 422) {
        final decoded = json.decode(response.body);
        final errors = decoded['errors'];
        if (errors is Map) {
          final firstError = errors.values.first;
          return firstError is List
              ? firstError.first.toString()
              : firstError.toString();
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

  Future<String?> updateComplaintStatus(
    dynamic id,
    String newStatus, {
    String? comment,
  }) async {
    if (_token == null) {
      return 'Debes iniciar sesión para actualizar el estado.';
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/denuncias/$id/estado'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'estado': normalizeStatus(newStatus),
          'comentario': comment,
        }),
      );
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return decoded['message']?.toString() ??
            'No se pudo actualizar el estado.';
      }

      await fetchComplaints();
      await fetchMapComplaints();
      await fetchMyComplaints();
      return null;
    } catch (e) {
      return 'Error de conexión con el servidor: $e';
    }
  }
}
