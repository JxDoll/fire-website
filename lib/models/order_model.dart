import 'cart_item.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String customerName;
  final String customerEmail;
  final String shippingAddress;
  OrderStatus status;
  final DateTime orderDate;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.customerName,
    required this.customerEmail,
    required this.shippingAddress,
    this.status = OrderStatus.pending,
    required this.orderDate,
    required this.paymentMethod,
  });

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    String? customerName,
    String? customerEmail,
    String? shippingAddress,
    OrderStatus? status,
    DateTime? orderDate,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
