import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});  // TAMBAH KEY, HAPUS CONST DI CALLER KALAU ADA

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrasi Eleven Flower')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),  // HAPUS CONST
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),  // HAPUS CONST
            ),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),  // HAPUS CONST
              maxLines: 3,
            ),
            TextField(
              controller: _noTeleponController,
              decoration: InputDecoration(labelText: 'No Telepon'),  // HAPUS CONST
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),  // HAPUS CONST
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),  // HAPUS CONST
              obscureText: true,
            ),
            SizedBox(height: 16),  // HAPUS CONST
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading ? CircularProgressIndicator() : Text('Daftar'),  // HAPUS CONST
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),  // HAPUS CONST
              child: Text('Sudah punya akun? Login'),  // HAPUS CONST
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final success = await Provider.of<AuthProvider>(context, listen: false).register(
      nama: _namaController.text,
      alamat: _alamatController.text,
      noTelepon: _noTeleponController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));  // HAPUS CONST
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrasi gagal!')));  // HAPUS CONST
    }
  }
}