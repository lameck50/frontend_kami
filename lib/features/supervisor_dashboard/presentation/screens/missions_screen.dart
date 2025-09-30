import 'package:flutter/material.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/providers/supervisor_provider.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/create_mission_screen.dart';
import 'package:provider/provider.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  void initState() {
    super.initState();
    // Utiliser addPostFrameCallback pour s'assurer que le contexte est disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // On ne recharge les missions que si la liste est vide
      final provider = Provider.of<SupervisorProvider>(context, listen: false);
      if (provider.missions.isEmpty) {
        provider.fetchMissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SupervisorProvider>(
        builder: (context, provider, child) {
          if (provider.isFetchingMissions && provider.missions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.missionsError.isNotEmpty && provider.missions.isEmpty) {
            return Center(
              child: Text("Erreur: ${provider.missionsError}"),
            );
          }

          if (provider.missions.isEmpty) {
            return const Center(
              child: Text("Aucune mission pour le moment."),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMissions(),
            child: ListView.builder(
              itemCount: provider.missions.length,
              itemBuilder: (context, index) {
                final mission = provider.missions[index];
                return ListTile(
                  leading: Icon(_getIconForStatus(mission['status'])),
                  title: Text(mission['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Agent: ${mission['assignedTo']?['name'] ?? 'Non assigné'} - Statut: ${mission['status']}'),
                  onTap: () {
                    // TODO: Naviguer vers le détail de la mission
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMissionScreen()),
          );
        },
        tooltip: 'Créer une mission',
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'En attente':
        return Icons.pending_actions;
      case 'En cours':
        return Icons.directions_run;
      case 'Terminée':
        return Icons.check_circle;
      case 'Annulée':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
