import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});  // TAMBAH KEY

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eleven Flower'),  // HAPUS CONST KALAU ADA
        actions: [
          IconButton(
            icon: Icon(Icons.logout),  // HAPUS CONST KALAU ADA
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Center(
        child: Text('Selamat datang, ${Provider.of<AuthProvider>(context).user?.nama}! Katalog produk nanti di sini.'),  // HAPUS CONST KALAU ADA
      ),
    );
  }
}