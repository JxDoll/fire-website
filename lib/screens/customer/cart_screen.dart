import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../constants/app_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();

    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const CustomNavbar(currentRoute: '/cart'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: isDark ? AppColors.darkSurface : Colors.white,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Text(
                    'Shopping Basket',
                    style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            ),

            // Cart details
            Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: cartItems.isEmpty
                      ? _buildEmptyCart(context, isDark)
                      : isMobile
                      ? Column(children: [_buildCartItemsList(context, cartItems, cartProvider, isDark), const SizedBox(height: 30), _buildOrderSummaryCard(context, cartProvider, isDark)])
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildCartItemsList(context, cartItems, cartProvider, isDark)),
                            const SizedBox(width: 32),
                            Expanded(flex: 1, child: _buildOrderSummaryCard(context, cartProvider, isDark)),
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

  Widget _buildEmptyCart(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 64, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          const SizedBox(height: 20),
          const Text('Your Shopping Basket is Empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Add some fire safety and extinguishing items to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pushReplacementNamed(context, '/shop'),
            child: const Text('Return to Shop', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context, List<dynamic> items, CartProvider provider, bool isDark) {
    return Column(
      children: items.map((item) {
        final product = item.product;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              // Product small thumbnail image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.primary.withValues(alpha: 0.05)),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_fire_department, color: AppColors.primary, size: 30),
                ),
              ),
              const SizedBox(width: 16),

              // Title & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('Type: ${product.category} | ${product.capacity}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    const SizedBox(height: 6),
                    Text('₹${product.price.toStringAsFixed(2)} each', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Adjuster and total price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Quantity controller
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => provider.removeSingleItem(product.id)),
                      Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => provider.addItem(product)),
                    ],
                  ),

                  // Total Item price & Delete button
                  Row(
                    children: [
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => provider.removeItem(product.id),
                        tooltip: 'Remove item',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, CartProvider provider, bool isDark) {
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
          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Subtotal
          _buildSummaryRow('Cart Subtotal', '₹${provider.subtotal.toStringAsFixed(2)}', isDark),
          const SizedBox(height: 12),

          // Shipping
          _buildSummaryRow('Estimated Shipping', provider.shippingCost == 0.0 ? 'FREE' : '₹${provider.shippingCost.toStringAsFixed(2)}', isDark, valueColor: provider.shippingCost == 0.0 ? AppColors.success : null),
          const SizedBox(height: 8),
          if (provider.shippingCost != 0.0)
            Text(
              'Add ₹${(150.00 - provider.subtotal).toStringAsFixed(2)} more for FREE shipping!',
              style: TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 12),

          // Tax
          _buildSummaryRow('Sales Tax (12%)', '₹${provider.taxAmount.toStringAsFixed(2)}', isDark),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Total
          _buildSummaryRow('Grand Total', '₹${provider.totalAmount.toStringAsFixed(2)}', isDark, isTotal: true),
          const SizedBox(height: 30),

          // Checkout Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/checkout');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 18),
                SizedBox(width: 8),
                Text('SECURE CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? (isDark ? Colors.white : AppColors.lightTextPrimary) : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: isTotal ? 20 : 14, fontWeight: FontWeight.bold, color: valueColor ?? (isDark ? Colors.white : AppColors.lightTextPrimary)),
        ),
      ],
    );
  }
}
