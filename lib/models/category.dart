class Category {
  final int id;
  final String nama;
  final String description;
  final String? imageUrl; // Field baru untuk menampung URL gambar dari Laravel

  Category({
    required this.id,
    required this.nama,
    this.description = '',
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      // Parsing ID (aman jika API kirim string atau int)
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      
      nama: json['nama'] ?? '',
      
      description: json['description'] ?? '',
      
      // Mengambil 'image_url' dari JSON Laravel (hasil dari $appends)
      // Nilainya bisa null jika admin belum upload foto
      imageUrl: json['image_url'], 
    );
  }
}