import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'pages/landing.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/citizen/list_page.dart';
import 'pages/citizen/map_page.dart';
import 'pages/citizen/my_complaints.dart';
import 'pages/citizen/profile.dart';
import 'pages/citizen/create_page.dart';
import 'pages/admin/dashboard.dart';
import 'pages/admin/complaints_admin.dart';
import 'pages/admin/map_admin.dart';
import 'pages/admin/users.dart';
import 'pages/admin/stats.dart';
import 'pages/admin/reports.dart';
import 'components/admin_layout.dart';
import 'components/nav.dart';

const Color kPrimaryDark = Color(0xFF1B2A56);
const Color kGreyText = Color(0xFF8A93A3);

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Denuncias Ciudadanas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/citizen': (context) => const CitizenMainShell(),
        '/admin': (context) => const AdminMainShell(),
        '/create': (context) => const CreatePage(),
      },
    );
  }
}

class CitizenMainShell extends StatefulWidget {
  const CitizenMainShell({super.key});

  @override
  State<CitizenMainShell> createState() => _CitizenMainShellState();
}

class _CitizenMainShellState extends State<CitizenMainShell> {
  int _currentIndex = 0;
  final _pages = const [
    ListPage(),
    MapPage(),
    MyComplaintsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CitizenNav(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _currentIndex,
        selectedItemColor: kPrimaryDark,
        unselectedItemColor: kGreyText,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Mis Denuncias',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AdminMainShell extends StatefulWidget {
  const AdminMainShell({super.key});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  int _selectedIndex = 0;
  final _adminPages = const [
    DashboardPage(),
    ComplaintsAdminPage(),
    MapAdminPage(),
    UsersPage(),
    StatsPage(),
    ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      child: _adminPages[_selectedIndex],
    );
  }
}
