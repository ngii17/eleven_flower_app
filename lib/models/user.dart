class User {
  final int id;
  final String nama;
  final String alamat;
  final String noTelepon;
  final String email;
  final String roles; // 'user' atau 'admin'
  final String? profilePhotoUrl; // [BARU] Tambahan untuk foto profil

  User({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.noTelepon,
    required this.email,
    required this.roles,
    this.profilePhotoUrl, // [BARU]
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // [PENTING] Ganti IP ini sesuai dengan IP Laptop kamu yang ada di api_service.dart
    // Jangan lupa akhiri dengan slash '/'
    const String baseStorageUrl = 'http://172.20.67.132:8000/storage/';

    String? photoUrl;
    if (json['profile_photo_path'] != null) {
      // Gabungkan Base URL Storage dengan path dari database
      photoUrl = "$baseStorageUrl${json['profile_photo_path']}";
    }

    return User(
      id: json['id'],
      // Saya kasih fallback (??) biar aman kalau Laravel kirimnya 'name' atau 'nama'
      nama: json['nama'] ?? json['name'] ?? '', 
      alamat: json['alamat'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      email: json['email'] ?? '',
      roles: json['roles'] ?? 'user',
      profilePhotoUrl: photoUrl, // [BARU] Masukkan URL foto ke object User
    );
  }
}