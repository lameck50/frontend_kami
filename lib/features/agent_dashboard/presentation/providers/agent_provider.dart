import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kami_geoloc/features/supervisor_dashboard/domain/entities/message.dart';
import '../../data/datasources/agent_remote_data_source.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum AlertState { initial, sending, sent, error }

class AgentProvider with ChangeNotifier {
  final AuthProvider authProvider;
  late final AgentRemoteDataSource _dataSource;

  AgentProvider({required this.authProvider}) {
    _dataSource = AgentRemoteDataSource(client: http.Client(), authProvider: authProvider);
  }

  AlertState _state = AlertState.initial;
  AlertState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<dynamic> _supervisors = [];
  List<dynamic> get supervisors => _supervisors;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isFetchingSupervisors = false;
  bool get isFetchingSupervisors => _isFetchingSupervisors;

  bool _isFetchingMessages = false;
  bool get isFetchingMessages => _isFetchingMessages;

  String _supervisorsError = '';
  String get supervisorsError => _supervisorsError;

  String _messagesError = '';
  String get messagesError => _messagesError;

  Future<void> sendAlert(String message) async {
    try {
      _state = AlertState.sending;
      notifyListeners();

      await _dataSource.sendAlert(message);

      _state = AlertState.sent;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = AlertState.error;
      notifyListeners();
    }
  }

  void resetState() {
    _state = AlertState.initial;
    _errorMessage = '';
    notifyListeners();
  }

  // --- Missions de l'agent ---
  List<dynamic> _missions = [];
  List<dynamic> get missions => _missions;

  bool _isFetchingMissions = false;
  bool get isFetchingMissions => _isFetchingMissions;

  Future<void> fetchMyMissions() async {
    _isFetchingMissions = true;
    notifyListeners();
    try {
      _missions = await _dataSource.getMyMissions();
    } catch (e) {
      // Gérer l'erreur silencieusement pour ne pas bloquer l'UI principale
      print(e.toString());
    } finally {
      _isFetchingMissions = false;
      notifyListeners();
    }
  }

  Future<void> updateMissionStatus(String missionId, String status) async {
    try {
      await _dataSource.updateMissionStatus(missionId, status);
      // Mettre à jour la mission dans la liste locale
      final index = _missions.indexWhere((m) => m['_id'] == missionId);
      if (index != -1) {
        _missions[index]['status'] = status;
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      // On pourrait vouloir montrer une erreur à l'utilisateur ici
    }
  }

  // --- Chat ---
  Future<void> fetchSupervisors() async {
    _isFetchingSupervisors = true;
    _supervisorsError = '';
    notifyListeners();

    try {
      _supervisors = await _dataSource.getSupervisors();
    } catch (e) {
      _supervisorsError = e.toString();
    } finally {
      _isFetchingSupervisors = false;
      notifyListeners();
    }
  }

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
}
