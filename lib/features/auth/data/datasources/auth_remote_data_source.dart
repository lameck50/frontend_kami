
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';

// Erreur personnalisée pour la communication avec l'API
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message; // Retourne directement le message
}

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$API_ENDPOINT/auth/login'), // URL corrigée
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 400) {
      // Erreurs d'authentification ou de validation
      throw ServerException(json.decode(response.body)['message'] ?? 'Erreur d\'authentification');
    } else {
      // Autres erreurs serveur
      throw ServerException('Erreur du serveur. Veuillez réessayer plus tard.');
    }
  }
}
