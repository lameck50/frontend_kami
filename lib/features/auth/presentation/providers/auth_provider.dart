import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/auth_remote_data_source.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  final AuthRemoteDataSource authDataSource = AuthRemoteDataSourceImpl(client: http.Client());

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    try {
      final response = await authDataSource.login(email, password);
      _token = response['token'];
      _user = response['user'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    _token = null;
    _user = null;
    notifyListeners();
  }
}
