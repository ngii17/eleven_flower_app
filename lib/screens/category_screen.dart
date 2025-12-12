import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _apiService = ApiService();

  List<Category> categories = [];
  List<Product> suggestedProducts = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final cats = await _apiService.getCategories();
      final sortedCats = cats.toSet().toList()
        ..sort((a, b) => a.nama.compareTo(b.nama));
      final prods = await _apiService.getProducts();

      if (mounted) {
        setState(() {
          categories = sortedCats;
          suggestedProducts = prods;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        debugPrint("Error loading data: $e");
      }
    }
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  void _navigateToCategoryProducts(Category cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredCategoryScreen(category: cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories.where((cat) {
      return cat.nama.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    const double headerHeight = 210.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: headerHeight + 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Kategori",
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.pink))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: filteredCategories.isEmpty
                            ? const Center(child: Text("Kategori tidak ditemukan."))
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredCategories.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.75,
                                ),
                                itemBuilder: (context, index) {
                                  return _buildCategoryItem(filteredCategories[index]);
                                },
                              ),
                      ),
                const SizedBox(height: 30),
                if (!isLoading && suggestedProducts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Saran untuk Anda",
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: suggestedProducts.length > 5 ? 5 : suggestedProducts.length,
                    itemBuilder: (context, index) {
                      return _buildSuggestionItem(suggestedProducts[index]);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: _buildFixedHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            // --- TAMBAHAN 1: Radius pada container gambar utama ---
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            image: DecorationImage(
              image: AssetImage('assets/images/logo_header.jpg'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ]
          ),
          child: Container(
            decoration: BoxDecoration(
              // --- TAMBAHAN 2: Radius pada gradient agar mengikuti bentuk ---
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang,",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Temukan Keindahan\nBunga Impianmu",
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          left: 20,
          right: 20,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Cari bunga atau kategori...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                suffixIcon: Icon(Icons.search, color: Colors.pink),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(Category cat) {
    bool hasImage = cat.imageUrl != null && cat.imageUrl!.isNotEmpty;
    return GestureDetector(
      onTap: () => _navigateToCategoryProducts(cat),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hasImage
                    ? Image.network(
                        cat.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Center(child: Icon(Icons.local_florist, color: Colors.pink, size: 30)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cat.nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? "Bunga segar berkualitas.",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                try {
                  await _apiService.addToCart(product.id, 1);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masuk keranjang!")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBF0), 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                     BoxShadow(
                        color: Colors.pink.withOpacity(0.1), 
                        blurRadius: 4, 
                        offset: const Offset(0,2)
                     ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart, 
                  color: Colors.pink, 
                  size: 20
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FilteredCategoryScreen extends StatefulWidget {
  final Category category;

  const FilteredCategoryScreen({super.key, required this.category});

  @override
  State<FilteredCategoryScreen> createState() => _FilteredCategoryScreenState();
}

class _FilteredCategoryScreenState extends State<FilteredCategoryScreen> {
  final ApiService _apiService = ApiService();
  List<Product> allProducts = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final prods = await _apiService.getProducts(categoryId: widget.category.id);
      if (mounted) {
        setState(() {
          allProducts = prods;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = allProducts.where((p) {
      return p.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    const double headerHeight = 210.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: headerHeight),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.pink))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          widget.category.nama,
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? Center(child: Text("Produk tidak ditemukan", style: TextStyle(color: Colors.grey[600])))
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.68,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  return _buildProductCard(filteredProducts[index]);
                                },
                              ),
                      ),
                    ],
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: _buildFixedHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            // --- TAMBAHAN 3: Radius pada container gambar di screen detail ---
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            image: DecorationImage(
              image: AssetImage('assets/images/logo_header.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            // --- TAMBAHAN 4: Radius pada overlay gelap agar mengikuti bentuk ---
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: const Center(
              child: Text(
                "Koleksi Terbaik",
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          bottom: 5,
          left: 20,
          right: 20,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Cari dalam kategori ini...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                suffixIcon: Icon(Icons.search, color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            "4.8",
                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                           try {
                             await _apiService.addToCart(product.id, 1);
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Berhasil masuk keranjang!"), duration: Duration(seconds: 1)),
                             );
                           } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                           }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6), 
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBF0), 
                            borderRadius: BorderRadius.circular(10), 
                          ),
                          child: const Icon(
                            Icons.shopping_cart, 
                            size: 18, 
                            color: Colors.pink
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}