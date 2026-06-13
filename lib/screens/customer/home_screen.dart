import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../widgets/product_card.dart';
import '../../constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final featuredProducts = productProvider.products.take(3).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, currentRoute: '/'),
      endDrawer: const CustomDrawer(currentRoute: '/'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section
            _buildHeroSection(context),

            // 2. Extinguisher Categories
            _buildCategorySection(context, productProvider),

            // 3. Featured Products
            _buildFeaturedSection(context, featuredProducts),

            // 4. P.A.S.S. Safety Manual Section
            _buildSafetyGuideSection(context),

            // 5. Testimonials
            _buildTestimonialsSection(context),

            // Footer
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isDark ? [const Color(0xFF16161A), const Color(0xFF0C0C0E)] : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: isMobile ? 40 : 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'CE & UL CERTIFIED PRODUCTS',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'PREMIUM CERTIFIED\nFIRE EXTINGUISHERS',
                      style: TextStyle(fontSize: isMobile ? 32 : 54, fontWeight: FontWeight.w900, height: 1.15, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Protecting your home, vehicles, server rooms, and commercial warehouses with premium-grade firefighting safety solutions. Choose the right protection today.',
                      style: TextStyle(fontSize: isMobile ? 14 : 18, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 32, vertical: isMobile ? 16 : 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                          ),
                          onPressed: () {
                            productProvider(context, listen: false).setSelectedCategory('All');
                            Navigator.pushReplacementNamed(context, '/shop');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Shop Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 28, vertical: isMobile ? 16 : 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text('Admin Access', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 350,
                    margin: const EdgeInsets.only(left: 40),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle animated fire/safety radial background
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.08)),
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department, size: 130, color: AppColors.primary),
                            SizedBox(height: 10),
                            Text(
                              'SAFETY SAVES LIVES',
                              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13, letterSpacing: 2.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, ProductProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMobile = ResponsiveLayout.isMobile(context);

    // Map categories to modern visual icon shapes
    final Map<String, IconData> categoryIcons = {'Dry Powder': Icons.layers_outlined, 'CO2': Icons.cloud_queue, 'Foam': Icons.bubble_chart_outlined, 'Water': Icons.water_drop_outlined, 'Wet Chemical': Icons.restaurant};

    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 60.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATEGORIES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'Filter by Extinguisher Type',
              style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: provider.categories
                  .where((c) => c != 'All')
                  .map(
                    (category) => MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          provider.setSelectedCategory(category);
                          Navigator.pushReplacementNamed(context, '/shop');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(categoryIcons[category] ?? Icons.safety_check, color: AppColors.primary, size: 22),
                              const SizedBox(width: 12),
                              Text(category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, List<dynamic> products) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMobile = ResponsiveLayout.isMobile(context);
    bool isTablet = ResponsiveLayout.isTablet(context);

    int columns = isMobile ? 1 : (isTablet ? 2 : 3);

    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 60.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FEATURED SOLUTIONS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Highly Recommended',
                        style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/shop');
                    },
                    icon: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                    label: const Icon(Icons.arrow_forward, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 0.76),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyGuideSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMobile = ResponsiveLayout.isMobile(context);

    final List<Map<String, String>> steps = [
      {'step': 'P', 'title': 'PULL THE PIN', 'desc': 'Pull the pin out to break the tamper seal lock, allowing the handle to squeeze.'},
      {'step': 'A', 'title': 'AIM LOW', 'desc': 'Aim the nozzle, hose or horn directly at the base of the fire. Do not target the flames.'},
      {'step': 'S', 'title': 'SQUEEZE HANDLE', 'desc': 'Squeeze the operating lever slowly and firmly to release the extinguishing agent.'},
      {'step': 'S', 'title': 'SWEEP SIDE TO SIDE', 'desc': 'Sweep the hose back and forth across the base of the fire until it goes completely out.'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 60.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'EMERGENCY GUIDE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'The P.A.S.S. Method',
              style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'How to properly operate a portable fire extinguisher during an active fire hazard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: steps
                  .map(
                    (step) => Container(
                      width: isMobile ? double.infinity : 260,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                step['step']!,
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            step['title']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step['desc']!,
                            style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMobile = ResponsiveLayout.isMobile(context);

    final testimonials = [
      {'quote': 'The CO2 extinguisher we bought was extremely easy to install. Excellent instructions, high-quality pressure dials, and sleek mountings.', 'author': 'Vimal Patel', 'title': 'Warehouse Safety Lead'},
      {'quote': 'Saves life and property. Kept Sentinel home extinguisher in my caravan. It handles classes A, B and electrical. Tested it during a minor stove hazard, worked like charm!', 'author': 'Deepa Shah', 'title': 'Home Owner'},
    ];

    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 60.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'TESTIMONIALS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                'Trusted by Safety Professionals',
                style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: testimonials
                    .map(
                      (item) => Container(
                        width: isMobile ? double.infinity : 480,
                        padding: const EdgeInsets.all(32),
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
                                Icon(Icons.star, color: AppColors.rating, size: 18),
                                Icon(Icons.star, color: AppColors.rating, size: 18),
                                Icon(Icons.star, color: AppColors.rating, size: 18),
                                Icon(Icons.star, color: AppColors.rating, size: 18),
                                Icon(Icons.star, color: AppColors.rating, size: 18),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '"${item['quote']}"',
                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, height: 1.5),
                            ),
                            const SizedBox(height: 20),
                            Text(item['author']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(item['title']!, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Help support local listener mapping
  ProductProvider productProvider(BuildContext context, {required bool listen}) {
    return Provider.of<ProductProvider>(context, listen: listen);
  }
}
