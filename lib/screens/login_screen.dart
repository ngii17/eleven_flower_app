import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../globals.dart'; // Untuk snackbarKey
import 'register_screen.dart';
import 'catalog_screen.dart';
import '../theme/theme.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- LOGIC TETAP SAMA ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi sederhana
    if (email.isEmpty || password.isEmpty) {
      snackbarKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Email dan Password harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Panggil Provider untuk login
      await Provider.of<AuthProvider>(context, listen: false).login(email, password);
      
      if (!mounted) return;
      // Jika sukses, pindah ke Catalog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()), // <--- Ini Benar (Buka Navigasi Utama)
        );
    } catch (e) {
      // Error handling sudah ada di Provider/ApiService
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      // Menggunakan Stack untuk Background Image full screen
      body: Stack(
        children: [
          // 1. BACKGROUND PATTERN (Bunga-bunga pink)
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Pastikan file 'flower_pattern.jpg' ada di assets/images/
                image: AssetImage('assets/images/flower_pattern.jpg'), 
                fit: BoxFit.cover,
                opacity: 0.6, 
              ),
              color: Color(0xFFEAC3C3), 
            ),
          ),

          // 2. CONTENT (Scrollable agar aman di HP kecil)
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // LOGO & JUDUL
                    Image.asset(
                      'assets/images/logo_eleven.png', 
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    // const Text(
                    //   'Eleven',
                    //   style: TextStyle(
                    //     fontFamily: 'Times New Roman', 
                    //     fontSize: 40,
                    //     color: Colors.black,
                    //     height: 1.0,
                    //   ),
                    // ),
                    // const Text(
                    //   'FLORIST',
                    //   style: TextStyle(
                    //     fontFamily: 'Poppins',
                    //     fontSize: 14,
                    //     letterSpacing: 4,
                    //     fontWeight: FontWeight.w500,
                    //     color: Colors.black54,
                    //   ),
                    // ),

                    const SizedBox(height: 40),

                    // CARD LOGIN (Kotak Pink Muda)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8EC), // Warna Pink Sangat Muda
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // JUDUL LOGIN
                          const Center(
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900, 
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // EMAIL LABEL & INPUT
                          _buildLabel('Email:'),
                          const SizedBox(height: 8),
                          _buildShadowInput(
                            controller: _emailController,
                            hint: '', 
                          ),

                          const SizedBox(height: 16),

                          // PASSWORD LABEL & INPUT
                          _buildLabel('Password:'),
                          const SizedBox(height: 8),
                          _buildShadowInput(
                            controller: _passwordController,
                            isPassword: true,
                            hint: '',
                          ),

                          const SizedBox(height: 20),

                          // REGISTER LINK
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Belum punya akun, kak? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  // PERBAIKAN: Hapus 'const' di sini
                                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                                ),
                                child: const Text(
                                  'REGISTER',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF7986CB), 
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // BUTTON LOGIN
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE96FA1), 
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25), 
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24, 
                                      width: 24, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        height: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER: Label Teks
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // WIDGET HELPER: Input Field dengan Shadow khusus
  Widget _buildShadowInput({
    required TextEditingController controller,
    bool isPassword = false,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // Abu-abu muda
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), 
            blurRadius: 4,
            offset: const Offset(0, 3), 
          ),
        ],
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }
}