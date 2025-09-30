import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/admin_remote_data_source.dart';
import '../../domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminProvider with ChangeNotifier {
  final AuthProvider authProvider;
  late final AdminRemoteDataSource _dataSource;

  AdminProvider({required this.authProvider}) {
    _dataSource = AdminRemoteDataSource(client: http.Client(), authProvider: authProvider);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  List<dynamic> _reportData = [];
  List<dynamic> get reportData => _reportData;

  List<User> _users = [];
  List<User> get users => _users;

  Future<bool> fetchDailyReport(DateTime date) async {
    final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _reportData = await _dataSource.getDailyReport(dateString);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _users = await _dataSource.getUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _dataSource.createUser(userData);
      await fetchUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _dataSource.updateUser(id, userData);
      await fetchUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _dataSource.deleteUser(id);
      _users.removeWhere((user) => user.id == id);
      notifyListeners(); // Notify listeners after removing the user
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchMonthlyReport(int year, int month) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _reportData = await _dataSource.getMonthlyReport(year, month);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
