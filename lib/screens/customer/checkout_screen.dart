import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../responsive/responsive_layout.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_footer.dart';
import '../../constants/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _paymentMethod = 'Credit Card';
  final _cardNoController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _upiController = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill logged-in customer info if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        _nameController.text = auth.currentUserName ?? '';
        _emailController.text = auth.currentUserEmail ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _cardNoController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _processCheckout(CartProvider cart, OrderProvider orderProvider, ProductProvider productProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // If guest, log them in as guest customer for session order tracking simplicity
    if (!authProvider.isAuthenticated) {
      await authProvider.login(_emailController.text, 'guest123');
    }

    final newOrder = await orderProvider.placeOrder(
      items: cart.items.values.toList(),
      totalAmount: cart.totalAmount,
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      shippingAddress: _addressController.text,
      paymentMethod: _paymentMethod,
    );

    // Deduct stock levels in-memory to reflect realistic purchase actions
    for (var cartItem in cart.items.values) {
      productProvider.updateStock(cartItem.product.id, -cartItem.quantity);
    }

    if (mounted) {
      cart.clear();
      setState(() {
        _isProcessing = false;
      });

      // Show success screen or route directly to tracking screen
      Navigator.pushReplacementNamed(context, '/track-order', arguments: newOrder.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const CustomNavbar(currentRoute: '/cart'),
      body: _isProcessing
          ? _buildLoadingOverlay(isDark)
          : SingleChildScrollView(
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
                          'Checkout Payment Gateway',
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
                        child: Form(
                          key: _formKey,
                          child: isMobile
                              ? Column(
                                  children: [
                                    _buildOrderSummaryMini(cartProvider, isDark),
                                    const SizedBox(height: 30),
                                    _buildShippingForm(isDark),
                                    const SizedBox(height: 30),
                                    _buildPaymentForm(isDark),
                                    const SizedBox(height: 30),
                                    _buildSubmitCTA(cartProvider, orderProvider, productProvider),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 5, child: Column(children: [_buildShippingForm(isDark), const SizedBox(height: 30), _buildPaymentForm(isDark)])),
                                    const SizedBox(width: 32),
                                    Expanded(flex: 3, child: Column(children: [_buildOrderSummaryMini(cartProvider, isDark), const SizedBox(height: 24), _buildSubmitCTA(cartProvider, orderProvider, productProvider)])),
                                  ],
                                ),
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

  Widget _buildLoadingOverlay(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Processing Secure Payment Transaction...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary),
            ),
            const SizedBox(height: 8),
            Text('Please do not refresh or close this browser tab.', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingForm(bool isDark) {
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
              Icon(Icons.local_shipping_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text('1. Shipping Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
            validator: (value) => value == null || value.trim().isEmpty ? 'Enter recipient name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
            validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email address' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined)),
            validator: (value) => value == null || value.length < 10 ? 'Enter contact number (10+ digits)' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Shipping Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.pin_drop_outlined)),
            validator: (value) => value == null || value.trim().isEmpty ? 'Enter shipping destination' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(bool isDark) {
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
              Icon(Icons.payment, color: AppColors.primary),
              SizedBox(width: 10),
              Text('2. Payment Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          // Selector
          Wrap(
            spacing: 12,
            children: ['Credit Card', 'UPI', 'Net Banking'].map((method) {
              final isSelected = _paymentMethod == method;
              return ChoiceChip(
                label: Text(method),
                selected: isSelected,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.lightTextPrimary)),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _paymentMethod = method;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Conditional fields
          if (_paymentMethod == 'Credit Card') ...[
            TextFormField(
              controller: _cardNoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Card Number', hintText: '4111 2222 3333 4444', border: OutlineInputBorder(), prefixIcon: Icon(Icons.credit_card)),
              validator: (value) => value == null || value.length < 16 ? 'Enter valid 16-digit card number' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(labelText: 'Expiry Date', hintText: 'MM/YY', border: OutlineInputBorder()),
                    validator: (value) => value == null || !value.contains('/') ? 'Enter MM/YY' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.length < 3 ? 'Enter CVV' : null,
                  ),
                ),
              ],
            ),
          ] else if (_paymentMethod == 'UPI') ...[
            TextFormField(
              controller: _upiController,
              decoration: const InputDecoration(labelText: 'UPI VPA ID', hintText: 'username@okaxis', border: OutlineInputBorder(), prefixIcon: Icon(Icons.alternate_email)),
              validator: (value) => value == null || !value.contains('@') ? 'Enter valid UPI ID' : null,
            ),
          ] else ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Choose Bank', border: OutlineInputBorder(), prefixIcon: Icon(Icons.account_balance)),
              initialValue: 'State Bank of India',
              items: ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank'].map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
              onChanged: (_) {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummaryMini(CartProvider provider, bool isDark) {
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
          const Text('Checkout Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...provider.items.values.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} (x${item.quantity})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                '₹${provider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitCTA(CartProvider cart, OrderProvider order, ProductProvider product) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: cart.items.isEmpty ? null : () => _processCheckout(cart, order, product),
      child: const Text('AUTHORIZE MOCK TRANSACTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}
