class Category {
  final int id;
  final String nama;
  final int productsCount;

  Category({required this.id, required this.nama, this.productsCount = 0});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nama: json['nama'],
      productsCount: json['products_count'] ?? 0,
    );
  }
}