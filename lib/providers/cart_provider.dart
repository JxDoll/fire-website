import 'package:flutter/material.dart';
import '../models/fire_extinguisher.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  double get shippingCost {
    if (subtotal == 0) return 0.0;
    return subtotal > 150 ? 0.0 : 15.0; // Free shipping over $150
  }

  double get taxAmount => subtotal * 0.12; // 12% sales tax

  double get totalAmount => subtotal + shippingCost + taxAmount;

  void addItem(FireExtinguisher product) {
    if (_items.containsKey(product.id)) {
      if (_items[product.id]!.quantity < product.stock) {
        _items.update(
          product.id,
          (existingItem) => CartItem(
            id: existingItem.id,
            product: existingItem.product,
            quantity: existingItem.quantity + 1,
          ),
        );
      }
    } else {
      if (product.stock > 0) {
        _items.putIfAbsent(
          product.id,
          () => CartItem(
            id: DateTime.now().toString(),
            product: product,
            quantity: 1,
          ),
        );
      }
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
