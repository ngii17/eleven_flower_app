class User {
  final int id;
  final String nama;
  final String alamat;
  final String noTelepon;
  final String email;
  final String roles;  // 'user' atau 'admin'

  User({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.noTelepon,
    required this.email,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      alamat: json['alamat'],
      noTelepon: json['no_telepon'],
      email: json['email'],
      roles: json['roles'],
    );
  }
}