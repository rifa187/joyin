import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORT UTILS & PROVIDERS
// Pastikan Anda sudah membuat file formatters.dart sesuai langkah 1 di atas.
// Jika belum, copas class CreditCardNumberFormatter ke bagian paling bawah file ini.
import 'package:joyin/utils/formatters.dart'; 
import 'package:joyin/dashboard/dashboard_page.dart';
import 'package:joyin/providers/user_provider.dart';

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
  int _selectedPaymentMethodIndex = 3; // Default ke QRIS atau Transfer
  int? _selectedBankIndex;
  int? _selectedEWalletIndex;
  bool _isLoading = false; // Untuk loading state saat tombol ditekan

  final Color _brandColor = const Color(0xFF4DB6AC); // Warna Hijau Joyin

  final List<Map<String, dynamic>> _paymentMethods = [
    {'label': 'Kartu Kredit', 'icon': Icons.credit_card},
    {'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'label': 'E-Wallet', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'QRIS', 'icon': Icons.qr_code},
  ];

  // Pastikan Anda memiliki gambar-gambar ini di folder assets/images/
  // Jika tidak ada, kode akan error atau gambar blank.
  final List<Map<String, dynamic>> _bankOptions = [
    {'name': 'BCA', 'asset': 'assets/images/BCA.png', 'height': 40.0},
    {'name': 'Mandiri', 'asset': 'assets/images/mandiri.png', 'height': 30.0},
    {'name': 'BNI', 'asset': 'assets/images/BNI.png', 'height': 25.0},
    {'name': 'BRI', 'asset': 'assets/images/BRI.png', 'height': 30.0},
  ];

  final List<Map<String, dynamic>> _eWalletOptions = [
    {'name': 'GoPay', 'asset': 'assets/images/gopay.png', 'height': 30.0},
    {'name': 'OVO', 'asset': 'assets/images/OVO.png', 'height': 25.0},
    {'name': 'DANA', 'asset': 'assets/images/DANA.png', 'height': 25.0},
    {'name': 'ShopeePay', 'asset': 'assets/images/Shopeepay.png', 'height': 30.0},
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Paket yang Dipilih', Icons.inventory_2_outlined),
            const SizedBox(height: 16),
            _buildPackageCard(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Durasi Langganan', Icons.schedule),
            const SizedBox(height: 16),
            _buildDurationSelector(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Metode Pembayaran', Icons.payment),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            
            const SizedBox(height: 24),
            // Form Dinamis berdasarkan metode yang dipilih
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey<int>(_selectedPaymentMethodIndex),
                children: [
                  if (_selectedPaymentMethodIndex == 0) _buildCreditCardForm(),
                  if (_selectedPaymentMethodIndex == 1) _buildBankTransferOptions(),
                  if (_selectedPaymentMethodIndex == 2) _buildEWalletOptions(),
                  if (_selectedPaymentMethodIndex == 3) _buildQrisView(),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildPriceDetails(),
            
            const SizedBox(height: 32),
            _buildPayButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _brandColor, size: 24),
        const SizedBox(width: 10),
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
    final cardGradient = LinearGradient(
      colors: [const Color(0xFF66BB6A), _brandColor], // Gradien Hijau
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _brandColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
              decoration: BoxDecoration(gradient: cardGradient),
              child: Column(
                children: [
                  Text(
                    'Paket ${widget.packageName}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
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
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: widget.packageFeatures.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: _brandColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Durasi Langganan',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              _buildCircleBtn(
                icon: Icons.remove,
                onTap: () {
                  if (_duration > 1) setState(() => _duration--);
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_duration Bulan',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildCircleBtn(
                icon: Icons.add,
                onTap: () {
                  if (_duration < 12) setState(() => _duration++);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20, color: Colors.black54),
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9, // Sedikit lebih tinggi
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? _brandColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _brandColor : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  method['icon'],
                  color: isSelected ? _brandColor : Colors.grey[400],
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  method['label'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? _brandColor : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- FORM WIDGETS ---

  Widget _buildQrisView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_scanner, size: 80, color: Colors.black87),
          const SizedBox(height: 10),
          Text(
            "Scan QRIS untuk Bayar",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            "Mendukung GoPay, OVO, Dana, ShopeePay, BCA, dll",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildTextField(label: 'Nomor Kartu', hint: '0000 0000 0000 0000', formatter: CreditCardNumberFormatter()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Expiry', hint: 'MM/YY')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(label: 'CVV', hint: '123')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(label: 'Nama Pemilik', hint: 'Nama di kartu'),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, TextInputFormatter? formatter}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 6),
        TextFormField(
          inputFormatters: formatter != null ? [formatter] : [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _brandColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferOptions() {
    return _buildSelectionList(_bankOptions, _selectedBankIndex, (val) {
      setState(() => _selectedBankIndex = val);
    });
  }

  Widget _buildEWalletOptions() {
    return _buildSelectionList(_eWalletOptions, _selectedEWalletIndex, (val) {
      setState(() => _selectedEWalletIndex = val);
    });
  }

  Widget _buildSelectionList(List<Map<String, dynamic>> items, int? selectedIndex, ValueChanged<int?> onChanged) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return RadioListTile<int>(
          value: index,
          groupValue: selectedIndex,
          onChanged: onChanged,
          activeColor: _brandColor,
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.white,
          selectedTileColor: _brandColor.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            children: [
              // Placeholder Image jika asset tidak ketemu agar tidak error
              Image.asset(
                item['asset'], 
                height: item['height'], 
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 24, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }),
    );
  }

  // --- TOTAL & BUTTON ---

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Widget _buildPriceDetails() {
    final cleanPriceString = widget.packagePrice.replaceAll(RegExp(r'[^0-9]'), '');
    final pricePerMonth = double.tryParse(cleanPriceString) ?? 0;
    final subtotal = pricePerMonth * _duration;
    final ppn = subtotal * 0.12; // PPN 12%
    final total = subtotal + ppn;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildPriceRow('Harga Paket', 'Rp ${_formatCurrency(pricePerMonth)} /bln'),
          _buildPriceRow('Durasi', '$_duration Bulan'),
          const Divider(height: 24),
          _buildPriceRow('Subtotal', 'Rp ${_formatCurrency(subtotal)}'),
          _buildPriceRow('PPN (12%)', 'Rp ${_formatCurrency(ppn)}'),
          const Divider(height: 24, thickness: 1.5),
          _buildPriceRow('Total Tagihan', 'Rp ${_formatCurrency(total)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: isTotal ? Colors.black : Colors.grey[600], fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isTotal ? _brandColor : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    final cleanPriceString = widget.packagePrice.replaceAll(RegExp(r'[^0-9]'), '');
    final pricePerMonth = double.tryParse(cleanPriceString) ?? 0;
    final total = (pricePerMonth * _duration) * 1.12; // Termasuk PPN

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          setState(() => _isLoading = true);
          
          // Simulasi Loading Pembayaran
          await Future.delayed(const Duration(seconds: 2));

          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final navigator = Navigator.of(context);
          final prefs = await SharedPreferences.getInstance();

          // Simpan Data ke SharedPrefs (Biar persisten saat restart app)
          await prefs.setBool('has_purchased_package', true);
          await prefs.setString('selected_package', widget.packageName);
          await prefs.setInt('selected_package_duration_months', _duration);

          if (!mounted) return;

          // Update State Global
          final currentUser = userProvider.user!;
          final updatedUser = currentUser.copyWith(
            hasPurchasedPackage: true,
            packageDurationMonths: _duration,
          );
          userProvider.setUser(updatedUser);

          // Tampilkan Dialog Sukses
          if (mounted) {
            showDialog(
              context: context, 
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: _brandColor, size: 80),
                    const SizedBox(height: 20),
                    Text("Pembayaran Berhasil!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Selamat, paket ${widget.packageName} Anda sudah aktif.", textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _brandColor),
                        onPressed: () => navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const DashboardPage()),
                          (route) => false,
                        ),
                        child: const Text("Kembali ke Dashboard", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              )
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          shadowColor: _brandColor.withOpacity(0.4),
        ),
        child: _isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text('Bayar Sekarang - Rp ${_formatCurrency(total)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}