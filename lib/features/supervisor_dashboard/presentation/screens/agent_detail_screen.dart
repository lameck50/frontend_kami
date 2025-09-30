import 'package:flutter/material.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/providers/supervisor_provider.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/chat_screen.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/history_map_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AgentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> agent;

  const AgentDetailScreen({super.key, required this.agent});

  Future<void> _selectDateAndFetchHistory(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && context.mounted) {
      final provider = Provider.of<SupervisorProvider>(context, listen: false);
      final success = await provider.fetchAgentHistory(agent['id'], picked);

      if (context.mounted) {
        if (success && provider.historyPoints.isNotEmpty) {
          final List<LatLng> points = provider.historyPoints.map((p) {
            return LatLng(p['latitude'], p['longitude']);
          }).toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryMapScreen(points: points, agentName: agent['name']),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.historyError.isNotEmpty
                  ? provider.historyError
                  : "Aucune donnée pour cette date."),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(agent['name'] ?? "Détail de l'agent"),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(agentId: agent['id'], agentName: agent['name']),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${agent['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Poste: ${agent['postName'] ?? 'Non assigné'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Statut: ${agent['status']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Position: ${agent['position']?['lat']}, ${agent['position']?['lng']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            Consumer<SupervisorProvider>(
              builder: (context, provider, child) {
                return provider.isFetchingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.timeline),
                          label: const Text("Voir l'historique des trajets"),
                          onPressed: () => _selectDateAndFetchHistory(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    ));
  }
}
