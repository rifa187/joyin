import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../models/admin_order.dart';

class OrderDetailSheet extends StatelessWidget {
  final AdminOrder order;
  final Function(AdminOrder, OrderStatus) onUpdateStatus;

  const OrderDetailSheet({super.key, required this.order, required this.onUpdateStatus});

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (match) => '${match[0]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -4))],
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.black.withOpacity(0.08), borderRadius: BorderRadius.circular(8)))),
                
                Text('Detail Pemesanan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
                const SizedBox(height: 14),
                
                DetailRow(label: 'Nama Pemesan', value: order.customerName),
                DetailRow(label: 'No. WhatsApp', value: order.phone),
                DetailRow(label: 'Paket', value: order.packageName),
                DetailRow(label: 'Total', value: _formatCurrency(order.amount)),
                DetailRow(label: 'Status', value: order.paymentStatus),
                
                const SizedBox(height: 12),
                Text('Bukti Transfer', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF7F8FB), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Text(order.transferNote, style: GoogleFonts.poppins(color: AppColors.textPrimary, height: 1.4)),
                ),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () { Navigator.pop(context); onUpdateStatus(order, OrderStatus.rejected); },
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Tolak', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () { Navigator.pop(context); onUpdateStatus(order, OrderStatus.confirmed); },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.joyin, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Terima', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12.5))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}