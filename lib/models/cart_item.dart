import 'fire_extinguisher.dart';

class CartItem {
  final String id;
  final FireExtinguisher product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}
