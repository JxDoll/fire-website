import 'package:flutter/material.dart';
import '../responsive/responsive_layout.dart';
import '../constants/app_colors.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsivePadding(context), vertical: 40.0),
      child: Column(
        children: [
          Wrap(
            spacing: 40.0,
            runSpacing: 30.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Column 1: Brand details
              SizedBox(
                // width: isMobile ? double.infinity : 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: AppColors.primary, size: 32),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SAI INTERNATIONAL FIRE SERVICE',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightTextPrimary, letterSpacing: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your premium partner in fire safety solutions. Providing state-of-the-art certified fire extinguishers, professional safety equipment, and advisory assets since 2026.',
                      style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),

              // Column 2: Navigation Links
              _buildFooterColumn(context, title: 'PRODUCTS', links: ['ABC Dry Powder', 'Carbon Dioxide (CO2)', 'AFFF Foam', 'Water Spray', 'Wet Chemical (Kitchen)']),

              // Column 3: Safety Resources
              _buildFooterColumn(context, title: 'SAFETY GUIDE', links: ['Fire Classes Explained', 'How to Use (P.A.S.S.)', 'Maintenance Checks', 'Emergency Evacuation', 'Certification Norms']),

              // Column 4: Newsletter
              SizedBox(
                width: isMobile ? double.infinity : 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEWSLETTER',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text('Subscribe to receive fire hazard alerts, product updates, and safety manuals.', style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter email address',
                              hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: isDark ? AppColors.darkCard : AppColors.lightBackground,
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for subscribing!'), backgroundColor: AppColors.success));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('© 2026 SAI INTERNATIONAL FIRE SERVICE Inc. All rights reserved.', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    const SizedBox(height: 12),
                    Row(children: [_buildSocialIcon(Icons.facebook), const SizedBox(width: 12), _buildSocialIcon(Icons.chat_bubble_outline), const SizedBox(width: 12), _buildSocialIcon(Icons.alternate_email)]),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '© 2026 SAI INTERNATIONAL FIRE SERVICE Inc. All rights reserved.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(children: [_buildSocialIcon(Icons.facebook), const SizedBox(width: 12), _buildSocialIcon(Icons.chat_bubble_outline), const SizedBox(width: 12), _buildSocialIcon(Icons.alternate_email)]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(BuildContext context, {required String title, required List<String> links}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(link, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(icon, size: 18, color: AppColors.primary);
  }
}
