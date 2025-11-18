import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  final ApiService _apiService = ApiService();

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      _user = result['user'];
      notifyListeners();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registrasi
  Future<bool> register({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.register(
        nama: nama,
        alamat: alamat,
        noTelepon: noTelepon,
        email: email,
        password: password,
      );
      _user = result['user'];
      notifyListeners();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
  }
}