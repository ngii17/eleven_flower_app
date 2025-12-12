import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../globals.dart';
import 'login_screen.dart';
import '../theme/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers sesuai field di Screenshot Figma
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Visibility password
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    // Validasi form sebelum kirim ke backend
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        nama: _namaController.text.trim(),
        alamat: _alamatController.text.trim(),
        noTelepon: _teleponController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Sukses register
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Pindah ke Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()), 
      );
    } catch (e) {
      // Error handling provider
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      // 1. BACKGROUND IMAGE (Stack)
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Gunakan gambar pattern yang sama dengan Login
                image: AssetImage('assets/images/flower_pattern.jpg'), 
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
              color: Color(0xFFEAC3C3),
            ),
          ),

          // 2. FORM CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  // TOMBOL BACK
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // LOGO SECTION
                  Image.asset(
                    'assets/images/logo_eleven.png',
                    height: 120, 
                    fit: BoxFit.contain,
                  ),
                  
                  const SizedBox(height: 50),

                  // CARD REGISTER (Pink Box)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8EC), // Pink Muda (Sesuai Figma)
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // JUDUL REGISTER
                          const Center(
                            child: Text(
                              'REGISTER',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // --- INPUT FIELDS ---
                          
                          _buildInputGroup(
                            label: 'Nama:', 
                            controller: _namaController,
                            hint: 'masukkan nama lengkap',
                          ),
                          
                          const SizedBox(height: 16),

                          _buildInputGroup(
                            label: 'Alamat:', 
                            controller: _alamatController,
                            hint: 'masukkan alamat',
                          ),

                          const SizedBox(height: 16),

                          _buildInputGroup(
                            label: 'No Telepon:', 
                            controller: _teleponController,
                            hint: '08xxxxxxx',
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 16),

                          _buildInputGroup(
                            label: 'Email:', 
                            controller: _emailController,
                            hint: 'email@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          _buildInputGroup(
                            label: 'Password:', 
                            controller: _passwordController,
                            hint: '******',
                            isPassword: true,
                          ),

                          const SizedBox(height: 32),

                          // SIGN UP BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE96FA1), // Pink Tua
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25), // Pill Shape
                                ),
                              ),
                              child: isLoading 
                                  ? const SizedBox(
                                      // SAYA KECILKAN JADI 24 BIAR GAK ERROR
                                      height: 24, width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        height: 1.2, // <--- INI SOLUSINYA AGAR TIDAK KEPOTONG
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER
  Widget _buildInputGroup({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        
        // Input Box dengan Shadow
        Container(
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
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.black87),
            validator: (value) => value == null || value.isEmpty ? '$label tidak boleh kosong' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}