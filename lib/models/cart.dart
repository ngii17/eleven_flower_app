class Cart {
  final int id;
  final double total;
  final List<CartItem> items;

  Cart({required this.id, required this.total, required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      total: double.parse(json['total'].toString()),
      items: (json['items'] as List? ?? []).map((item) => CartItem.fromJson(item)).toList(),
    );
  }
}

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product']['name'] ?? 'Unknown Product',
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      image: json['product']['image'],
    );
  }

  double get subtotal => price * quantity;
}