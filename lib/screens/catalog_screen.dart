import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
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
    setState(() => isLoading = true);
    try {
      final cats = await _apiService.getCategories();
      final prods = await _apiService.getProducts(
        categoryId: selectedCategory?.id,
        search: searchQuery,
      );
    setState(() {
      categories = [
        Category(id: 0, nama: 'Semua Kategori'),  // Buat objek Category dummy
        ...cats
  ];
  products = prods;
  selectedCategory ??= categories[0];  // Default pilih "Semua Kategori"
});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katalog Bunga'),
        backgroundColor: Colors.pink[50],
      ),
      body: Column(
        children: [
          // Search + Filter
          Padding(
            padding: EdgeInsets.all(12),
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
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<Category>(
                  hint: Text('Kategori'),
                  value: selectedCategory,
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.nama));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedCategory = val);
                    _loadData();
                  },
                ),
              ],
            ),
          ),

          // Loading atau Grid Produk
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: GridView.builder(
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          ),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    product.imageUrl,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        product.category.nama,
                                        style: TextStyle(color: Colors.pink, fontSize: 12),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                                      ),
                                      Text('Stock: ${product.stock}', style: TextStyle(fontSize: 11)),
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