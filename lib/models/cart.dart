// models/cart.dart
class Cart {
  final int id;
  final double total;
  final List<CartItem> items;

  Cart({required this.id, required this.total, required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<CartItem> itemsList = list.map((i) => CartItem.fromJson(i)).toList();

    return Cart(
      id: json['id'] ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      items: itemsList,
    );
  }
}

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;     // harga per item (dari product.price)
  final int quantity;
  final String? image;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
  });

  // INI YANG BIKIN SEMUA JADI JALAN — AMBIL HARGA DARI product.price!
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Ambil harga dari product.price atau product.harga
    double harga = 0.0;
    if (json['product'] != null) {
      harga = double.tryParse(json['product']['price'].toString()) ??
              double.tryParse(json['product']['harga'].toString()) ??
              0.0;
    }

    return CartItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? json['product']['id'] ?? 0,
      productName: json['product']['name'] ?? json['product']['nama'] ?? 'Unknown',
      price: harga,
      quantity: json['quantity'] ?? 1,
      image: json['product']['image'] ?? json['product']['gambar'],
    );
  }

  double get subtotal => price * quantity;
}