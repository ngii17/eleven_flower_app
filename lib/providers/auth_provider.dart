import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../models/cart.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  final ApiService _apiService = ApiService();

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Panggil API
      final result = await _apiService.login(email, password);
      
      // FIX: Karena ApiService sudah melakukan User.fromJson, 
      // di sini kita tinggal ambil object-nya saja.
      _user = result['user']; 
      
      notifyListeners();
      return true;
    } catch (e) {
      print("Login Error: $e");
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- REGISTRASI ---
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
      
      // Sama seperti login, langsung ambil object user
      _user = result['user'];
      
      notifyListeners();
      return true;
    } catch (e) {
      print("Register Error: $e");
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
  }

  // --- CART FEATURES ---
  
  // Get cart
  Future<Cart> getCart() async {
    return await _apiService.getCart();
  }

  // Add to cart
  Future<void> addToCart(int productId, int quantity) async {
    await _apiService.addToCart(productId, quantity);
    // Tips: Kita tidak perlu notifyListeners di sini 
    // karena CartScreen biasanya me-refresh data (getCart) saat dibuka.
  }

  // Update cart item
  Future<void> updateCartItem(int itemId, int quantity) async {
    await _apiService.updateCartItem(itemId, quantity);
  }

  // Remove from cart
  Future<void> removeFromCart(int itemId) async {
    await _apiService.removeFromCart(itemId);
  }

  // Clear cart
  Future<void> clearCart() async {
    await _apiService.clearCart();
  }
}