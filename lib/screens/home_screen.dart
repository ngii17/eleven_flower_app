import 'package:flutter/material.dart';
import 'catalog_screen.dart';  // Pastikan import ini ada

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogScreen();  // Langsung buka katalog!
  }
}