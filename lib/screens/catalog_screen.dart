import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _apiService = ApiService();
  List<Product> products = [];
  List<Category> categories = [];
  Category? selectedCategory;
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final cats = await _apiService.getCategories();
      final uniqueCats = cats.toSet().toList()..sort((a, b) => a.nama.compareTo(b.nama));

      final prods = await _apiService.getProducts(
        categoryId: selectedCategory?.id == 0 ? null : selectedCategory?.id,
        search: searchQuery.isEmpty ? null : searchQuery,
      );

      if (!mounted) return;

      setState(() {
        categories = [Category(id: 0, nama: 'Semua Kategori'), ...uniqueCats];
        products = prods;
        selectedCategory ??= categories[0];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Bunga'),
        backgroundColor: Colors.pink[50],
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (!auth.isLoggedIn) {
                return IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.grey),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silakan login dulu untuk keranjang!')),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Kategori
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      searchQuery = val;
                      _loadData();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 150,
                  child: DropdownButton<Category>(
                    hint: const Text('Kategori'),
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories.map((cat) {
                      return DropdownMenuItem<Category>(
                        value: cat,
                        child: Text(cat.nama, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedCategory = val);
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Daftar Produk — SUDAH DIKECILIN & DIRAPIHIN!
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_florist, size: 60, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text('Tidak ada produk', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.78,     // kotak lebih kecil
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                                ),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Gambar lebih kecil
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          product.imageUrl,
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 100,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image_not_supported, size: 36),
                                          ),
                                        ),
                                      ),
                                      // Text rapi & kecil
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              product.category.nama,
                                              style: const TextStyle(fontSize: 10, color: Colors.pink),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rp ${product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                                            ),
                                            Text(
                                              'Stock: ${product.stock}',
                                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}