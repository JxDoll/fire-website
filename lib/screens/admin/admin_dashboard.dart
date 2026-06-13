import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/order_model.dart';
import '../../models/fire_extinguisher.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _activeTab = 0; // 0 = Orders, 1 = Inventory

  @override
  void initState() {
    super.initState();
    // Pre-populate mock orders for Admin dashboard realism
    Provider.of<OrderProvider>(context, listen: false).populateMockOrders();
  }

  void _advanceOrderStatus(BuildContext context, OrderProvider provider, OrderModel order) {
    OrderStatus nextStatus = order.status;
    if (order.status == OrderStatus.pending) {
      nextStatus = OrderStatus.processing;
    } else if (order.status == OrderStatus.processing) {
      nextStatus = OrderStatus.shipped;
    } else if (order.status == OrderStatus.shipped) {
      nextStatus = OrderStatus.delivered;
    } else {
      return; // Already delivered
    }

    provider.updateOrderStatus(order.id, nextStatus);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order ${order.id} updated to $nextStatus!'), backgroundColor: AppColors.success));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final orders = orderProvider.orders;
    final products = productProvider.products;

    // Analytics Math
    double totalRevenue = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    int activeOrdersCount = orders.where((o) => o.status != OrderStatus.delivered).length;
    int totalStock = products.fold(0, (sum, p) => sum + p.stock);
    int lowStockCount = products.where((p) => p.stock < 15).length;

    bool isMobile = ResponsiveLayout.isMobile(context);
    bool isTablet = ResponsiveLayout.isTablet(context);

    int statColumns = isMobile ? 1 : (isTablet ? 2 : 4);

    return Scaffold(
      appBar: const CustomNavbar(currentRoute: '/admin'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Admin Panel Jumbotron
            Container(
              width: double.infinity,
              color: isDark ? AppColors.darkSurface : Colors.white,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADMIN SYSTEM PORTAL',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Firesafe Control Center',
                            style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield_outlined, color: AppColors.warning, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'ADMIN SECURE MODE',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Dashboard Body
            Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      // 1. Stats Row
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: statColumns, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: isMobile ? 2.0 : 1.5),
                        children: [
                          StatCard(title: 'Total Gross Sales', value: '₹${totalRevenue.toStringAsFixed(2)}', icon: Icons.monetization_on_outlined, color: AppColors.success, trend: '+14.5%'),
                          StatCard(title: 'Active Dispatches', value: '$activeOrdersCount orders', icon: Icons.local_shipping_outlined, color: AppColors.info, trend: '+2 new'),
                          StatCard(title: 'Inventory Storage', value: '$totalStock cylinders', icon: Icons.storage_outlined, color: AppColors.primary, trend: 'Optimal'),
                          StatCard(title: 'Low Stock Alerts', value: '$lowStockCount items', icon: Icons.warning_amber_outlined, color: AppColors.warning, trend: '-50%', isPositive: false),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // 2. Navigation Tab Buttons
                      Row(children: [_buildTabButton(0, 'Orders Dispatch Panel', Icons.local_shipping_outlined), const SizedBox(width: 16), _buildTabButton(1, 'Inventory Stock Manager', Icons.inventory_2_outlined)]),
                      const SizedBox(height: 24),

                      // 3. Tab Contents
                      if (_activeTab == 0) _buildOrdersDispatcher(orders, orderProvider, isDark, isMobile) else _buildInventoryManager(products, productProvider, isDark, isMobile),
                    ],
                  ),
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isActive = _activeTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.primary : (isDark ? AppColors.darkCard : Colors.white),
        foregroundColor: isActive ? Colors.white : (isDark ? Colors.white70 : AppColors.lightTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isActive ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () {
        setState(() {
          _activeTab = index;
        });
      },
    );
  }

  Widget _buildOrdersDispatcher(List<OrderModel> orders, OrderProvider provider, bool isDark, bool isMobile) {
    if (orders.isEmpty) {
      return _buildEmptyState('No orders placed in system yet.', Icons.shopping_basket_outlined, isDark);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Transaction Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderMeta(order, isDark),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatusBadge(order.status), _buildAdvanceCTA(order, provider)]),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildOrderMeta(order, isDark)),
                          const SizedBox(width: 16),
                          _buildStatusBadge(order.status),
                          const SizedBox(width: 20),
                          _buildAdvanceCTA(order, provider),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMeta(OrderModel order, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 8),
            Text('- By ${order.customerName}', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Destination: ${order.shippingAddress}',
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text('Total Charged: ₹${order.totalAmount.toStringAsFixed(2)} | Method: ${order.paymentMethod}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAdvanceCTA(OrderModel order, OrderProvider provider) {
    final isDelivered = order.status == OrderStatus.delivered;
    String label = 'Dispatch Pack';
    IconData icon = Icons.gif_box;

    if (order.status == OrderStatus.processing) {
      label = 'Ship Package';
      icon = Icons.local_shipping;
    } else if (order.status == OrderStatus.shipped) {
      label = 'Confirm Delivery';
      icon = Icons.done_all;
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      onPressed: isDelivered ? null : () => _advanceOrderStatus(context, provider, order),
    );
  }

  Widget _buildInventoryManager(List<FireExtinguisher> products, ProductProvider provider, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Extinguisher Inventory Catalog', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Cylinder Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  // Prompt adding a mock product
                  final newProd = FireExtinguisher(
                    id: 'fe-abc-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
                    name: 'Sentinel Pro Heavy Duty Dry Powder',
                    description: 'Industrial heavy duty fire extinguisher for high-risk hazards.',
                    price: 120.00,
                    imageUrl: 'https://images.unsplash.com/photo-1616788494707-ec28f08d05a1?q=80&w=600',
                    category: 'Dry Powder',
                    capacity: '9 kg',
                    rating: 5.0,
                    reviewsCount: 1,
                    fireClass: 'Class A, B, C',
                    dischargeTime: '25 seconds',
                    range: '7 meters',
                    pressure: '15 bar',
                    stock: 10,
                  );
                  provider.addProduct(newProd);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New mock product added successfully!'), backgroundColor: AppColors.success));
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isLowStock = product.stock < 15;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Cat: ${product.category} | Price: ₹${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isLowStock ? AppColors.warning : AppColors.success),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => provider.updateStock(product.id, -1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.success, size: 20),
                          onPressed: () => provider.updateStock(product.id, 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => provider.removeProduct(product.id),
                          tooltip: 'Delete product',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, size: 40, color: isDark ? Colors.white30 : Colors.black26),
          const SizedBox(height: 12),
          Text(msg),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color = AppColors.warning;
    String label = 'Pending';

    if (status == OrderStatus.processing) {
      color = AppColors.info;
      label = 'Processing';
    } else if (status == OrderStatus.shipped) {
      color = Colors.purple;
      label = 'Shipped';
    } else if (status == OrderStatus.delivered) {
      color = AppColors.success;
      label = 'Delivered';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
