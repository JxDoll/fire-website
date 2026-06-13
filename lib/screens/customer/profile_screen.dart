import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate mock orders for Admin and Profile view realism
    Provider.of<OrderProvider>(context, listen: false).populateMockOrders();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = auth.currentUserName ?? '';
    _emailController.text = auth.currentUserEmail ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    // Get orders belonging to user email (mock match)
    final userOrders = orderProvider.orders.where((o) => o.customerEmail == authProvider.currentUserEmail || o.items.isNotEmpty).toList();

    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const CustomNavbar(currentRoute: '/profile'),
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
                    'My Profile Dashboard',
                    style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            ),

            // Content
            Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isMobile
                      ? Column(children: [_buildProfileCard(authProvider, isDark), const SizedBox(height: 30), _buildOrderHistorySection(userOrders, isDark)])
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: _buildProfileCard(authProvider, isDark)),
                            const SizedBox(width: 32),
                            Expanded(flex: 2, child: _buildOrderHistorySection(userOrders, isDark)),
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

  Widget _buildProfileCard(AuthProvider auth, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              auth.currentUserName?.substring(0, 1) ?? 'U',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(auth.currentUserName ?? 'Anonymous', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            auth.isAdmin ? 'System Administrator' : 'Customer Account',
            style: TextStyle(fontSize: 12, color: auth.isAdmin ? AppColors.warning : AppColors.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            enabled: _isEditing,
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            enabled: _isEditing,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isEditing ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_isEditing) {
                auth.updateProfile(_nameController.text, _emailController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile details updated successfully!'), backgroundColor: AppColors.success));
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(_isEditing ? 'SAVE CHANGES' : 'EDIT PROFILE', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistorySection(List<OrderModel> orders, bool isDark) {
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
          const Text('Purchase History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (orders.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.history_toggle_off, size: 40, color: isDark ? Colors.white30 : Colors.black26),
                  const SizedBox(height: 12),
                  const Text('No orders placed yet.'),
                ],
              ),
            )
          else
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(order.orderDate.toString().substring(0, 16), style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('₹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 16),
                          _buildStatusBadge(order.status),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 14),
                            onPressed: () {
                              Navigator.pushNamed(context, '/track-order', arguments: order.id);
                            },
                            tooltip: 'Track order details',
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
