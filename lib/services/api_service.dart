import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/product.dart';

class ApiService {
static const String baseUrl = 'http://10.0.2.2:8000/api';
// Tambahin base URL untuk gambar biar aman
static const String baseStorageUrl = 'http://10.0.2.2:8000/storage/';
  static const String tokenKey = 'auth_token';

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, data['token']);  // GUNAKAN prefs DI SINI (FIX UNUSED)
      return {'user': User.fromJson(data['user']), 'token': data['token']};
    }
    throw Exception('Login gagal: ${response.body}');
  }

  // Registrasi
  Future<Map<String, dynamic>> register({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama': nama,
        'alamat': alamat,
        'no_telepon': noTelepon,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, data['token']);  // GUNAKAN prefs (FIX UNUSED)
      return {'user': User.fromJson(data['user']), 'token': data['token']};
    }
    throw Exception('Registrasi gagal: ${response.body}');
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    await prefs.remove(tokenKey);  // GUNAKAN prefs (FIX UNUSED)
  }

  // Get token (async version)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);  // GUNAKAN prefs
  }

  // Helper: Headers dengan token (async, call getToken dulu)
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

    // Ambil semua kategori (untuk dropdown)
  Future<List<Category>> getCategories() async {
  final response = await http.get(Uri.parse('$baseUrl/categories'));
  print('Categories Response: ${response.body}'); // DEBUG

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List data = body['data'] ?? body; // kadang langsung array
    return data.map((json) => Category.fromJson(json)).toList();
  }
  throw Exception('Gagal ambil kategori: ${response.body}');
}

  // Ambil list produk (dengan filter & search)
  // getProducts — tambahin print biar tau response apa
Future<List<Product>> getProducts({int? categoryId, String? search}) async {
  var uri = Uri.parse('$baseUrl/products');
  if (categoryId != null || search != null) {
    uri = uri.replace(queryParameters: {
      if (categoryId != null && categoryId != 0) 'category_id': categoryId.toString(),
      if (search != null && search.isNotEmpty) 'q': search,
    });
  }

  final response = await http.get(uri);
  
  // DEBUG: Liat apa yang dikirim backend
  print('URL: $uri');
  print('Status: ${response.statusCode}');
  print('Response: ${response.body}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List data = body['data'];
    return data.map((json) => Product.fromJson(json)).toList();
  }
  throw Exception('Gagal ambil produk: ${response.body}');
}
}
