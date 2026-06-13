import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../responsive/responsive_layout.dart';
import '../constants/app_colors.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String currentRoute;

  const CustomNavbar({super.key, this.scaffoldKey, required this.currentRoute});

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context)),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo & Brand
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_fire_department, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SAI INTERNATIONAL FIRE SERVICE',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightTextPrimary, letterSpacing: 1.5),
                      ),
                      Text(
                        'E-COMMERCE',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Links for Desktop
            if (isDesktop)
              Row(
                children: [
                  _NavBarItem(title: 'Home', isActive: currentRoute == '/', onTap: () => Navigator.pushReplacementNamed(context, '/')),
                  _NavBarItem(title: 'Shop Extinguishers', isActive: currentRoute == '/shop', onTap: () => Navigator.pushReplacementNamed(context, '/shop')),
                  if (authProvider.role == UserRole.admin)
                    _NavBarItem(title: 'Admin Panel', isActive: currentRoute == '/admin', onTap: () => Navigator.pushReplacementNamed(context, '/admin'))
                  else ...[
                    _NavBarItem(title: 'Track Order', isActive: currentRoute == '/track-order', onTap: () => Navigator.pushReplacementNamed(context, '/track-order')),
                  ],
                ],
              ),

            // Right side icons (Cart, Theme, Auth)
            Row(
              children: [
                // Theme Toggle
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: 'Toggle Theme',
                ),
                const SizedBox(width: 8),

                // Cart Icon (Only if not Admin)
                if (authProvider.role != UserRole.admin)
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        onPressed: () => Navigator.pushNamed(context, '/cart'),
                        tooltip: 'Cart',
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(width: 8),

                // Account / Auth Navigation
                if (isDesktop) ...[
                  if (authProvider.isAuthenticated) ...[
                    PopupMenuButton<String>(
                      offset: const Offset(0, 50),
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                authProvider.currentUserName?.substring(0, 1) ?? 'U',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              authProvider.currentUserName ?? 'User',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      ),
                      onSelected: (val) {
                        if (val == 'profile') {
                          Navigator.pushNamed(context, '/profile');
                        } else if (val == 'settings') {
                          Navigator.pushNamed(context, '/settings');
                        } else if (val == 'logout') {
                          authProvider.logout();
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(children: [Icon(Icons.person_outline, size: 20), SizedBox(width: 10), Text('My Profile')]),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(children: [Icon(Icons.settings_outlined, size: 20), SizedBox(width: 10), Text('Settings')]),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.redAccent, size: 20),
                              SizedBox(width: 10),
                              Text('Logout', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Login / Register'),
                    ),
                  ],
                ] else ...[
                  // Mobile Hamburger Drawer button
                  IconButton(
                    icon: Icon(Icons.menu, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    onPressed: () {
                      if (scaffoldKey != null) {
                        scaffoldKey!.currentState?.openEndDrawer();
                      }
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ),
            const SizedBox(height: 4),
            Container(height: 2, width: 24, color: isActive ? AppColors.primary : Colors.transparent),
          ],
        ),
      ),
    );
  }
}

// Global Drawer for mobile and tablet views
class CustomDrawer extends StatelessWidget {
  final String currentRoute;

  const CustomDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.primary, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'SAI INTERNATIONAL FIRE SERVICE',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                  if (authProvider.isAuthenticated) Text(authProvider.currentUserName ?? '', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ],
              ),
            ),
          ),

          // Drawer Links
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerTile(context, title: 'Home', icon: Icons.home_outlined, route: '/'),
                _buildDrawerTile(context, title: 'Shop Catalog', icon: Icons.shopping_bag_outlined, route: '/shop'),
                if (authProvider.role == UserRole.admin)
                  _buildDrawerTile(context, title: 'Admin Panel', icon: Icons.dashboard_customize_outlined, route: '/admin')
                else ...[
                  _buildDrawerTile(context, title: 'Track Order', icon: Icons.local_shipping_outlined, route: '/track-order'),
                ],
                const Divider(),
                if (authProvider.isAuthenticated) ...[_buildDrawerTile(context, title: 'Profile', icon: Icons.person_outline, route: '/profile'), _buildDrawerTile(context, title: 'Settings', icon: Icons.settings_outlined, route: '/settings')],
              ],
            ),
          ),

          // Logout / Login Footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: authProvider.isAuthenticated
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      authProvider.logout();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.login),
                    label: const Text('Login / Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(BuildContext context, {required String title, required IconData icon, required String route}) {
    final isActive = currentRoute == route;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      title: Text(
        title,
        style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
