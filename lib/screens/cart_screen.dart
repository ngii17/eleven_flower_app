import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = true;
  Cart? cart;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);
    try {
      cart = await Provider.of<AuthProvider>(context, listen: false).getCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Keranjang Belanja')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (cart == null || cart!.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Keranjang Belanja')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Keranjang kosong', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Lihat Katalog'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Belanja (${cart!.items.length})'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).clearCart();
              _loadCart();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart!.items.length,
              itemBuilder: (context, index) {
                final item = cart!.items[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      item.image != null ? '${ApiService.baseUrl.replaceAll('/api', '/storage/')}${item.image}' : 'https://via.placeholder.com/60x60.png?text=No+Image',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported),
                    ),
                    title: Text(item.productName),
                    subtitle: Text('Rp ${(item.price * item.quantity).toStringAsFixed(0)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: item.quantity > 1
                              ? () => _updateQuantity(item.id, item.quantity - 1)
                              : () => _removeItem(item.id),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _updateQuantity(item.id, item.quantity + 1),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: Rp ${cart!.total.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fitur Checkout menyusul ya! 😊')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuantity(int itemId, int quantity) async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateCartItem(itemId, quantity);
      _loadCart();  // Reload
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _removeItem(int itemId) async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).removeFromCart(itemId);
      _loadCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}