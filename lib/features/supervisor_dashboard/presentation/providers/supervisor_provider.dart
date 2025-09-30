import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kami_geoloc/features/supervisor_dashboard/domain/entities/message.dart';
import '../../data/datasources/supervisor_remote_data_source.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/geofence.dart';

enum ListScreenState { initial, loading, loaded, error }

class SupervisorProvider with ChangeNotifier {
  final AuthProvider authProvider;
  late final SupervisorRemoteDataSource _dataSource;

  SupervisorProvider({required this.authProvider}) {
    _dataSource = SupervisorRemoteDataSource(client: http.Client(), authProvider: authProvider);
  }

  List<dynamic> _allAgents = []; // Contient toujours tous les agents
  List<dynamic> _filteredAgents = []; // La liste affichée, potentiellement filtrée
  List<dynamic> get agents => _filteredAgents;

  ListScreenState _state = ListScreenState.initial;
  ListScreenState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Geofence> _geofences = [];
  List<Geofence> get geofences => _geofences;

  bool _isFetchingGeofences = false;
  bool get isFetchingGeofences => _isFetchingGeofences;

  String _geofencesError = '';
  String get geofencesError => _geofencesError;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isFetchingMessages = false;
  bool get isFetchingMessages => _isFetchingMessages;

  String _messagesError = '';
  String get messagesError => _messagesError;

  Future<void> fetchAgents() async {
    try {
      _state = ListScreenState.loading;
      notifyListeners();

      _allAgents = await _dataSource.getAgents();
      _filteredAgents = _allAgents; // Au début, on affiche tout

      _state = ListScreenState.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = ListScreenState.error;
      notifyListeners();
    }
  }

  void searchAgents(String query) {
    if (query.isEmpty) {
      _filteredAgents = _allAgents;
    } else {
      _filteredAgents = _allAgents
          .where((agent) =>
              agent['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void updateAgentPosition(String agentId, dynamic newPosition) {
    try {
      // Créez un LatLng à partir des données de position
      final position = {
        'lat': newPosition['latitude'],
        'lng': newPosition['longitude'],
      };

      // Mettre à jour la liste complète
      int allIndex = _allAgents.indexWhere((agent) => agent['id'] == agentId);
      if (allIndex != -1) {
        _allAgents[allIndex]['position'] = position;
      }

      // Mettre à jour la liste filtrée
      int filteredIndex = _filteredAgents.indexWhere((agent) => agent['id'] == agentId);
      if (filteredIndex != -1) {
        _filteredAgents[filteredIndex]['position'] = position;
      }

      if (allIndex != -1 || filteredIndex != -1) {
        notifyListeners();
      }
    } catch (e) {
      print("Erreur lors de la mise à jour de la position de l'agent: $e");
    }
  }

  // --- Historique des positions ---
  List<dynamic> _historyPoints = [];
  List<dynamic> get historyPoints => _historyPoints;

  bool _isFetchingHistory = false;
  bool get isFetchingHistory => _isFetchingHistory;

  String _historyError = '';
  String get historyError => _historyError;

  Future<bool> fetchAgentHistory(String agentId, DateTime date) async {
    final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    _isFetchingHistory = true;
    _historyError = '';
    _historyPoints = [];
    notifyListeners();

    try {
      _historyPoints = await _dataSource.getAgentHistory(agentId, dateString);
      if (_historyPoints.isEmpty) {
        _historyError = 'Aucun historique trouvé pour cette date.';
      }
      return true;
    } catch (e) {
      _historyError = e.toString();
      return false;
    } finally {
      _isFetchingHistory = false;
      notifyListeners();
    }
  }

  // --- Missions ---
  List<dynamic> _missions = [];
  List<dynamic> get missions => _missions;

  bool _isFetchingMissions = false;
  bool get isFetchingMissions => _isFetchingMissions;

  String _missionsError = '';
  String get missionsError => _missionsError;

  Future<void> fetchMissions() async {
    _isFetchingMissions = true;
    _missionsError = '';
    notifyListeners();

    try {
      _missions = await _dataSource.getMissions();
    } catch (e) {
      _missionsError = e.toString();
    } finally {
      _isFetchingMissions = false;
      notifyListeners();
    }
  }

  Future<bool> createMission(String title, String description, String agentId) async {
    try {
      final newMission = await _dataSource.createMission(title, description, agentId);
      _missions.insert(0, newMission); // Ajouter au début de la liste
      notifyListeners();
      return true;
    } catch (e) {
      _missionsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Geofences ---
  Future<void> fetchGeofences() async {
    _isFetchingGeofences = true;
    _geofencesError = '';
    notifyListeners();

    try {
      final data = await _dataSource.getGeofences();
      _geofences = data.map((d) => Geofence.fromJson(d)).toList();
    } catch (e) {
      _geofencesError = e.toString();
    } finally {
      _isFetchingGeofences = false;
      notifyListeners();
    }
  }

  Future<bool> createGeofence(Map<String, dynamic> geofenceData) async {
    try {
      final newGeofence = await _dataSource.createGeofence(geofenceData);
      _geofences.add(Geofence.fromJson(newGeofence));
      notifyListeners();
      return true;
    } catch (e) {
      _geofencesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGeofence(String id) async {
    try {
      await _dataSource.deleteGeofence(id);
      _geofences.removeWhere((g) => g.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _geofencesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Chat ---
  Future<void> fetchMessages(String userId) async {
    _isFetchingMessages = true;
    _messagesError = '';
    notifyListeners();

    try {
      final data = await _dataSource.getMessages(userId);
      _messages = data.map((d) => Message.fromJson(d)).toList();
    } catch (e) {
      _messagesError = e.toString();
    } finally {
      _isFetchingMessages = false;
      notifyListeners();
    }
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  // --- Leaderboard ---
  List<dynamic> _leaderboard = [];
  List<dynamic> get leaderboard => _leaderboard;

  bool _isFetchingLeaderboard = false;
  bool get isFetchingLeaderboard => _isFetchingLeaderboard;

  String _leaderboardError = '';
  String get leaderboardError => _leaderboardError;

  Future<void> fetchLeaderboard() async {
    _isFetchingLeaderboard = true;
    _leaderboardError = '';
    notifyListeners();

    try {
      _leaderboard = await _dataSource.getLeaderboard();
    } catch (e) {
      _leaderboardError = e.toString();
    } finally {
      _isFetchingLeaderboard = false;
      notifyListeners();
    }
  }
}
