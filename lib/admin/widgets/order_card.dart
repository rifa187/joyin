import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../models/admin_order.dart';

class OrderCard extends StatelessWidget {
  final AdminOrder order;
  final VoidCallback onSeeDetail;
  final VoidCallback onSeeProof;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OrderCard({
    super.key,
    required this.order,
    required this.onSeeDetail,
    required this.onSeeProof,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    order.id.toString(),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(order.phone, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          
          // Body Card
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.packageName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(order.paymentStatus, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(order.createdAt.toIso8601String().substring(0, 16), style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('Bukti transfer', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSeeProof,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border.withOpacity(0.8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Lihat Bukti', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onSeeDetail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border.withOpacity(0.8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Lihat Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Accept/Reject Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Terima', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Tolak', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final OrderStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, text, label) = switch (status) {
      OrderStatus.pending => (const Color(0xFFFFF4E5), const Color(0xFFE0A63C), 'Menunggu'),
      OrderStatus.confirmed => (const Color(0xFFE9F9F2), const Color(0xFF2E9961), 'Dikonfirmasi'),
      OrderStatus.rejected => (const Color(0xFFFEECEC), const Color(0xFFD64545), 'Ditolak'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: text.withOpacity(0.24)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(color: text, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}