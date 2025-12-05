import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/dashboard/dashboard_gate.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/user_provider.dart';

// Custom TextInputFormatter for credit card numbers (XXXX XXXX XXXX XXXX)
class CreditCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }

    final StringBuffer newText = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i % 4 == 0 && i > 0) {
        newText.write(' ');
      }
      newText.write(digitsOnly[i]);
    }

    final String formattedText = newText.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final String packageName;
  final String packagePrice;
  final List<String> packageFeatures;

  const PaymentScreen({
    super.key,
    required this.packageName,
    required this.packagePrice,
    required this.packageFeatures,
  });

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  int _duration = 1;
  int _selectedPaymentMethodIndex = 3;
  int? _selectedBankIndex;
  int? _selectedEWalletIndex;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'label': 'Kartu Kredit', 'icon': Icons.credit_card},
    {'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'label': 'E-Wallet', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'QRIS', 'icon': Icons.qr_code},
  ];

  final List<Map<String, dynamic>> _bankOptions = [
    {'name': 'BNI', 'asset': 'assets/images/BNI.png', 'height': 20.0},
    {'name': 'BCA', 'asset': 'assets/images/BCA.png', 'height': 60.0},
    {'name': 'BRI', 'asset': 'assets/images/BRI.png', 'height': 60.0},
    {'name': 'Mandiri', 'asset': 'assets/images/mandiri.png', 'height': 25.0},
  ];

  final List<Map<String, dynamic>> _eWalletOptions = [
    {'name': 'gopay', 'asset': 'assets/images/gopay.png', 'height': 40.0},
    {'name': 'DANA', 'asset': 'assets/images/DANA.png', 'height': 25.0},
    {
      'name': 'ShopeePay',
      'asset': 'assets/images/Shopeepay.png',
      'height': 30.0,
    },
    {'name': 'OVO', 'asset': 'assets/images/OVO.png', 'height': 25.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                'Paket yang Dipilih',
                Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 16),
              _buildPackageCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Durasi', Icons.schedule),
              const SizedBox(height: 16),
              _buildDurationSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'Metode Pembayaran',
                Icons.monetization_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              if (_selectedPaymentMethodIndex == 0) _buildCreditCardForm(),
              if (_selectedPaymentMethodIndex == 1) _buildBankTransferOptions(),
              if (_selectedPaymentMethodIndex == 2) _buildEWalletOptions(),
              const SizedBox(height: 24),
              _buildPriceDetails(),
              const SizedBox(height: 32),
              _buildPayButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5FCAAC), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard() {
    const cardGradient = LinearGradient(
      colors: [Color(0xFF9B51E0), Color(0xFF5FCAAC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(gradient: cardGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Paket ${widget.packageName}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.packagePrice,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: widget.packageFeatures
                    .map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check,
                              color: Color(0xFF5FCAAC),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                feature,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Per Bulan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDurationButton(
                icon: Icons.remove,
                onPressed: () {
                  if (_duration > 1) {
                    setState(() {
                      _duration--;
                    });
                  }
                },
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$_duration',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildDurationButton(
                icon: Icons.add,
                onPressed: () {
                  if (_duration < 12) {
                    setState(() {
                      _duration++;
                    });
                  }
                },
              ),
              const SizedBox(width: 10),
              Text(
                'Bulan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _paymentMethods.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final method = _paymentMethods[index];
        final isSelected = _selectedPaymentMethodIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethodIndex = index;
              _selectedBankIndex = null;
              _selectedEWalletIndex = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF5FCAAC) : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF5FCAAC).withAlpha(77),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  method['icon'],
                  color: isSelected
                      ? const Color(0xFF5FCAAC)
                      : Colors.grey[500],
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  method['label'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF5FCAAC)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'No. Kartu',
          hint: '',
          formatter: CreditCardNumberFormatter(),
        ),
        const SizedBox(height: 16),
        Text(
          'Tanggal Kadaluwarsa',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(label: '', hint: ''),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(label: '', hint: ''),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Nama di Kartu', hint: ''),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputFormatter? formatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextFormField(
          inputFormatters: formatter != null ? [formatter] : [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferOptions() {
    return Column(
      children: List.generate(_bankOptions.length, (index) {
        return _buildOptionRow(
          assetPath: _bankOptions[index]['asset']! as String,
          imageHeight: _bankOptions[index]['height']! as double,
          index: index,
          selectedIndex: _selectedBankIndex,
          onChanged: (val) {
            setState(() {
              _selectedBankIndex = val;
            });
          },
        );
      }),
    );
  }

  Widget _buildEWalletOptions() {
    return Column(
      children: List.generate(_eWalletOptions.length, (index) {
        return _buildOptionRow(
          assetPath: _eWalletOptions[index]['asset']! as String,
          imageHeight: _eWalletOptions[index]['height']! as double,
          index: index,
          selectedIndex: _selectedEWalletIndex,
          onChanged: (val) {
            setState(() {
              _selectedEWalletIndex = val;
            });
          },
        );
      }),
    );
  }

  Widget _buildOptionRow({
    required String assetPath,
    required double imageHeight,
    required int index,
    required int? selectedIndex,
    required ValueChanged<int?> onChanged,
  }) {
    return RadioGroup<int>(
      groupValue: selectedIndex,
      onChanged: onChanged,
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedIndex == index
                  ? const Color(0xFF5FCAAC)
                  : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(assetPath, height: imageHeight, fit: BoxFit.contain),
              Radio<int>(value: index, activeColor: const Color(0xFF5FCAAC)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    String priceStr = amount.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return priceStr.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  Widget _buildPriceDetails() {
    final cleanPriceString = widget.packagePrice.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final pricePerMonth = double.tryParse(cleanPriceString) ?? 0;
    final subtotal = pricePerMonth * _duration;
    final ppn = subtotal * 0.12;
    final total = subtotal + ppn;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Paket yang di pilih', 'Paket ${widget.packageName}'),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Harga per Bulan',
            'Rp. ${_formatCurrency(pricePerMonth)}',
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Durasi', '$_duration Bulan'),
          const SizedBox(height: 12),
          _buildPriceRow('Subtotal', 'Rp. ${_formatCurrency(subtotal)}'),
          const SizedBox(height: 12),
          _buildPriceRow('PPN (12%)', 'Rp. ${_formatCurrency(ppn)}'),
          const Divider(height: 24, thickness: 1),
          _buildPriceRow(
            'Total',
            'Rp. ${_formatCurrency(total)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isTotal ? Colors.black : Colors.black54,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    final cleanPriceString = widget.packagePrice.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final pricePerMonth = double.tryParse(cleanPriceString) ?? 0;
    final subtotal = pricePerMonth * _duration;
    final ppn = subtotal * 0.12;
    final total = subtotal + ppn;
    final formattedPrice = _formatCurrency(total);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final packageProvider = Provider.of<PackageProvider>(
            context,
            listen: false,
          );
          final navigator = Navigator.of(context);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_purchased_package', true);
          await prefs.setString('selected_package', widget.packageName);
          await prefs.setInt('selected_package_duration_months', _duration);

          if (!mounted) return;

          final currentUser = userProvider.user;
          if (currentUser != null) {
            final updatedUser = currentUser.copyWith(
              hasPurchasedPackage: true,
              packageDurationMonths: _duration,
            );
            userProvider.setUser(updatedUser);
          }

          // Tandai paket yang aktif di provider agar dashboard & profil langsung ter-update.
          packageProvider.loadCurrentUserPackage(widget.packageName);
          packageProvider.selectDuration(widget.packageName, _duration);

          if (!mounted) return;

          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardGate()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5FCAAC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: const Color(0xFF5FCAAC).withAlpha(102),
        ),
        child: Text(
          'Bayar Sekarang - Rp $formattedPrice',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
