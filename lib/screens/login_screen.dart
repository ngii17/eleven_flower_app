import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});  // TAMBAH KEY INI

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Eleven Flower')),  // HAPUS CONST KALAU ADA
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // HAPUS CONST KALAU ADA
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),  // HAPUS CONST KALAU ADA
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),  // HAPUS CONST KALAU ADA
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),  // HAPUS CONST KALAU ADA
              obscureText: true,
            ),
            const SizedBox(height: 16),  // HAPUS CONST KALAU ADA
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),  // HAPUS CONST KALAU ADA
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),  // HAPUS CONST KALAU ADA
              child: const Text('Belum punya akun? Daftar'),  // HAPUS CONST KALAU ADA
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final success = await Provider.of<AuthProvider>(context, listen: false).login(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));  // HAPUS CONST KALAU ADA
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login gagal!')));  // HAPUS CONST KALAU ADA
    }
  }
}