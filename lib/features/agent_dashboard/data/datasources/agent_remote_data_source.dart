import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart'; // Pour ServerException

class AgentRemoteDataSource {
  final http.Client client;
  final AuthProvider authProvider;

  AgentRemoteDataSource({required this.client, required this.authProvider});

  Future<void> sendAlert(String message) async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé. Veuillez vous reconnecter.');
    }

    final response = await client.post(
      Uri.parse('$API_ENDPOINT/agent/alert'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 200) {
      // Alerte envoyée avec succès
      return;
    } else if (response.statusCode == 403 || response.statusCode == 401 || response.statusCode == 400) {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Erreur lors de l\'envoi de l\'alerte.');
    } else {
      throw ServerException('Erreur serveur lors de l\'envoi de l\'alerte (${response.statusCode}).');
    }
  }

  Future<List<dynamic>> getMyMissions() async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/missions/my-missions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('Impossible de charger les missions.');
    }
  }

  Future<void> updateMissionStatus(String missionId, String status) async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.put(
      Uri.parse('$API_BASE_URL/missions/$missionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw ServerException('Impossible de mettre à jour la mission.');
    }
  }

  Future<List<dynamic>> getSupervisors() async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/users?role=superviseur'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('Impossible de charger les superviseurs.');
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
}
