import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart'; // Untuk navigasi logout
import '../theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- LOGIC BAWAAN (JANGAN DIHAPUS) ---
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _retrieveLostData();
    }
  }

  Future<void> _retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.file != null) {
        _handleUpload(response.file!.path);
      }
    } catch (e) {
      print("Error retrieve lost data: $e");
    }
  }

  Future<void> _handleUpload(String path) async {
    final success = await Provider.of<AuthProvider>(context, listen: false).updatePhoto(path);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Foto profil berhasil diperbarui!" : "Gagal upload foto.")),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) await _handleUpload(image.path);
    } catch (e) {
      print("Error pick image: $e");
    }
  }

  // Fungsi Logout
  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    if (user == null) return const Scaffold(body: Center(child: Text("User not found")));

    return Scaffold(
      // Background Pink Sangat Muda (Sesuai Screenshot)
      backgroundColor: const Color(0xFFFFF5F7), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BAGIAN HEADER (BANNER + FOTO) ---
            Stack(
              clipBehavior: Clip.none, // Agar logo bisa "keluar" dari banner
              alignment: Alignment.bottomCenter,
              children: [
                // 1. BANNER BUNGA
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // Pastikan kamu punya gambar ini, atau ganti dengan warna solid sementara
                      image: AssetImage('assets/images/logo_header.jpg'), 
                      // image: NetworkImage('https://images.unsplash.com/photo-1563245372-f21724e3856d?q=80&w=2000&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // 2. LOGO / FOTO PROFIL (Lingkaran)
                Positioned(
                  bottom: -40, // Membuatnya menonjol keluar ke bawah
                  child: GestureDetector(
                    onTap: auth.isLoading ? null : _pickImage, // Bisa diklik untuk ganti foto
                    child: Container(
                      padding: const EdgeInsets.all(4), // Border putih tipis
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFFFF0F5),
                        // Logika: Jika user punya foto, tampilkan. Jika tidak, pakai Logo Eleven.
                        backgroundImage: (user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty)
                            ? NetworkImage(user.profilePhotoUrl!)
                            : const AssetImage('assets/images/logo_eleven.png') as ImageProvider,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50), // Spasi agar tidak ketabrak logo
            const SizedBox(height: 10),
            
            const SizedBox(height: 20),

            // --- LIST DATA USER (FORM FIELD STYLE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem("NAMA:", user.nama, Icons.person_outline),
                  _buildProfileItem("NOMOR TELEPON:", user.noTelepon, Icons.phone_outlined),
                  _buildProfileItem("ALAMAT:", user.alamat, Icons.location_on_outlined),
                  _buildProfileItem("EMAIL:", user.email, Icons.mail_outline),
                  
                  const SizedBox(height: 30),

                  // --- LOGOUT BUTTON ---
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCDD2), // Pink agak merah (Sesuai SS)
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, color: Colors.redAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER: Membuat Item Profil seperti di Screenshot
  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Label (Misal: NAMA:)
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900, // Bold tebal
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          
          // 2. Kotak Isi (Pink Box)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8EC), // Warna Pink Input (Sesuai SS)
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value.isEmpty ? "-" : value,
                    style: const TextStyle(
                      fontFamily: 'Times New Roman', // Font isinya Serif (sesuai SS)
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}