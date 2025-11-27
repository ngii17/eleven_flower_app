import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _apiService.getHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _apiService.getHistory();
    });
  }

  String formatRupiah(num number) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }

  // Dialog Ulasan
  void _showReviewDialog(int orderId, int productId, String productName) {
    int _rating = 5;
    final TextEditingController _commentController = TextEditingController();
    bool _isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Ulas $productName", style: const TextStyle(fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Beri rating:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setStateDialog(() => _rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: "Tulis pengalamanmu...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
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
                              const SnackBar(content: Text("Ulasan berhasil dikirim!")),
                            );
                          } catch (e) {
                            setStateDialog(() => _isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.toString()}")),
                            );
                          }
                        },
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Kirim"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // WIDGET UNTUK LIST PESANAN
  Widget _buildOrderList(List<dynamic> orders, {required bool isCompletedTab}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompletedTab ? Icons.assignment_turned_in_outlined : Icons.hourglass_empty,
              size: 60, 
              color: Colors.grey[300]
            ),
            const SizedBox(height: 16),
            Text(
              isCompletedTab ? "Belum ada pesanan selesai" : "Tidak ada pesanan dalam proses",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final details = order['details'] as List;
        // Kita hapus variabel totalPrice karena tidak dipakai lagi

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Invoice & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['no_invoice'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompletedTab ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isCompletedTab ? "Selesai" : "Menunggu Konfirmasi",
                        style: TextStyle(
                          color: isCompletedTab ? Colors.green[800] : Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Tanggal: ${order['tanggal_pengiriman']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const Divider(thickness: 1, height: 20),

                // List Produk
                ...details.map((detail) {
                  final product = detail['product'];
                  final productName = product?['name'] ?? 'Produk dihapus';
                  final productId = product?['id'] ?? 0;
                  final qty = detail['qty'];
                  // Harga satuan tetap ditampilkan biar user tau varian apa, tapi total bawah dihapus
                  final price = double.tryParse(detail['harga_satuan']?.toString() ?? '0') ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Icon Gambar
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.local_florist, color: Colors.pink),
                        ),
                        const SizedBox(width: 12),
                        // Detail Nama & Harga Satuan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("$qty x ${formatRupiah(price)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        
                        // TOMBOL ULAS (Hanya muncul di Tab Selesai)
                        if (isCompletedTab)
                          ElevatedButton(
                            onPressed: () => _showReviewDialog(order['id'], productId, productName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 30),
                            ),
                            child: const Text("Ulas", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                      ],
                    ),
                  );
                }).toList(),

                // BAGIAN TOTAL BAYAR SUDAH DIHAPUS DARI SINI
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Ada 2 Tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pesanan Saya"),
          backgroundColor: Colors.pink[100],
          foregroundColor: Colors.pink[900],
          bottom: const TabBar(
            labelColor: Colors.pink,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.pink,
            tabs: [
              Tab(text: "Dalam Proses"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } 

            final allOrders = snapshot.data ?? [];

            // FILTER DATA DISINI
            // 1. Pending: status_pembayaran != 'sudah'
            final pendingOrders = allOrders.where((o) => o['status_pembayaran'] != 'sudah').toList();
            
            // 2. Selesai: status_pembayaran == 'sudah'
            final completedOrders = allOrders.where((o) => o['status_pembayaran'] == 'sudah').toList();

            return TabBarView(
              children: [
                // Tab 1: Dalam Proses (Refreshable)
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildOrderList(pendingOrders, isCompletedTab: false),
                ),

                // Tab 2: Selesai (Refreshable)
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildOrderList(completedOrders, isCompletedTab: true),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}