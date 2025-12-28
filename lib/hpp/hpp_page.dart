import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/package_provider.dart';
import '../package/package_theme.dart';
import '../services/hpp_api_service.dart';
import '../widgets/locked_feature_widget.dart';
import 'hpp_model.dart';
import 'hpp_detail_page.dart';

class HppPage extends StatefulWidget {
  const HppPage({super.key});

  @override
  State<HppPage> createState() => _HppPageState();
}

class _HppPageState extends State<HppPage> {
  final HppApiService _hppApi = HppApiService();
  final List<HppItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _lastAccessToken;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().accessToken;
      if (token != null && token.isNotEmpty) {
        _fetchItems(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final accessToken = authProvider.accessToken;
    if (accessToken != null &&
        accessToken.isNotEmpty &&
        _lastAccessToken != accessToken) {
      _lastAccessToken = accessToken;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchItems(accessToken);
      });
    }

    final packageProvider = context.watch<PackageProvider>();
    final packageTheme =
        PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final accent = packageTheme.accent;
    final navColor = packageTheme.headerGradient.last;
    final navIconBrightness =
        navColor.computeLuminance() > 0.6 ? Brightness.dark : Brightness.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: navColor,
        systemNavigationBarIconBrightness: navIconBrightness,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          title: const SizedBox.shrink(),
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: packageTheme.headerGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroSection(accent),
                    const SizedBox(height: 18),
                    _buildFeatureHighlights(accent),
                    const SizedBox(height: 18),
                    _buildSummaryCard(accent),
                    const SizedBox(height: 18),
                    if (_isLocked)
                      _buildLockedCard()
                    else
                      _buildListCard(accent),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hitung HPP Produk & Jasa',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Susun biaya produksi, dapatkan HPP per unit, dan terima rekomendasi harga jual dari AI.',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildHeroChip(Icons.auto_graph_outlined, 'Rekomendasi AI'),
            _buildHeroChip(Icons.receipt_long_outlined, 'Total biaya lengkap'),
            _buildHeroChip(Icons.scale_outlined, 'HPP per unit'),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isLocked ? null : _openCreateSheet,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(
            'Tambah HPP',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: accent,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(Color accent) {
    final features = [
      (
        Icons.calculate_outlined,
        'Kalkulator HPP Otomatis',
        'Hitung seluruh biaya variabel dan biaya tetap secara akurat, tanpa ribet.',
      ),
      (
        Icons.auto_graph_outlined,
        '3 Rekomendasi Harga Jual Berbasis AI',
        'Dapatkan saran harga kompetitif, standar, dan premium sesuai kondisi bisnis kamu.',
      ),
      (
        Icons.trending_up_outlined,
        'Proyeksi Laba & Target Penjualan',
        'Ketahui berapa produk yang harus terjual untuk mencapai target keuntungan.',
      ),
      (
        Icons.folder_open_outlined,
        'Manajemen Worksheet',
        'Kelola HPP untuk banyak produk atau brand dalam satu dashboard yang rapi.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitur HPP',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(feature.$1, size: 18, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.$2,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.$3,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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

  Widget _buildSummaryCard(Color accent) {
    final totalItems = _items.length;
    final totalCost = _items.fold<int>(0, (sum, item) => sum + item.totalCost);
    final avgCost = totalItems == 0 ? 0.0 : totalCost / totalItems;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            title: 'Total Item',
            value: '$totalItems',
            color: accent,
          ),
          _buildSummaryItem(
            title: 'Total Biaya',
            value: _formatCurrency(totalCost.toDouble()),
            color: AppColors.textPrimary,
          ),
          _buildSummaryItem(
            title: 'Rata-rata HPP',
            value: _formatCurrency(avgCost),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const LockedFeatureWidget(
        title: 'Fitur HPP membutuhkan paket aktif',
        message:
            'Upgrade paket agar bisa menghitung HPP, melihat rekomendasi AI, dan menyimpan daftar produk.',
        icon: Icons.lock_outline,
      ),
    );
  }

  Widget _buildListCard(Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar HPP',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            _buildInfoText('Memuat data HPP...')
          else if (_error != null)
            _buildInfoText(_error!, isError: true)
          else if (_items.isEmpty)
            _buildInfoText('Belum ada data HPP. Tambahkan produk pertama kamu.')
          else
            Column(
              children: _items
                  .map((item) => _buildItemCard(item, accent))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String message, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isError ? AppColors.error : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildItemCard(HppItem item, Color accent) {
    final isService = item.type.toUpperCase() == 'SERVICE';
    final typeLabel = isService ? 'Jasa' : 'Produk';
    final chipColor = isService ? const Color(0xFF6C7BFF) : accent;

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    typeLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: chipColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.grey[600],
                  onPressed: () => _confirmDelete(item),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildKeyValueRow(
              'Total HPP',
              _formatCurrency(item.totalCost.toDouble()),
            ),
            const SizedBox(height: 6),
            _buildKeyValueRow(
              'HPP per Unit',
              '${_formatCurrency(item.costPerUnit)}${_formatUnit(item.unit)}',
            ),
            const SizedBox(height: 6),
            if (item.aiSuggestedPrice != null)
              _buildKeyValueRow(
                'Rekomendasi AI',
                _formatCurrency(item.aiSuggestedPrice!.toDouble()),
                valueColor: accent,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  _formatDate(item.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (item.aiRecommendation != null &&
                    item.aiRecommendation!.isNotEmpty)
                  TextButton(
                    onPressed: () => _showAiDetail(item),
                    child: Text(
                      'Lihat alasan',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(?=(\d{3})+(?!\d))'),
          (match) => '${match[0]}.',
        )}';
  }

  String _formatUnit(String? unit) {
    if (unit == null || unit.trim().isEmpty) return '';
    return ' / ${unit.trim()}';
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _fetchItems(String accessToken) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _isLocked = false;
    });

    try {
      final items = await _hppApi.fetchItems(accessToken);
      if (mounted) {
        setState(() {
          _items
            ..clear()
            ..addAll(items);
        });
      }
    } on HppApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLocked = e.statusCode == 403;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openCreateSheet() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final unitController = TextEditingController();
    final materialController = TextEditingController(text: '0');
    final laborController = TextEditingController(text: '0');
    final overheadController = TextEditingController(text: '0');
    final otherController = TextEditingController(text: '0');

    String type = 'PRODUCT';
    bool useAi = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final quantity =
                double.tryParse(qtyController.text.replaceAll(',', '.')) ?? 1;
            final material = _parseInt(materialController.text);
            final labor = _parseInt(laborController.text);
            final overhead = _parseInt(overheadController.text);
            final other = _parseInt(otherController.text);
            final total = material + labor + overhead + other;
            final perUnit = total / (quantity <= 0 ? 1 : quantity);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tambah HPP',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Nama Produk/Jasa',
                      controller: nameController,
                      hint: 'Contoh: Kopi Susu 250ml',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Tipe',
                      value: type,
                      items: const [
                        DropdownMenuItem(value: 'PRODUCT', child: Text('Produk')),
                        DropdownMenuItem(value: 'SERVICE', child: Text('Jasa')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => type = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Quantity',
                            controller: qtyController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\\.]'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            label: 'Unit',
                            controller: unitController,
                            hint: 'pcs / jam',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Biaya Bahan',
                      controller: materialController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Tenaga Kerja',
                      controller: laborController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Overhead',
                      controller: overheadController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Biaya Lainnya',
                      controller: otherController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildKeyValueRow(
                            'Total Biaya',
                            _formatCurrency(total.toDouble()),
                          ),
                          const SizedBox(height: 6),
                          _buildKeyValueRow(
                            'HPP per Unit',
                            _formatCurrency(perUnit),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: useAi,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Minta rekomendasi AI',
                        style: GoogleFonts.poppins(fontSize: 12.5),
                      ),
                      onChanged: (value) =>
                          setSheetState(() => useAi = value),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setSheetState(() => isSaving = true);
                              final created = await _createItem(
                                name: nameController.text,
                                type: type,
                                quantity: qtyController.text,
                                unit: unitController.text,
                                materialCost: materialController.text,
                                laborCost: laborController.text,
                                overheadCost: overheadController.text,
                                otherCost: otherController.text,
                                useAi: useAi,
                              );
                              if (created != null && mounted) {
                                Navigator.of(context).pop();
                              } else {
                                setSheetState(() => isSaving = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.joyin,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Simpan & Hitung',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  int _parseInt(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<HppItem?> _createItem({
    required String name,
    required String type,
    required String quantity,
    required String unit,
    required String materialCost,
    required String laborCost,
    required String overheadCost,
    required String otherCost,
    required bool useAi,
  }) async {
    final accessToken = context.read<AuthProvider>().accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showSnack('Sesi kamu berakhir, silakan login kembali.');
      return null;
    }

    try {
      final payload = {
        'name': name.trim(),
        'type': type,
        'quantity': quantity,
        'unit': unit.trim(),
        'materialCost': _parseInt(materialCost),
        'laborCost': _parseInt(laborCost),
        'overheadCost': _parseInt(overheadCost),
        'otherCost': _parseInt(otherCost),
        'useAi': useAi,
      };

      final created = await _hppApi.createItem(
        accessToken: accessToken,
        payload: payload,
      );

      if (mounted) {
        setState(() {
          _items.insert(0, created);
        });
      }
      _showSnack('HPP berhasil disimpan.');
      return created;
    } on HppApiException catch (e) {
      _showSnack(e.message, isError: true);
      if (e.statusCode == 403 && mounted) {
        setState(() => _isLocked = true);
      }
      return null;
    } catch (e) {
      _showSnack('Gagal menyimpan HPP: $e', isError: true);
      return null;
    }
  }

  void _confirmDelete(HppItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus HPP', style: GoogleFonts.poppins()),
          content: Text(
            'Yakin mau hapus "${item.name}"?',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteItem(item);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(HppItem item) async {
    final accessToken = context.read<AuthProvider>().accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await _hppApi.deleteItem(accessToken: accessToken, id: item.id);
      if (mounted) {
        setState(() => _items.removeWhere((e) => e.id == item.id));
      }
      _showSnack('HPP dihapus.');
    } on HppApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Gagal menghapus HPP: $e', isError: true);
    }
  }

  void _openDetail(HppItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HppDetailPage(
          itemId: item.id,
          initialItem: item,
          onUpdated: (updated) {
            final index = _items.indexWhere((e) => e.id == updated.id);
            if (index != -1) {
              setState(() => _items[index] = updated);
            }
          },
        ),
      ),
    );
  }

  void _showAiDetail(HppItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rekomendasi AI', style: GoogleFonts.poppins()),
          content: Text(
            item.aiRecommendation ?? '-',
            style: GoogleFonts.poppins(fontSize: 12.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? AppColors.error : AppColors.joyin,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
