import 'package:flutter/material.dart';
import 'list_page.dart';
import 'my_complaints.dart';
import 'create_page.dart';
import 'profile.dart';

class CitizenLayout extends StatefulWidget {
  const CitizenLayout({super.key});

  @override
  State<CitizenLayout> createState() => _CitizenLayoutState();
}

class _CitizenLayoutState extends State<CitizenLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ListPage(),
    MyComplaintsPage(),
    CreatePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city_outlined),
            activeIcon: Icon(Icons.location_city),
            label: 'Denuncias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Mis Reclamos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Nueva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
