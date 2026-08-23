import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../models/user.dart';
import '../data/mock.dart';

class AppProvider extends ChangeNotifier {
  final List<Complaint> _complaints = List.from(mockComplaints);
  List<User> _users = [];
  User? _currentUser;
  String? _token;

  List<Complaint> get complaints => _complaints;
  List<User> get users => _users;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  void setSession(User user, String token) {
    _currentUser = user;
    _token = token;
    notifyListeners();
  }

  void setUsers(List<User> users) {
    _users = users;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _token = null;
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
