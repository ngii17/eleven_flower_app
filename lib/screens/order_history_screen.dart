import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  // Hapus const agar tidak di-cache oleh Flutter saat hot reload
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<dynamic> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getHistory();
      if (mounted) {
        setState(() {
          _allOrders = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // === FUNGSI LAIN TETAP SAMA ===
  Future<void> _deleteOrder(int orderId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Riwayat"),
        content: const Text("Yakin ingin menghapus riwayat pesanan ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() {
          _allOrders.removeWhere((order) => order['id'] == orderId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Riwayat berhasil dihapus")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
      }
    }
  }

  String formatRupiah(dynamic number) {
    double price = double.tryParse(number.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(price);
  }

  void _showReviewDialog(int orderId, int productId, String productName) {
    int _rating = 5;
    final TextEditingController _commentController = TextEditingController();
    bool _isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Ulas $productName",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Beri rating:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setStateDialog(() => _rating = index + 1),
                    )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Tulis pengalamanmu...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE58CB0)),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_commentController.text.trim().isEmpty) return;
                      setStateDialog(() => _isSubmitting = true);
                      try {
                        await _apiService.sendReview(
                          orderId: orderId,
                          productId: productId,
                          rating: _rating,
                          comment: _commentController.text,
                        );
                        if (mounted) Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Terima kasih atas ulasannya!")));
                      } catch (e) {
                        setStateDialog(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal: ${e.toString()}")));
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Kirim", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, {required bool isCompletedTab}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                isCompletedTab
                    ? Icons.assignment_turned_in_outlined
                    : Icons.inventory_2_outlined,
                size: 60,
                color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
                isCompletedTab
                    ? "Belum ada riwayat selesai"
                    : "Tidak ada pesanan berjalan",
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final details = order['details'] as List;
        final totalHarga = order['total_harga'] ?? 0;
        final orderId = order['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Order
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order #$orderId",
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompletedTab
                            ? const Color(0xFFC8E6C9)
                            : const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompletedTab ? "Selesai" : "Proses",
                        style: TextStyle(
                          color: isCompletedTab ? Colors.green[800] : Colors.orange[800],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5),

              // Items
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: details.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (ctx, i) {
                  final detail = details[i];
                  final product = detail['product'];
                  final productName = product?['name'] ?? 'Item dihapus';
                  final productId = product?['id'] ?? 0;
                  final price = detail['harga_satuan'] ?? 0;
                  final imagePath = product?['image'];
                  final imageUrl = imagePath != null
                      ? '${ApiService.baseStorageUrl}$imagePath'
                      : null;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl != null
                              ? Image.network(imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      ))
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.local_florist, color: Colors.pink),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text("Qty: ${detail['quantity'] ?? 1}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(formatRupiah(price),
                                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ),
                        if (isCompletedTab)
                          ElevatedButton(
                            onPressed: () => _showReviewDialog(orderId, productId, productName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE58CB0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text("Ulas",
                                style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 1, thickness: 0.5),

              // Total & Delete
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Tagihan",
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(formatRupiah(totalHarga),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFFE58CB0))),
                      ],
                    ),
                    if (isCompletedTab)
                      IconButton(
                        onPressed: () => _deleteOrder(orderId),
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        tooltip: "Hapus Riwayat",
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final userName = user?.nama ?? "User";
    final userPhotoUrl = user?.profilePhotoUrl;

    final pendingOrders = _allOrders.where((o) => o['status_pembayaran'] != 'sudah').toList();
    final completedOrders = _allOrders.where((o) => o['status_pembayaran'] == 'sudah').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF0D1D8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                        ? Image.network(userPhotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.grey))
                        : const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // JUDUL
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: const Text("Pesanan Saya",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // TAB BAR
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFE58CB0),
              labelColor: const Color(0xFFE58CB0),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.inventory_2, size: 28), child: Text("Dalam Proses", style: TextStyle(fontSize: 12))),
                Tab(icon: Icon(Icons.check_circle_outline, size: 28), child: Text("Selesai", style: TextStyle(fontSize: 12))),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.pink))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      RefreshIndicator(onRefresh: _fetchOrders, color: Colors.pink, child: _buildOrderList(pendingOrders, isCompletedTab: false)),
                      RefreshIndicator(onRefresh: _fetchOrders, color: Colors.pink, child: _buildOrderList(completedOrders, isCompletedTab: true)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}