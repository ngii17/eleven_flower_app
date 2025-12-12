import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _apiService = ApiService();

  List<Product> products = [];
  String searchQuery = '';
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Timer Auto Slide Banner
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      int bannerCount = products.length > 5 ? 5 : products.length;

      if (bannerCount > 0 && _pageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % bannerCount;
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final prods = await _apiService.getProducts(
          search: searchQuery.isEmpty ? null : searchQuery);
      if (mounted) setState(() => products = prods);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- FUNGSI ADD TO CART ---
  Future<void> _addToCart(Product p) async {
    try {
      await _apiService.addToCart(p.id, 1);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text("${p.name} berhasil masuk keranjang!")),
            ],
          ),
          backgroundColor: Colors.pinkAccent,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan ke keranjang"), backgroundColor: Colors.red),
      );
    }
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Column(
        children: [
          _buildFixedHeader(), 
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.pinkAccent,
              backgroundColor: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 25),
                  _buildDynamicBannerSlider(),
                  const SizedBox(height: 30),

                  // ================== JUDUL TERLARIS ==================
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Terlaris",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    // "Premium Quality" dihapus dari sini
                  ),
                  const SizedBox(height: 16),

                  // ================== LIST PRODUK ==================
                  isLoading
                      ? const SizedBox(
                          height: 200,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.pink)),
                        )
                      : products.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(50),
                              child: Center(
                                child: Text(
                                  "Produk tidak ditemukan",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: products.length,
                              itemBuilder: (context, i) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 20),
                                child:
                                    _buildProductCard(products[i]),
                              ),
                            ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER BARU ====================
  Widget _buildFixedHeader() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Container(
            height: 175,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo_header.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            // Overlay Gradient agar tulisan terbaca
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3), // Sedikit lebih gelap di atas
                    Colors.black.withOpacity(0.6)
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30)),
              ),
            ),
          ),

          // --- PENGGANTI LOGO PROFIL (Teks Sambutan) ---
          Positioned(
            top: 50, // Posisi teks di area atas
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Selamat Datang",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text("👋", style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "Temukan Bunga\nImpianmu Disini 🌸",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2, // Jarak antar baris
                  ),
                ),
              ],
            ),
          ),

          // Kolom Pencarian
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5F6C).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  searchQuery = val.trim();
                  _loadData();
                },
                decoration: InputDecoration(
                  hintText: 'Cari bunga favoritmu...',
                  hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.pink[300]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            searchQuery = '';
                            _loadData();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BANNER SLIDER ====================
  Widget _buildDynamicBannerSlider() {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 180,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: const Center(
            child:
                CircularProgressIndicator(color: Colors.pinkAccent)),
      );
    }
    if (products.isEmpty) return const SizedBox.shrink();

    final bannerProducts = products.take(5).toList();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) =>
                setState(() => _currentBannerIndex = i),
            itemCount: bannerProducts.length,
            itemBuilder: (_, index) {
              final product = bannerProducts[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(product: product))),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 140,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(20))
                        ),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.horizontal(
                                  left: Radius.circular(20)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[100],
                                  child: Icon(Icons.broken_image_rounded,
                                      color: Colors.grey[300]),
                                ),
                              ),
                              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.black.withOpacity(0.05)])))
                            ]
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "FEATURED",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[400],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF333333)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.description,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF80AB),
                                          Color(0xFFFF4081)
                                        ]),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        formatRupiah(
                                            product.price),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerProducts.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentBannerIndex == i ? 24 : 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == i
                    ? Colors.pinkAccent
                    : Colors.pink[100],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        )
      ],
    );
  }

  // ==================== CARD PRODUK ====================
  Widget _buildProductCard(Product p) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: p))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC0A0B0).withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 10),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  p.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[100],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text("Harga",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400])),
                          Text(
                            formatRupiah(p.price),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.pinkAccent,
                            ),
                          ),
                        ],
                      ),

                      // Tombol Keranjang
                      InkWell(
                        onTap: () => _addToCart(p),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEF2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.pinkAccent.withOpacity(0.2)),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_rounded,
                            color: Colors.pink,
                            size: 20,
                          ),
                        ),
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
  }
}