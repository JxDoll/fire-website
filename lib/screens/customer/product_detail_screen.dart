import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../constants/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    // Find the product
    final product = productProvider.products.firstWhere((p) => p.id == productId);

    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const CustomNavbar(currentRoute: '/shop'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Breadcrumbs / Back button
            Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 16),
              color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Catalogue',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : AppColors.lightTextPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product Details Block
            Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isMobile
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildProductImage(product), const SizedBox(height: 30), _buildProductDetails(context, product, cartProvider, isDark)])
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: _buildProductImage(product)),
                            const SizedBox(width: 48),
                            Expanded(flex: 1, child: _buildProductDetails(context, product, cartProvider, isDark)),
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

  Widget _buildProductImage(dynamic product) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.local_fire_department, color: AppColors.primary, size: 100);
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: Text(
                product.category,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, dynamic product, CartProvider cartProvider, bool isDark) {
    bool isOutOfStock = product.stock == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Name
        const Text(
          'SAI INTERNATIONAL FIRE SERVICE CERTIFIED SAFETY',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 2),
        ),
        const SizedBox(height: 12),

        // Product Title
        Text(
          product.name,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
        ),
        const SizedBox(height: 12),

        // Ratings & Reviews
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.rating, size: 20),
            const SizedBox(width: 4),
            Text('${product.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 8),
            Text('(${product.reviewsCount} verified customer reviews)', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 20),

        // Price
        Text(
          '₹${product.price.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightTextPrimary),
        ),
        const SizedBox(height: 16),

        // Description
        Text(product.description, style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        const SizedBox(height: 24),

        // Technical Specs Grid
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Technical Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 16),
              _buildSpecRow('Fire Class Rating', product.fireClass, isDark),
              _buildSpecRow('Extinguishing Agent Capacity', product.capacity, isDark),
              _buildSpecRow('Discharge Range', product.range, isDark),
              _buildSpecRow('Discharge Duration', product.dischargeTime, isDark),
              _buildSpecRow('Working Pressure', product.pressure, isDark),
              _buildSpecRow('In-Stock Availability', isOutOfStock ? 'Out of Stock' : '${product.stock} units left', isDark, isAvailability: true, isOut: isOutOfStock),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Actions: Quantity selector & Add to Cart
        if (!isOutOfStock) ...[
          Row(
            children: [
              // Quantity adjust
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        if (_quantity < product.stock) {
                          setState(() {
                            _quantity++;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Add to cart CTA
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('ADD TO CART', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      cartProvider.addItem(product);
                    }
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $_quantity units of ${product.name} to cart!'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'GO TO CART',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(context, '/cart');
                          },
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'THIS ITEM IS CURRENTLY SOLD OUT',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecRow(String label, String value, bool isDark, {bool isAvailability = false, bool isOut = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAvailability ? (isOut ? Colors.redAccent : AppColors.success) : (isDark ? Colors.white : AppColors.lightTextPrimary)),
          ),
        ],
      ),
    );
  }
}
