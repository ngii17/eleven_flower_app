import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'cart_screen.dart'; // Opsional, jika ingin langsung ke cart

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  int _quantity = 1;
  bool _isAdding = false;
  
  // Variabel untuk menampung ulasan
  late Future<List<dynamic>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    // Load ulasan saat halaman dibuka
    _reviewsFuture = _apiService.getProductReviews(widget.product.id);
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  // Fungsi Tambah ke Keranjang
  Future<void> _addToCart({bool goToCart = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login dulu untuk belanja!')),
      );
      return;
    }

    setState(() => _isAdding = true);
    try {
      await auth.addToCart(widget.product.id, _quantity);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil masuk keranjang!'), backgroundColor: Colors.green),
      );

      if (goToCart) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
      } else {
        Navigator.pop(context);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. BAGIAN SCROLLABLE (Gambar + Info + Ulasan)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER GAMBAR + TOMBOL BACK ---
                  Stack(
                    children: [
                      // Gambar Produk
                      SizedBox(
                        height: 400, // Tinggi gambar diperbesar biar mewah
                        width: double.infinity,
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      
                      // Tombol Back (Overlay)
                      Positioned(
                        top: 40,
                        left: 15,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.5),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- INFO PRODUK ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Harga & Terjual
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatRupiah(widget.product.price),
                              style: const TextStyle(
                                fontSize: 22, 
                                color: Colors.pink, // Warna Pink sesuai gambar
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const Text(
                              "1357 Terjual", // Data dummy sesuai screenshot (atau ambil dari API jika ada)
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Nama Produk
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontFamily: 'Times New Roman', // Sesuai request font sebelumnya
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tag Kategori (Chip Pink)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.pink[100], // Background pink soft
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.product.category.nama,
                            style: TextStyle(color: Colors.pink[800], fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Deskripsi
                        const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          widget.product.description,
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Garis Pemisah Tebal
                  Container(height: 8, color: Colors.grey[100]),

                  // --- ULASAN PEMBELI ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ulasan Pembeli",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        
                        FutureBuilder<List<dynamic>>(
                          future: _reviewsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Colors.pink));
                            }
                            
                            final reviews = snapshot.data ?? [];

                            if (reviews.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text("Belum ada ulasan.", style: TextStyle(color: Colors.grey)),
                              );
                            }

                            // Tampilkan List Ulasan
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              separatorBuilder: (ctx, i) => const Divider(height: 30),
                              itemBuilder: (context, index) {
                                final review = reviews[index];
                                final user = review['user'];
                                final userName = user != null ? user['nama'] : 'Anonim';
                                final rating = review['rating'] ?? 0;
                                final comment = review['comment'] ?? '';
                                final date = review['created_at'] != null 
                                    ? DateFormat('dd MMM yyyy').format(DateTime.parse(review['created_at'])) 
                                    : '-';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.grey[200],
                                          child: Text(userName[0], style: const TextStyle(fontSize: 12, color: Colors.black)),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const Spacer(),
                                        Text(date, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Bintang
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < rating ? Icons.star : Icons.star_border,
                                          color: Colors.amber,
                                          size: 14,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(comment, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 2. BOTTOM BAR (TOMBOL BELI)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                // Tombol Kurang (-)
                _buildQuantityBtn(
                  icon: Icons.remove, 
                  onTap: () { if (_quantity > 1) setState(() => _quantity--); }
                ),
                
                // Angka Quantity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                
                // Tombol Tambah (+)
                _buildQuantityBtn(
                  icon: Icons.add, 
                  onTap: () { if (_quantity < widget.product.stock) setState(() => _quantity++); }
                ),
                
                const SizedBox(width: 20),

                // Ikon Keranjang (Add to Cart only)
                GestureDetector(
                   onTap: (widget.product.stock > 0 && !_isAdding) ? () => _addToCart(goToCart: false) : null,
                   child: Container(
                     padding: const EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.grey.shade300),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
                   ),
                ),

                const SizedBox(width: 10),

                // Tombol BELI SEKARANG (Pink Besar)
                Expanded(
                  child: ElevatedButton(
                    onPressed: (widget.product.stock > 0 && !_isAdding) 
                        ? () => _addToCart(goToCart: true) // Logic Beli Sekarang -> Masuk Cart & Buka Cart
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA86B6), // Warna Pink sesuai SS
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isAdding
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            widget.product.stock > 0 ? "Beli Sekarang" : "Stok Habis",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // Helper untuk tombol quantity bulat
  Widget _buildQuantityBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black54),
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}