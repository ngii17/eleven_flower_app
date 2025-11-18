import 'category.dart';

class Product {
  final int id;
  final String name;
  final Category category;
  final String description;
  final double price;
  final int stock;
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: Category.fromJson(json['category']),
      description: json['description'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      image: json['image'],
    );
  }

  String get imageUrl => image != null
      ? 'http://10.0.2.2:8000/storage/$image'  // Android emulator
      : 'https://via.placeholder.com/300x300.png?text=No+Image';
}