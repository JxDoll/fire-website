import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../constants/app_colors.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _searchController = TextEditingController();
  String? _searchedOrderId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderProvider = Provider.of<OrderProvider>(context);

    // Get order ID from arguments if passed, otherwise use search state
    final argOrderId = ModalRoute.of(context)!.settings.arguments as String?;
    final activeId = _searchedOrderId ?? argOrderId ?? (orderProvider.latestOrder?.id);

    final OrderModel? order = activeId != null ? orderProvider.getOrderById(activeId) : null;

    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const CustomNavbar(currentRoute: '/track-order'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Title Header
            Container(
              width: double.infinity,
              color: isDark ? AppColors.darkSurface : Colors.white,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Text(
                    'Order Delivery Tracker',
                    style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            ),

            // Main Body Container
            Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      // Search Bar
                      _buildTrackerSearchBox(isDark),
                      const SizedBox(height: 32),

                      if (order == null)
                        _buildNoActiveOrder(isDark)
                      else ...[
                        _buildOrderDetailsHeader(order, isDark),
                        const SizedBox(height: 24),
                        _buildTrackingStepper(order, isDark, isMobile),
                        const SizedBox(height: 24),
                        _buildCourierDetailsCard(order, isDark),
                      ],
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

  Widget _buildTrackerSearchBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Track Another Package', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(hintText: 'Enter order tracking number (e.g. ORD-984712)', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (_searchController.text.trim().isNotEmpty) {
                    setState(() {
                      _searchedOrderId = _searchController.text.trim();
                    });
                  }
                },
                child: const Text('TRACK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveOrder(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_shipping, size: 55, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text('No Active Tracking Order Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Check your order history under Profile or search for an Order ID above.',
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsHeader(OrderModel order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER NUMBER',
                style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(order.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Placed on: ${order.orderDate.toString().substring(0, 16)}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GRAND TOTAL',
                style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.success),
              ),
              const SizedBox(height: 8),
              Text('Method: ${order.paymentMethod}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStepper(OrderModel order, bool isDark, bool isMobile) {
    final statusIndex = OrderStatus.values.indexOf(order.status);

    final List<Map<String, dynamic>> steps = [
      {'status': OrderStatus.pending, 'label': 'Order Received', 'desc': 'Mock transaction authorized and queued.'},
      {'status': OrderStatus.processing, 'label': 'Inventory Dispatch', 'desc': 'Safeline safety container packaged.'},
      {'status': OrderStatus.shipped, 'label': 'In Transit', 'desc': 'Courier picked up package from depot.'},
      {'status': OrderStatus.delivered, 'label': 'Delivered', 'desc': 'Delivered safely to recipient address.'},
    ];

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
          const Text('Delivery Lifecycle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final stepIndex = steps.indexOf(step);
              final isCompleted = statusIndex >= stepIndex;
              final isCurrent = statusIndex == stepIndex;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon indicator + Line column
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: isCompleted ? AppColors.primary : (isDark ? AppColors.darkBorder : Colors.grey[200]), shape: BoxShape.circle),
                        child: Icon(isCompleted ? Icons.check : Icons.circle, color: isCompleted ? Colors.white : (isDark ? Colors.white30 : Colors.black12), size: isCompleted ? 14 : 6),
                      ),
                      if (index != steps.length - 1) Container(width: 2, height: 50, color: isCompleted ? AppColors.primary : (isDark ? AppColors.darkBorder : Colors.grey[200])),
                    ],
                  ),
                  const SizedBox(width: 20),

                  // Detail column
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['label']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? (isCurrent ? AppColors.primary : (isDark ? Colors.white : AppColors.lightTextPrimary)) : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(step['desc']!, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourierDetailsCard(OrderModel order, bool isDark) {
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
          const Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Courier & Consignee Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _buildCourierRow('Carrier logistics', 'DHL Safeline Logistics', isDark),
          _buildCourierRow('Recipient Name', order.customerName, isDark),
          _buildCourierRow('Shipping Destination', order.shippingAddress, isDark),
        ],
      ),
    );
  }

  Widget _buildCourierRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
