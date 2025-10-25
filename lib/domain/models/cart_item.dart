class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? description;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.description,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? description,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }
}
