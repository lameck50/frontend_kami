import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';

class AdminRemoteDataSource {
  final http.Client client;
  final AuthProvider authProvider;

  AdminRemoteDataSource({required this.client, required this.authProvider});

  Future<List<dynamic>> getDailyReport(String date) async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_ENDPOINT/reports/daily?date=$date'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de charger le rapport.');
    }
  }

  Future<List<User>> getUsers() async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de charger les utilisateurs.');
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.post(
      Uri.parse('$API_BASE_URL/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de créer l\'utilisateur.');
    }
  }

  Future<User> updateUser(String id, Map<String, dynamic> userData) async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.put(
      Uri.parse('$API_BASE_URL/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de mettre à jour l\'utilisateur.');
    }
  }

  Future<void> deleteUser(String id) async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.delete(
      Uri.parse('$API_BASE_URL/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de supprimer l\'utilisateur.');
    }
  }

  Future<List<dynamic>> getMonthlyReport(int year, int month) async {
    final token = authProvider.token;
    if (token == null) {
      throw ServerException('Token non trouvé.');
    }

    final response = await client.get(
      Uri.parse('$API_BASE_URL/reports/monthly?year=$year&month=$month'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw ServerException(body['message'] ?? 'Impossible de charger le rapport mensuel.');
    }
  }
}
