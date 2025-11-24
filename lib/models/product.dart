// models/product.dart
import 'category.dart';
import '../services/api_service.dart';

class Product {
  final int id;
  final String name;
  final Category category;
  final String description;
  final double price;
  final int stock;
  final String imageUrl; // Langsung full URL, pasti String (ada fallback)

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Ambil image_url dari backend (yang sudah kita kirim full URL)
    String imgUrl = 'https://via.placeholder.com/300x300.png?text=No+Image';

    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      imgUrl = json['image_url'].toString();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      // Kalau backend cuma kasih path, tambahin base storage
      imgUrl = '${ApiService.baseStorageUrl}${json['image']}';
    }

    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: Category.fromJson(
        json['category'] is Map<String, dynamic>
            ? json['category']
            : {'id': 0, 'nama': 'Uncategorized'},
      ),
      description: (json['description'] ?? 'Tidak ada deskripsi') as String,
      price: double.parse(json['price'].toString()),
      stock: json['stock'] as int,
      imageUrl: imgUrl, // Selalu String, tidak pernah null
    );
  }
}