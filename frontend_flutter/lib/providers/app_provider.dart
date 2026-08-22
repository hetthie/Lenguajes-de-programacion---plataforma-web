import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../models/user.dart';
import '../data/mock.dart';

class AppProvider extends ChangeNotifier {
  final List<Complaint> _complaints = List.from(mockComplaints);
  final List<User> _users = List.from(mockUsers);
  User? _currentUser = mockUsers[0]; // Usuario activo por defecto

  List<Complaint> get complaints => _complaints;
  List<User> get users => _users;
  User? get currentUser => _currentUser;

  void login(String email, String role) {
    _currentUser = User(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@')[0],
      email: email,
      role: role,
      status: 'Activo',
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addComplaint(Complaint complaint) {
    _complaints.insert(0, complaint);
    notifyListeners();
  }

  void updateComplaintStatus(String id, String newStatus) {
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _complaints[index];
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
