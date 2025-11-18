import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.imageUrl,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported, size: 80),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            Text(product.category.nama, style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            SizedBox(height: 10),
            Text('Stock tersedia: ${product.stock}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Deskripsi', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(product.description),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fitur Add to Cart menyusul ya! 😄')));
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pink,
                ),
                child: Text('Tambah ke Keranjang', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}