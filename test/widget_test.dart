import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fire/main.dart';
import 'package:fire/providers/theme_provider.dart';
import 'package:fire/providers/auth_provider.dart';
import 'package:fire/providers/product_provider.dart';
import 'package:fire/providers/cart_provider.dart';
import 'package:fire/providers/order_provider.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
        ],
        child: const FireSafetyApp(),
      ),
    );

    // Verify that the main brand logo/text is loaded on the Home Screen
    expect(find.text('FIRESAFE'), findsWidgets);
  });
}
