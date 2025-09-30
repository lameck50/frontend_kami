import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kami_geoloc/core/config/theme_provider.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/chat_screen.dart';
import '../providers/agent_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final _alertMessageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AgentProvider>(context, listen: false);
      provider.fetchMyMissions();
      provider.fetchSupervisors();
    });
  }

  @override
  void dispose() {
    _alertMessageController.dispose();
    super.dispose();
  }

  void _sendAlert() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    await agentProvider.sendAlert(_alertMessageController.text);

    if (mounted) {
      if (agentProvider.state == AlertState.sent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerte envoyée avec succès !')),
        );
        _alertMessageController.clear();
        agentProvider.resetState();
      } else if (agentProvider.state == AlertState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Erreur: ${agentProvider.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                radius: 5,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.watch<AuthProvider>().user?['name'] ?? 'Agent', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(context.watch<AuthProvider>().user?['role'] ?? 'N/A', style: const TextStyle(fontSize: 12)),
                  Text('Points: ${context.watch<AuthProvider>().user?['points'] ?? 0}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: 'Changer de thème',
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
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
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.warning), text: 'Alerte'),
              Tab(icon: Icon(Icons.assignment), text: 'Missions'),
              Tab(icon: Icon(Icons.chat), text: 'Chat'),
            ],
          ),
        ),
        body: Consumer<AgentProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                // --- Formulaire d'alerte ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Envoyer une Alerte',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _alertMessageController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Message d\'alerte',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un message.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            provider.state == AlertState.sending
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _sendAlert,
                                    child: const Text('ENVOYER'),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Liste des missions ---
                provider.isFetchingMissions
                    ? const Center(child: CircularProgressIndicator())
                    : provider.missions.isEmpty
                        ? const Center(child: Text('Aucune mission assignée.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: provider.missions.length,
                            itemBuilder: (context, index) {
                              final mission = provider.missions[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(mission['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(mission['description'] ?? 'Pas de description.'),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Chip(label: Text(mission['status'])),
                                          if (mission['status'] == 'En attente')
                                            TextButton(onPressed: () => provider.updateMissionStatus(mission['_id'], 'En cours'), child: const Text('Accepter')),
                                          if (mission['status'] == 'En cours')
                                            TextButton(onPressed: () => provider.updateMissionStatus(mission['_id'], 'Terminée'), child: const Text('Terminer')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                // --- Liste des superviseurs pour le chat ---
                provider.isFetchingSupervisors
                    ? const Center(child: CircularProgressIndicator())
                    : provider.supervisors.isEmpty
                        ? const Center(child: Text('Aucun superviseur trouvé.'))
                        : ListView.builder(
                            itemCount: provider.supervisors.length,
                            itemBuilder: (context, index) {
                              final supervisor = provider.supervisors[index];
                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(supervisor['name']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(agentId: supervisor['_id'], agentName: supervisor['name']),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ],
            );
          },
        ),
      ),
    );
  }
}
