import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/agent_detail_screen.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/widgets/agent_search_delegate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kami_geoloc/core/config/theme_provider.dart';
import '../providers/supervisor_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/missions_screen.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/geofencing_screen.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/screens/leaderboard_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'package:kami_geoloc/core/constants/api_constants.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  final MapController _mapController = MapController();
  late IO.Socket socket;

  // Coordonnées des postes
  static const LatLng _beni = LatLng(0.4911, 29.4731);
  static const LatLng _butembo = LatLng(0.14164, 29.29117);
  static const LatLng _oicha = LatLng(0.69687, 29.52237);

  @override
  void initState() {
    super.initState();
    _initSocket();
    // Listen for geofence alerts
    socket.on('geofenceAlert', (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.blueAccent,
            content: Text('Geofence: L\'agent ${data['agentName']} est ${data['eventType']} de la zone ${data['fenceName']}'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    });
  }

  void _initSocket() {
    // IMPORTANT: Utilisez l'adresse IP de votre machine si vous testez sur un appareil physique.
    // Sur l'émulateur Android, '10.0.2.2' fait référence au localhost de la machine hôte.
    // Sur un appareil réel, remplacez par l'IP locale de votre serveur (ex: '192.168.1.10').
    socket = IO.io(API_BASE_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connecté au serveur de socket');
    });

    socket.on('newAlert', (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange[800],
            content: Text('ALERTE de ${data['agentName']}: ${data['message']}'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    });

    socket.on('positionUpdate', (data) {
      if (mounted) {
        // Mettre à jour la position de l'agent dans le provider
        Provider.of<SupervisorProvider>(context, listen: false)
            .updateAgentPosition(data['agentId'], data);
      }
    });

    socket.onDisconnect((_) => print('Déconnecté du serveur de socket'));
    socket.onError((error) => print('Erreur de socket: $error'));
  }

  @override
  void dispose() {
    socket.dispose(); // Fermer la connexion
    super.dispose();
  }

  void _showPostSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Aller au poste'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                _mapController.move(_beni, 13.0);
                Navigator.of(context).pop();
              },
              child: const Text('Beni'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _mapController.move(_butembo, 13.0);
                Navigator.of(context).pop();
              },
              child: const Text('Butembo'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _mapController.move(_oicha, 13.0);
                Navigator.of(context).pop();
              },
              child: const Text('Oicha'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    // Le provider est maintenant fourni plus haut dans l'arbre (main.dart)
    // On s'assure juste de l'utiliser pour charger les agents au début.
    Provider.of<SupervisorProvider>(context, listen: false).fetchAgents();

    return DefaultTabController(
        length: 5,
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
                    Text(user?['name'] ?? 'Superviseur', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(user?['role'] ?? 'N/A', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.pin_drop_outlined),
                tooltip: 'Chercher un poste',
                onPressed: () => _showPostSelectionDialog(context),
              ),
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
              Consumer<SupervisorProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: AgentSearchDelegate(supervisorProvider: provider),
                      );
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
                Tab(icon: Icon(Icons.list), text: 'Liste'),
                Tab(icon: Icon(Icons.map), text: 'Carte'),
                Tab(icon: Icon(Icons.assignment), text: 'Missions'),
                Tab(icon: Icon(Icons.layers), text: 'Zones'),
                Tab(icon: Icon(Icons.leaderboard), text: 'Classement'),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Consumer<SupervisorProvider>(
                  builder: (context, provider, child) {
                    if (provider.state == ListScreenState.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.state == ListScreenState.error) {
                      return Center(child: Text('Erreur: ${provider.errorMessage}'));
                    }

                    return TabBarView(
                      children: [
                        RefreshIndicator(
                          onRefresh: () => provider.fetchAgents(),
                          child: ListView.builder(
                            itemCount: provider.agents.length,
                            itemBuilder: (context, index) {
                              final agent = provider.agents[index];
                              final isOnline = agent['status'] == 'En poste';
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isOnline ? Colors.green : Colors.grey,
                                  child: Text(agent['name'][0]),
                                ),
                                title: Text(agent['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Poste: ${agent['postName'] ?? 'Non assigné'} - Statut: ${agent['status']}'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AgentDetailScreen(agent: agent),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: const LatLng(0.4911, 29.4731),
                            initialZoom: 11.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: provider.agents.map((agent) {
                                final lat = agent['position']?['lat'];
                                final lng = agent['position']?['lng'];

                                if (lat != null && lng != null) {
                                  return Marker(
                                    width: 120.0,
                                    height: 80.0,
                                    point: LatLng(lat, lng),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AgentDetailScreen(agent: agent),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          const Icon(Icons.location_on, color: Colors.red, size: 35),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              agent['name'],
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              }).where((marker) => marker != null).cast<Marker>().toList(),
                            ),
                          ],
                        ),
                        const MissionsScreen(), // Onglet Missions
                        const GeofencingScreen(), // Onglet Geofencing
                        const LeaderboardScreen(), // Onglet Classement
                      ],
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'KamiGeoloc © 2025',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
