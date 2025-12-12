// lib/services/api_service.dart — UPDATED (SUPPORT UPLOAD KATEGORI)
import 'dart:convert';
import 'dart:async';
import 'dart:io'; // <--- TAMBAHAN PENTING BUAT FILE
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../globals.dart';

class ApiService {
  // Pastikan IP ini sesuai dengan laptop kamu (ipconfig)
  static const String baseUrl = 'http://10.39.186.132:8000/api';
  static const String baseStorageUrl = 'http://10.39.186.132:8000/storage/';
  static const String tokenKey = 'auth_token';

  // --- ERROR HANDLER CANGGIH ---
  static void showError(String rawError) {
    String msg = 'Terjadi kesalahan';

    if (rawError.contains('<!DOCTYPE') || rawError.contains('<html') || rawError.contains('Whoops')) {
      final title = RegExp(r'<title>(.*?)</title>').firstMatch(rawError)?.group(1);
      final h1 = RegExp(r'<h1[^>]*>(.*?)</h1>').firstMatch(rawError)?.group(1);
      final exception = RegExp(r'<span class="exception_message">(.*?)</span>').firstMatch(rawError)?.group(1);

      if (title?.contains('500') == true) {
        msg = 'Server error (500) - Backend mati atau ada bug';
      } else if (title?.contains('404') == true) {
        msg = 'API tidak ditemukan (404)';
      } else if (h1 != null) {
        msg = h1.trim();
      } else if (exception != null) {
        msg = exception.trim();
      } else {
        msg = 'Server sedang bermasalah atau IP salah';
      }
    } else {
      try {
        final jsonError = jsonDecode(rawError);
        if (jsonError is Map && jsonError['message'] != null) {
          msg = jsonError['message'];
          if (jsonError['errors'] is Map) {
            final firstError = jsonError['errors'].values.first;
            if (firstError is List && firstError.isNotEmpty) {
              msg = firstError[0];
            }
          }
        } else {
          msg = rawError.replaceAll('Exception:', '').trim();
        }
      } catch (_) {
        msg = rawError.replaceAll('Exception:', '').trim();
      }

      if (msg.contains('already been taken') || msg.contains('sudah digunakan')) {
        msg = 'Data sudah terdaftar!';
      } else if (msg.contains('Unauthenticated') || msg.contains('Unauthorized')) {
        msg = 'Sesi habis, silakan login lagi.';
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      snackbarKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () => snackbarKey.currentState?.hideCurrentSnackBar(),
            ),
          ),
        );
    });
  }

  // --- AUTH ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, data['token']);
        return {'user': User.fromJson(data['user']), 'token': data['token']};
      }
      throw Exception(response.body);
    } catch (e) {
      showError(e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String nama,
    required String alamat,
    required String noTelepon,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'alamat': alamat,
          'no_telepon': noTelepon,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) return;
      throw Exception(response.body);
    } catch (e) {
      showError(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
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

  // --- CATEGORIES (NEW: CREATE, UPDATE, DELETE) ---

  Future<List<Category>> getCategories() async {
    // Tambahkan header Accept application/json agar Controller Laravel lari ke logic JSON
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {'Accept': 'application/json'}, 
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return (data as List).map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception(response.body);
    }
  }

  // 1. Create Category dengan Gambar
  Future<void> createCategory(String nama, File image) async {
    final token = await getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/categories'));
    
    // Header khusus Multipart (JANGAN pakai Content-Type: application/json)
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['nama'] = nama;
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  // 2. Update Category (Bisa ganti nama saja, atau ganti gambar juga)
  Future<void> updateCategory(int id, String nama, File? image) async {
    final token = await getToken();
    // Trik Laravel: Pakai POST tapi field _method = PUT agar bisa baca file upload
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/categories/$id'));
    
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['_method'] = 'PUT'; // PENTING!
    request.fields['nama'] = nama;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  // 3. Delete Category
  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }


  // --- PRODUCTS & CART ---

  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    var uri = Uri.parse('$baseUrl/products');
    if (categoryId != null || search != null) {
      uri = uri.replace(queryParameters: {
        if (categoryId != null && categoryId != 0) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'q': search,
      });
    }
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Cart> getCart() async {
    final response = await http.get(Uri.parse('$baseUrl/carts'), headers: await getHeaders());
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return Cart.fromJson(data);
  }

  Future<void> addToCart(int id, int qty) async => await http.post(Uri.parse('$baseUrl/cart-items'), headers: await getHeaders(), body: jsonEncode({'product_id': id, 'quantity': qty}));
  Future<void> updateCartItem(int id, int qty) async => await http.put(Uri.parse('$baseUrl/cart-items/$id'), headers: await getHeaders(), body: jsonEncode({'quantity': qty}));
  Future<void> removeFromCart(int id) async => await http.delete(Uri.parse('$baseUrl/cart-items/$id'), headers: await getHeaders());
  Future<void> clearCart() async => await http.post(Uri.parse('$baseUrl/carts/clear'), headers: await getHeaders());

  Future<Map<String, dynamic>> checkout({
    required String namaPenerima,
    required String noHpPenerima,
    required String alamatPengiriman,
    required String tanggalPengiriman,
    String? catatan,
  }) async {
    final cart = await getCart();
    if (cart.items.isEmpty) throw Exception('Keranjang kosong!');
    final items = cart.items.map((i) => {'product_id': i.productId, 'quantity': i.quantity, 'price': i.price}).toList();
    final payload = {
      'nama_penerima': namaPenerima,
      'no_hp_penerima': noHpPenerima,
      'alamat_pengiriman': alamatPengiriman,
      'tanggal_pengiriman': tanggalPengiriman,
      if (catatan?.isNotEmpty == true) 'ucapan_kartu': catatan!.trim(),
      'items': items,
    };
    final response = await http.post(Uri.parse('$baseUrl/checkout'), headers: await getHeaders(), body: jsonEncode(payload));
    return jsonDecode(response.body);
  }

  // --- HISTORY & REVIEW ---
  Future<List<dynamic>> getHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/orders/history'), headers: await getHeaders());
    final json = jsonDecode(response.body);
    return json['data'] as List<dynamic>;
  }

  Future<void> sendReview({
    required int orderId,
    required int productId,
    required int rating,
    required String comment,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: await getHeaders(),
      body: jsonEncode({'order_id': orderId, 'product_id': productId, 'rating': rating, 'comment': comment}),
    );
  }

  Future<List<dynamic>> getProductReviews(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$productId/reviews'));
    final json = jsonDecode(response.body);
    return (json['data'] as List?) ?? [];
  }

  Future<User> updateProfilePhoto(String path) async {
    final token = await getToken() ?? (throw Exception('Token tidak ada'));
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/photo'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('photo', path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body)['user']);
    throw Exception('Gagal upload foto');
  }
}