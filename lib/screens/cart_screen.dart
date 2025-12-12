import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';
import 'main_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with RouteAware {
  bool isLoading = true;
  Cart? cart;
  bool isAllSelected = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      RouteObserver<PageRoute>().subscribe(this, route);
    }
    _loadCart();
  }

  @override
  void didPopNext() {
    _loadCart();
  }

  @override
  void dispose() {
    RouteObserver<PageRoute>().unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      cart = await Provider.of<AuthProvider>(context, listen: false).getCart();
    } catch (e) {
      debugPrint("Error load cart: $e");
    }
    if (mounted) setState(() => isLoading = false);
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(price);
  }

  // --- PERBAIKAN DI SINI ---
  // Fungsi ini sekarang memaksa aplikasi kembali ke MainScreen (Home)
  void _goToHome() {
    // Jika halaman ini di-push (ada tombol back), kita pop.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Jika tidak bisa pop (misal dari tab), kita refresh ke MainScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }
  // -------------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF5F7),
        appBar: AppBar(
          title: const Text('Keranjang Belanja',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFE6CACE),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    // KERANJANG KOSONG
    if (cart == null || cart!.items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF5F7),
          elevation: 0,
          // Tombol Back di pojok kiri atas
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _goToHome, 
          ),
          title: const Text('Keranjang Belanja', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 100, color: Colors.pink[200]),
              const SizedBox(height: 20),
              const Text('Keranjang Kosong',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54)),
              const SizedBox(height: 10),
              const Text('Yuk isi dengan bunga impianmu!',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              // Tombol Besar "Kembali ke Home"
              ElevatedButton.icon(
                onPressed: _goToHome, // Memanggil fungsi perbaikan
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text('Kembali ke Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // KERANJANG ADA ISI
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECC9D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: _goToHome,
        ),
        title: const Text('Keranjang Belanja',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCart,
        color: Colors.pink,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                itemCount: cart!.items.length,
                itemBuilder: (_, i) => _buildCartItemCard(cart!.items[i]),
              ),
            ),
            _buildBottomCheckoutBar(),
          ],
        ),
      ),
    );
  }

  // Widget Item Card (Kode Responsive dari jawaban sebelumnya)
  Widget _buildCartItemCard(CartItem item) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFECC9D1),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          ),
          child: const Text("Eleven Florist",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                      value: isAllSelected,
                      activeColor: Colors.black,
                      onChanged: (v) {}),
                  const SizedBox(width: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.image != null
                        ? Image.network(
                            '${ApiService.baseStorageUrl}${item.image}',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover)
                        : Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: const Icon(Icons.local_florist,
                                color: Colors.pink)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                formatRupiah(item.price),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                children: [
                                  _buildQtyBtn("-", () => item.quantity > 1 ? _updateQuantity(item.id, item.quantity - 1) : null),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.white,
                                    child: Text('${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  _buildQtyBtn("+", () => _updateQuantity(item.id, item.quantity + 1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text("Hapus Produk Yang Sudah tidak Diperlukan",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeItem(item.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFD68DA9),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text("Hapus",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyBtn(String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildBottomCheckoutBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: isAllSelected,
                    activeColor: Colors.black,
                    onChanged: (v) => setState(() => isAllSelected = v ?? true),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Pilih Semua",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text("(${cart!.items.length} item)", 
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Total Belanja",
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(formatRupiah(cart!.total),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD68DA9))),
                ],
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CheckoutScreen()));
                  if (result == true && mounted) {
                    await _loadCart();
                    _goToHome();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE594B4),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text("Checkout",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuantity(int itemId, int quantity) async {
    await Provider.of<AuthProvider>(context, listen: false)
        .updateCartItem(itemId, quantity);
    _loadCart();
  }

  Future<void> _removeItem(int itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: const Text('Yakin ingin menghapus bunga ini dari keranjang?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<AuthProvider>(context, listen: false)
          .removeFromCart(itemId);
      await _loadCart();
      if (cart?.items.isEmpty ?? true) _goToHome();
    }
  }
}