import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

enum OrderStatus { pending, confirmed, rejected }

class AdminOrder {
  final int id;
  final String customerName;
  final String phone;
  final String packageName;
  final String paymentStatus;
  final double amount;
  final DateTime createdAt;
  final String transferNote;
  final OrderStatus status;

  const AdminOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.packageName,
    required this.paymentStatus,
    required this.amount,
    required this.createdAt,
    required this.transferNote,
    required this.status,
  });

  AdminOrder copyWith({OrderStatus? status}) {
    return AdminOrder(
      id: id,
      customerName: customerName,
      phone: phone,
      packageName: packageName,
      paymentStatus: paymentStatus,
      amount: amount,
      createdAt: createdAt,
      transferNote: transferNote,
      status: status ?? this.status,
    );
  }
}

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage>
    with SingleTickerProviderStateMixin {
  final List<AdminOrder> _orders = [
    AdminOrder(
      id: 1,
      customerName: 'Andin Nugraha',
      phone: '0812-3456-7890',
      packageName: 'Paket Basic',
      paymentStatus: 'Menunggu konfirmasi',
      amount: 543900,
      createdAt: DateTime(2025, 11, 25, 9, 12),
      transferNote: 'm-Transfer berhasil 15/05 00:49:01\nBUKALAPAK',
      status: OrderStatus.pending,
    ),
    AdminOrder(
      id: 2,
      customerName: 'Bella Nadhira',
      phone: '0812-7788-8899',
      packageName: 'Paket Basic',
      paymentStatus: 'Lunas',
      amount: 543900,
      createdAt: DateTime(2025, 11, 25, 10, 45),
      transferNote: 'VA BCA • 1234567890',
      status: OrderStatus.confirmed,
    ),
    AdminOrder(
      id: 3,
      customerName: 'Fajar Nugraha',
      phone: '0813-2345-0011',
      packageName: 'Paket Basic',
      paymentStatus: 'Menunggu konfirmasi',
      amount: 543900,
      createdAt: DateTime(2025, 11, 25, 12, 58),
      transferNote: 'Konfirmasi manual via CS',
      status: OrderStatus.pending,
    ),
    AdminOrder(
      id: 4,
      customerName: 'Hendra Saputra',
      phone: '0819-2211-8811',
      packageName: 'Paket Basic',
      paymentStatus: 'Lunas',
      amount: 543900,
      createdAt: DateTime(2025, 11, 25, 13, 27),
      transferNote: 'QRIS - Midtrans',
      status: OrderStatus.confirmed,
    ),
  ];

  String _query = '';
  late final AnimationController _introController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _searchFade;
  late final Animation<Offset> _searchSlide;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _headerFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _searchFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.12, 0.6, curve: Curves.easeOut),
    );
    _searchSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.12, 0.7, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _orders.where((order) {
      final q = _query.toLowerCase();
      return order.customerName.toLowerCase().contains(q) ||
          order.packageName.toLowerCase().contains(q) ||
          order.phone.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.grad1, AppColors.grad3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Kelola Pesanan',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withValues(alpha: 0.18),
                            child: const Icon(Icons.support_agent, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: _searchFade,
                    child: SlideTransition(
                      position: _searchSlide,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Cari nama, paket, atau nomor',
                                  hintStyle: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                onChanged: (value) => setState(() => _query = value),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: filtered.isEmpty
                          ? _EmptyState(query: _query)
                          : ListView.builder(
                              key: ValueKey('${filtered.length}-${_query.trim()}'),
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final order = filtered[index];
                                final animation = _buildCardAnimation(index);
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    final value = animation.value;
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 18 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _OrderCard(
                                    order: order,
                                    onSeeDetail: () => _showOrderDetail(order),
                                    onSeeProof: () => _showOrderDetail(order),
                                    onAccept: () => _updateStatus(order, OrderStatus.confirmed),
                                    onReject: () => _updateStatus(order, OrderStatus.rejected),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Animation<double> _buildCardAnimation(int index) {
    final start = _clampDouble(0.2 + (index * 0.08), 0.0, 0.78);
    final end = _clampDouble(start + 0.35, 0.3, 1.0);
    return CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _updateStatus(AdminOrder order, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx == -1) return;
    setState(() {
      _orders[idx] = order.copyWith(status: status);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == OrderStatus.confirmed
              ? 'Pesanan dikonfirmasi.'
              : 'Pesanan ditolak.',
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: status == OrderStatus.confirmed ? AppColors.success : AppColors.error,
      ),
    );
  }

  void _showOrderDetail(AdminOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: child,
              ),
            );
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Text(
                        'Pemesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(label: 'Nama Pemesan', value: order.customerName),
                      _DetailRow(label: 'No. WhatsApp', value: order.phone),
                      _DetailRow(label: 'Paket', value: order.packageName),
                      _DetailRow(label: 'Jumlah Pembayaran', value: _formatCurrency(order.amount)),
                      _DetailRow(label: 'Status Pembayaran', value: order.paymentStatus),
                      _DetailRow(
                        label: 'Waktu',
                        value: order.createdAt.toIso8601String().substring(0, 16),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bukti Transfer',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  child: Text(
                                    order.transferNote,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _updateStatus(order, OrderStatus.rejected);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error, width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Tolak', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _updateStatus(order, OrderStatus.confirmed);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.joyin,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                order.status == OrderStatus.confirmed ? 'Batalkan Konfirmasi' : 'Konfirmasi Pesanan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (match) => '${match[0]}.')}';
  }
}

class _OrderCard extends StatefulWidget {
  final AdminOrder order;
  final VoidCallback onSeeDetail;
  final VoidCallback onSeeProof;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _OrderCard({
    required this.order,
    required this.onSeeDetail,
    required this.onSeeProof,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  bool _acceptPressed = false;
  bool _rejectPressed = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != widget.order.status) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final accent = _statusAccent(order.status);

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final glowStrength = 0.12 + (0.25 * _pulse.value);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: accent.withValues(alpha: 0.14 + (0.2 * _pulse.value)),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: accent.withValues(alpha: glowStrength),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    order.id.toString(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.phone,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.packageName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.paymentStatus,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.createdAt.toIso8601String().substring(0, 16),
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bukti transfer',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onSeeProof,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Lihat Bukti', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onSeeDetail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Lihat Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => _setAcceptPressed(true),
                  onTapUp: (_) => _setAcceptPressed(false),
                  onTapCancel: () => _setAcceptPressed(false),
                  child: AnimatedScale(
                    scale: _acceptPressed ? 0.97 : 1,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: ElevatedButton(
                      onPressed: widget.onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Terima',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => _setRejectPressed(true),
                  onTapUp: (_) => _setRejectPressed(false),
                  onTapCancel: () => _setRejectPressed(false),
                  child: AnimatedScale(
                    scale: _rejectPressed ? 0.97 : 1,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: ElevatedButton(
                      onPressed: widget.onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Tolak',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  void _setAcceptPressed(bool value) {
    if (_acceptPressed == value) return;
    setState(() => _acceptPressed = value);
  }

  void _setRejectPressed(bool value) {
    if (_rejectPressed == value) return;
    setState(() => _rejectPressed = value);
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  Color _statusAccent(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => const Color(0xFFE0A63C),
      OrderStatus.confirmed => const Color(0xFF2E9961),
      OrderStatus.rejected => const Color(0xFFD64545),
    };
  }
}

class _StatusChip extends StatefulWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _syncPulse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncPulse() {
    if (widget.status == OrderStatus.pending) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, text, label) = switch (widget.status) {
      OrderStatus.pending => (const Color(0xFFFFF4E5), const Color(0xFFE0A63C), 'Menunggu konfirmasi'),
      OrderStatus.confirmed => (const Color(0xFFE9F9F2), const Color(0xFF2E9961), 'Telah dikonfirmasi'),
      OrderStatus.rejected => (const Color(0xFFFEECEC), const Color(0xFFD64545), 'Ditolak'),
    };

    final Animation<double> pulseScale = widget.status == OrderStatus.pending
        ? Tween<double>(begin: 0.98, end: 1.04).animate(_pulse)
        : const AlwaysStoppedAnimation<double>(1);

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: ScaleTransition(
          scale: pulseScale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: text.withValues(alpha: 0.24)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.status == OrderStatus.pending)
                  FadeTransition(
                    opacity: _pulse,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.2).animate(_pulse),
                      child: Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: text,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    label,
                    key: ValueKey(label),
                    style: GoogleFonts.poppins(
                      color: text,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final message = query.trim().isEmpty
        ? 'Belum ada pesanan yang masuk.'
        : 'Pesanan dengan kata kunci tersebut tidak ditemukan.';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textSecondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian.',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
