import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kami_geoloc/features/admin/presentation/providers/admin_provider.dart';
import 'package:kami_geoloc/features/admin/presentation/screens/report_display_screen.dart';
import 'package:kami_geoloc/features/admin/presentation/screens/user_management_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _generateDailyReport(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && context.mounted) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final success = await provider.fetchDailyReport(picked);

      if (context.mounted) {
        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDisplayScreen(
                reportData: provider.reportData,
                date: picked,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error.isNotEmpty ? provider.error : "Erreur inconnue."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _generateMonthlyReport(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && context.mounted) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final success = await provider.fetchMonthlyReport(picked.year, picked.month);

      if (context.mounted) {
        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDisplayScreen(
                reportData: provider.reportData,
                date: picked,
                isMonthlyReport: true,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error.isNotEmpty ? provider.error : "Erreur inconnue."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panneau Administrateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 5,
                  ),
                  const SizedBox(width: 8),
                  Text('Bienvenue, ${user?['name'] ?? 'Admin'}!', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              Text('Rôle: ${user?['role'] ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 40),
              Consumer<AdminProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.bar_chart),
                              label: const Text('Générer un rapport journalier'),
                              onPressed: () => _generateDailyReport(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Générer un rapport mensuel'),
                              onPressed: () => _generateMonthlyReport(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Gérer les utilisateurs'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
