import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../supervisor_dashboard/presentation/screens/supervisor_home_screen.dart';
import '../../../agent_dashboard/presentation/screens/agent_home_screen.dart';
import '../../../admin/presentation/screens/admin_home_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      final role = auth.user?['role'];
      if (role == 'superviseur') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupervisorHomeScreen()));
      } else if (role == 'agent') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AgentHomeScreen()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
      } else {
        // Si le rôle est inconnu mais authentifié, on va au login par sécurité
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("KamiGeoloc", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
