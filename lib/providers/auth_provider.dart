// lib/providers/auth_provider.dart — FINAL & TIDAK MUTER-MUTER LAGI!
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/cart.dart'; // WAJIB IMPORT!

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;
  String? get token => _token;

  final ApiService _apiService = ApiService();

  // LOGIN — TIDAK MUTER-MUTER LAGI!
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      _user = result['user'];
      _token = result['token'];
    } catch (e) {
      // Error sudah ditampilkan oleh ApiService.showError()
      // Kita diam saja, biar loading berhenti
    } finally {
      _isLoading = false; // PASTI BERHENTI!
      notifyListeners();
    }
  }

  // REGISTER — TIDAK MUTER-MUTER LAGI!
  Future<void> register({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.register(
        nama: nama,
        alamat: alamat,
        noTelepon: noTelepon,
        email: email,
        password: password,
      );
    } catch (e) {
      // Error sudah ditampilkan global
    } finally {
      _isLoading = false; // PASTI BERHENTI!
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _token = null;
    notifyListeners();
  }

  // CART
  Future<Cart> getCart() async => await _apiService.getCart();
  Future<void> addToCart(int id, int qty) async => await _apiService.addToCart(id, qty);
  Future<void> updateCartItem(int id, int qty) async => await _apiService.updateCartItem(id, qty);
  Future<void> removeFromCart(int id) async => await _apiService.removeFromCart(id);
  Future<void> clearCart() async => await _apiService.clearCart();

  Future<bool> tryAutoLogin() async {
    final token = await _apiService.getToken();
    if (token == null) return false;
    _token = token;
    notifyListeners();
    return true;
  }

  Future<bool> updatePhoto(String path) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _apiService.updateProfilePhoto(path);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}