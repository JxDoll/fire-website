import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => [..._orders];

  OrderModel? get latestOrder {
    if (_orders.isEmpty) return null;
    return _orders.last;
  }

  OrderModel? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel> placeOrder({
    required List<CartItem> items,
    required double totalAmount,
    required String customerName,
    required String customerEmail,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: items,
      totalAmount: totalAmount,
      customerName: customerName,
      customerEmail: customerEmail,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      orderDate: DateTime.now(),
      status: OrderStatus.pending,
    );

    _orders.add(newOrder);
    notifyListeners();
    return newOrder;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      _orders[index].status = status;
      notifyListeners();
    }
  }

  // Prepopulate with a couple of mock completed/shipped orders for Admin UI realism
  void populateMockOrders() {
    if (_orders.isNotEmpty) return;
    
    _orders.addAll([
      OrderModel(
        id: 'ORD-984712',
        items: [],
        totalAmount: 184.97,
        customerName: 'Kevin Patel',
        customerEmail: 'kevin@gmail.com',
        shippingAddress: '404 Fire Safety St, Ahmedabad, Gujarat',
        paymentMethod: 'Credit Card',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        status: OrderStatus.delivered,
      ),
      OrderModel(
        id: 'ORD-345812',
        items: [],
        totalAmount: 74.50,
        customerName: 'Rajesh Shah',
        customerEmail: 'rajesh@outlook.com',
        shippingAddress: '12 Green Park, Vadodara, Gujarat',
        paymentMethod: 'UPI (Paytm)',
        orderDate: DateTime.now().subtract(const Duration(hours: 18)),
        status: OrderStatus.shipped,
      ),
      OrderModel(
        id: 'ORD-219403',
        items: [],
        totalAmount: 239.97,
        customerName: 'Sneha Patel',
        customerEmail: 'sneha@yahoo.com',
        shippingAddress: '88 Sky High Towers, Surat, Gujarat',
        paymentMethod: 'Net Banking',
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        status: OrderStatus.processing,
      ),
    ]);
    notifyListeners();
  }
}
