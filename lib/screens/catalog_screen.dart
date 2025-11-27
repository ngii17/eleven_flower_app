import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart'; // WAJIB ADA

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Helper untuk format rupiah
  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Bunga'),
        backgroundColor: Colors.pink[50],
        foregroundColor: Colors.pink[900],
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return IconButton(
                icon: Icon(
                  Icons.shopping_cart, 
                  color: auth.isLoggedIn ? Colors.pink : Colors.grey
                ),
                onPressed: () {
                  if (!auth.isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Silakan login dulu untuk membuka keranjang!')),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      
      // ===============================================
      // DRAWER (MENU SAMPING)
      // ===============================================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink[100]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 30, 
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Eleven Flower', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink)
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Katalog Produk'),
              onTap: () => Navigator.pop(context),
            ),
            
            // TOMBOL KERANJANG
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (!auth.isLoggedIn) return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: const Text('Keranjang Belanja'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  },
                );
              }
            ),

            // TOMBOL PESANAN SAYA (GANTI NAMA DISINI)
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (!auth.isLoggedIn) return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.purple), // Icon diganti biar fresh
                  title: const Text('Pesanan Saya'), // <-- SUDAH DIGANTI
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
                  },
                );
              }
            ),

            const Divider(),
            
            // TOMBOL LOGIN / LOGOUT
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.isLoggedIn) {
                  return ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await auth.logout();
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.login, color: Colors.green),
                    title: const Text('Login Member', style: TextStyle(color: Colors.green)),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Silakan pilih barang lalu checkout untuk Login/Register")),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),

      // BODY UTAMA
      body: Column(
        children: [
          // Filter: Search + Kategori
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      searchQuery = val;
                      _loadData();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari bunga...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Category>(
                      value: selectedCategory,
                      icon: const Icon(Icons.filter_list, color: Colors.pink),
                      items: categories.map((cat) {
                        return DropdownMenuItem<Category>(
                          value: cat,
                          child: Text(
                            cat.nama, 
                            style: TextStyle(
                              color: cat == selectedCategory ? Colors.pink : Colors.black87,
                              fontWeight: cat == selectedCategory ? FontWeight.bold : FontWeight.normal
                            ),
                            overflow: TextOverflow.ellipsis
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedCategory = val);
                        _loadData();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid Produk
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
                                Icon(Icons.local_florist_outlined, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75, 
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
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
                                  elevation: 2,
                                  shadowColor: Colors.pink.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Gambar Produk
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                          child: Image.network(
                                            product.imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.grey[100],
                                              child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Info Produk
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product.category.nama,
                                              style: TextStyle(fontSize: 11, color: Colors.pink[300]),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  formatRupiah(product.price),
                                                  style: const TextStyle(
                                                    fontSize: 14, 
                                                    fontWeight: FontWeight.bold, 
                                                    color: Colors.green
                                                  ),
                                                ),
                                                Text(
                                                  'Stok: ${product.stock}',
                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                ),
                                              ],
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