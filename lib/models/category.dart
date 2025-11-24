// models/category.dart
class Category {
  final int id;
  final String nama;

  Category({required this.id, required this.nama});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      nama: json['nama'] as String? ?? 'Unknown',
    );
  }

  // <<< FIX UTAMA: Override == & hashCode biar Set dedup berdasarkan ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => nama;
}