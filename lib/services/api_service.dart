import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; 
import '../models/category.dart';
import '../models/product.dart';
import '../models/cart.dart';

class ApiService {
  static const String baseUrl = 'http://172.20.67.132:8000/api';
  static const String baseStorageUrl = 'http://172.20.67.132:8000/storage/';
  static const String tokenKey = 'auth_token';

  // ================== AUTH ==================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, data['token']);
      return {'user': User.fromJson(data['user']), 'token': data['token']};
    }
    throw Exception('Login gagal: ${response.body}');
  }

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
      await prefs.setString(tokenKey, data['token']);
      return {'user': User.fromJson(data['user']), 'token': data['token']};
    }
    throw Exception('Registrasi gagal: ${response.body}');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    if (token != null) {
      try {
        await http.post(Uri.parse('$baseUrl/logout'), headers: {'Authorization': 'Bearer $token'});
      } catch (_) {}
    }
    await prefs.remove(tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ================== KATEGORI & PRODUK ==================
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? body;
      return data.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception('Gagal ambil kategori');
  }

  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    var uri = Uri.parse('$baseUrl/products');
    if (categoryId != null || search != null) {
      uri = uri.replace(queryParameters: {
        if (categoryId != null && categoryId != 0) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'q': search,
      });
    }

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? body;
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Gagal ambil produk');
  }

  // ================== CART – SUDAH 100% FIX & AMAN ==================
  Future<Cart> getCart() async {
    final headers = await getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/carts'), headers: headers);

    if (response.statusCode == 200) {
      final rawData = jsonDecode(response.body);
      final cartData = rawData is Map<String, dynamic> && rawData.containsKey('data')
          ? rawData['data']
          : rawData;

      return Cart.fromJson(cartData as Map<String, dynamic>);
    }

    throw Exception('Gagal mengambil keranjang. Silakan login ulang.');
  }

  Future<void> addToCart(int productId, int quantity) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/cart-items'),
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal tambah ke keranjang');
    }
  }

  Future<void> updateCartItem(int itemId, int quantity) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/cart-items/$itemId'),
      headers: headers,
      body: jsonEncode({'quantity': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal update jumlah barang');
    }
  }

  Future<void> removeFromCart(int itemId) async {
    final headers = await getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/cart-items/$itemId'), headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus item');
    }
  }

  Future<void> clearCart() async {
    final headers = await getHeaders();
    final response = await http.post(Uri.parse('$baseUrl/carts/clear'), headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Gagal mengosongkan keranjang');
    }
  }

  // ================== CHECKOUT – FINAL & PASTI JALAN 100% ==================
  Future<Map<String, dynamic>> checkout({
    required String namaPenerima,
    required String noHpPenerima,
    required String alamatPengiriman,
    required String tanggalPengiriman,
    String? catatan,
  }) async {
    final headers = await getHeaders();
    final cart = await getCart();

    if (cart.items.isEmpty) {
      throw Exception("Keranjang kosong! Silakan tambah produk terlebih dahulu.");
    }

    final items = cart.items.map((item) {
      return {
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
      };
    }).toList();

    final payload = {
      'nama_penerima': namaPenerima,
      'no_hp_penerima': noHpPenerima,
      'alamat_pengiriman': alamatPengiriman,
      'tanggal_pengiriman': tanggalPengiriman,
      if (catatan != null && catatan.trim().isNotEmpty) 'ucapan_kartu': catatan.trim(),
      'items': items,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Gagal checkout';
      throw Exception(message);
    }
  }

  // ================== HISTORY & REVIEW (FITUR BARU) ==================

  // 1. Ambil Riwayat Pesanan
  Future<List<dynamic>> getHistory() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']; 
    }
    
    throw Exception('Gagal mengambil riwayat pesanan');
  }

  // 2. Kirim Ulasan Produk
  Future<void> sendReview({
    required int orderId,
    required int productId,
    required int rating,
    required String comment,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: headers,
      body: jsonEncode({
        'order_id': orderId,
        'product_id': productId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal mengirim ulasan');
    }
  }

  // 3. Ambil List Ulasan per Produk (Public - Untuk Product Detail)
  Future<List<dynamic>> getProductReviews(int productId) async {
    // Tidak perlu header auth karena ini public route
    final response = await http.get(Uri.parse('$baseUrl/products/$productId/reviews'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];
    }
    // Jika kosong atau error, kembalikan list kosong saja biar aman
    return [];
  }
}