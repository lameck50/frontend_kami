import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart'; // Pour ServerException

class SupervisorRemoteDataSource {
  final http.Client client;
  final AuthProvider authProvider;

  SupervisorRemoteDataSource({required this.client, required this.authProvider});

  Future<List<dynamic>> getAgents() async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé. Veuillez vous reconnecter.');
    }

    final response = await client.get(
      Uri.parse('$API_ENDPOINT/agents'), // URL corrigée
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Accès non autorisé.');
    } else {
      throw ServerException('Impossible de charger les agents (Erreur serveur: ${response.statusCode})');
    }
  }

  Future<List<dynamic>> getAgentHistory(String agentId, String date) async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé. Veuillez vous reconnecter.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/agents/$agentId/history?date=$date'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de charger l\'historique.');
    }
  }

  Future<List<dynamic>> getMissions() async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/missions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de charger les missions.');
    }
  }

  Future<Map<String, dynamic>> createMission(String title, String description, String agentId) async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé.');
    }

    final response = await client.post(
      Uri.parse('$API_BASE_URL/missions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'assignedTo': agentId,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de créer la mission.');
    }
  }

  Future<List<dynamic>> getGeofences() async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/geofences'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('Impossible de charger les zones de geofencing.');
    }
  }

  Future<Map<String, dynamic>> createGeofence(Map<String, dynamic> geofenceData) async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé.');
    }

    final response = await client.post(
      Uri.parse('$API_BASE_URL/geofences'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(geofenceData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ServerException('Impossible de créer la zone de geofencing.');
    }
  }

  Future<void> deleteGeofence(String id) async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé.');
    }

    final response = await client.delete(
      Uri.parse('$API_BASE_URL/geofences/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw ServerException('Impossible de supprimer la zone de geofencing.');
    }
  }

  Future<List<dynamic>> getMessages(String userId) async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/messages/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('Impossible de charger les messages.');
    }
  }

  Future<List<dynamic>> getLeaderboard() async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/leaderboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('Impossible de charger le classement.');
    }
  }
}
