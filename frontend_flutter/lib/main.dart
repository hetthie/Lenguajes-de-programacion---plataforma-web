import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_provider.dart';
import 'pages/landing.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/citizen/citizen_layout.dart';
import 'pages/citizen/my_complaints.dart';
import 'pages/citizen/create_page.dart';
import 'pages/citizen/list_page.dart';
import 'pages/citizen/profile.dart';
import 'pages/admin/admin_layout.dart';
import 'pages/admin/dashboard.dart';
import 'pages/admin/complaints_admin.dart';
import 'pages/admin/stats.dart';
import 'pages/admin/users.dart';
import 'pages/admin/reports.dart';

const String supabaseUrl = 'https://ibslislewkgpcrzmqgns.supabase.co';
const String supabasePublishableKey = 'sb_publishable_yBKOP1WUzQA2gpOX4rMpsg_ZSx0Swef';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CiudadResuelve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/citizen': (context) => const CitizenLayout(),
        '/citizen/list': (context) => const ListPage(),
        '/citizen/my_complaints': (context) => const MyComplaintsPage(),
        '/citizen/create': (context) => const CreatePage(),
        '/citizen/profile': (context) => const ProfilePage(),
        '/admin': (context) => const AdminLayout(),
        '/admin/dashboard': (context) => const DashboardPage(),
        '/admin/complaints': (context) => const ComplaintsAdminPage(),
        '/admin/stats': (context) => const StatsPage(),
        '/admin/users': (context) => const UsersPage(),
        '/admin/reports': (context) => const ReportsPage(),
      },
    );
  }
}
