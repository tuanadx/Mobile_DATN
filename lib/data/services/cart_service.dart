import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/cart_item.dart';

class CartService {
  static const String _cartKey = 'cart_items';
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Load cart from local storage
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        _cartItems = cartList.map((json) => CartItem.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading cart: $e');
      _cartItems = [];
    }
  }

  // Save cart to local storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Add item to cart
  Future<void> addItem(CartItem item) async {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.productId == item.productId
    );

    if (existingIndex != -1) {
      // Update quantity if item already exists
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      _cartItems.add(item);
    }

    await _saveCart();
    _notifyListeners();
  }

  // Remove item from cart
  Future<void> removeItem(String itemId) async {
    _cartItems.removeWhere((item) => item.id == itemId);
    await _saveCart();
    _notifyListeners();
  }

  // Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      await _saveCart();
      _notifyListeners();
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
    _notifyListeners();
  }

  // Check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;

  // Get item by ID
  CartItem? getItemById(String itemId) {
    try {
      return _cartItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Listeners for cart changes
  final List<VoidCallback> _listeners = [];
  
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

typedef VoidCallback = void Function();
