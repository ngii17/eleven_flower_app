import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../models/cart.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token; 
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  
  // [PERBAIKAN PENTING DI SINI] 
  // Kita anggap login kalau Token ada (biarpun data user belum ke-load)
  // Ini biar pas buka aplikasi gak mental ke halaman login lagi.
  bool get isLoggedIn => _token != null; 
  
  String? get token => _token; 

  final ApiService _apiService = ApiService();

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      _user = result['user']; 
      _token = result['token']; 
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
      _user = result['user'];
      _token = result['token']; 
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
    _token = null; 
    notifyListeners();
  }

  // --- CART FEATURES ---
  Future<Cart> getCart() async {
    return await _apiService.getCart();
  }

  Future<void> addToCart(int productId, int quantity) async {
    await _apiService.addToCart(productId, quantity);
  }

  Future<void> updateCartItem(int itemId, int quantity) async {
    await _apiService.updateCartItem(itemId, quantity);
  }

  Future<void> removeFromCart(int itemId) async {
    await _apiService.removeFromCart(itemId);
  }

  Future<void> clearCart() async {
    await _apiService.clearCart();
  }

  // --- AUTO LOGIN (Saat Aplikasi Dibuka) ---
  Future<bool> tryAutoLogin() async {
    final storedToken = await _apiService.getToken();
    
    // Kalau tidak ada token tersimpan di HP, berarti belum login
    if (storedToken == null) {
      return false; 
    }
    
    // Kalau ada, kita simpan ke variabel _token
    _token = storedToken;
    
    // Opsional: Di masa depan kamu bisa panggil API Profile disini 
    // biar data _user terisi juga (misal: nama, email).
    // Tapi untuk sekarang, asal _token ada, Checkout sudah bisa jalan.
    
    notifyListeners(); // Kabari main.dart kalau status login berubah
    return true;
  }
}