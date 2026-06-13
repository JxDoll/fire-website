import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationAlerts = true;
  bool _safetyBulletins = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const CustomNavbar(currentRoute: '/settings'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header
            Container(
              width: double.infinity,
              color: isDark ? AppColors.darkSurface : Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.getResponsivePadding(context),
                vertical: 24,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Text(
                    'Application Settings',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 30,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
            ),

            // Settings options
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.getResponsivePadding(context),
                vertical: 40,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // Preference Card
                      _buildPreferencesCard(themeProvider, isDark),
                      const SizedBox(height: 24),

                      // Notification Card
                      _buildNotificationCard(isDark),
                      const SizedBox(height: 24),

                      // Support Card
                      _buildSupportCard(isDark),
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

  Widget _buildPreferencesCard(ThemeProvider themeProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.palette_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Display & Language Preferences',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Theme toggle
          SwitchListTile(
            title: const Text('Premium Dark Theme Mode'),
            subtitle: const Text('Reduce glare and save power on high-resolution displays.'),
            activeThumbColor: AppColors.primary,
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),

          // Language dropdown
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Language Preference'),
            subtitle: const Text('Translate titles, categories, and notifications.'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: ['English', 'Gujarati', 'Hindi']
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedLanguage = val;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language switched to $val (Mock operation)'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Safety Alerts & Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Order Shipping & Delivery Alerts'),
            subtitle: const Text('Receive push alerts or web emails for dispatch milestones.'),
            activeThumbColor: AppColors.primary,
            value: _notificationAlerts,
            onChanged: (val) {
              setState(() {
                _notificationAlerts = val;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Fire Safety Advisories & bulletins'),
            subtitle: const Text('Stay updated with industrial safety and compliance guidelines.'),
            activeThumbColor: AppColors.primary,
            value: _safetyBulletins,
            onChanged: (val) {
              setState(() {
                _safetyBulletins = val;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Help & Support Center',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportRow('Emergency Support Email', 'support@firesafe.com', isDark),
          _buildSupportRow('Emergency Helpline Number', '+91 79 2345 6789', isDark),
          _buildSupportRow('Warehouse Location', '404 Fire Safety St, Ahmedabad, Gujarat', isDark),
        ],
      ),
    );
  }

  Widget _buildSupportRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
