import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/package_provider.dart';
import '../package/package_theme.dart';
import '../services/hpp_api_service.dart';
import 'hpp_model.dart';

class HppDetailPage extends StatefulWidget {
  final int itemId;
  final HppItem initialItem;
  final ValueChanged<HppItem>? onUpdated;

  const HppDetailPage({
    super.key,
    required this.itemId,
    required this.initialItem,
    this.onUpdated,
  });

  @override
  State<HppDetailPage> createState() => _HppDetailPageState();
}

class _HppDetailPageState extends State<HppDetailPage> {
  final HppApiService _hppApi = HppApiService();
  HppItem? _item;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final packageTheme =
        PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final accent = packageTheme.accent;
    final navColor = packageTheme.headerGradient.last;
    final navIconBrightness =
        navColor.computeLuminance() > 0.6 ? Brightness.dark : Brightness.light;
    final item = _item;

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
                    Text(
                      'Detail HPP',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pantau komposisi biaya dan rekomendasi harga jual untuk item kamu.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      _buildInfoCard('Memuat detail HPP...')
                    else if (_error != null)
                      _buildInfoCard(_error!, isError: true)
                    else if (item != null)
                      ...[
                        _buildHeaderCard(item, accent),
                        const SizedBox(height: 16),
                        _buildCostBreakdown(item),
                        const SizedBox(height: 16),
                        _buildAiCard(item, accent),
                        const SizedBox(height: 16),
                        _buildActionRow(item, accent),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String message, {bool isError = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          color: isError ? AppColors.error : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildHeaderCard(HppItem item, Color accent) {
    final isService = item.type.toUpperCase() == 'SERVICE';
    final chipColor = isService ? const Color(0xFF6C7BFF) : accent;
    final typeLabel = isService ? 'Jasa' : 'Produk';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
            ],
          ),
          const SizedBox(height: 12),
          _buildKeyValueRow('Quantity',
              '${item.quantity.toStringAsFixed(2)}${_formatUnit(item.unit)}'),
          const SizedBox(height: 6),
          _buildKeyValueRow(
            'Total HPP',
            _formatCurrency(item.totalCost.toDouble()),
            valueColor: accent,
          ),
          const SizedBox(height: 6),
          _buildKeyValueRow(
            'HPP per Unit',
            _formatCurrency(item.costPerUnit),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdown(HppItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Rincian Biaya',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildKeyValueRow('Bahan', _formatCurrency(item.materialCost.toDouble())),
          const SizedBox(height: 6),
          _buildKeyValueRow('Tenaga Kerja', _formatCurrency(item.laborCost.toDouble())),
          const SizedBox(height: 6),
          _buildKeyValueRow('Overhead', _formatCurrency(item.overheadCost.toDouble())),
          const SizedBox(height: 6),
          _buildKeyValueRow('Biaya Lain', _formatCurrency(item.otherCost.toDouble())),
        ],
      ),
    );
  }

  Widget _buildAiCard(HppItem item, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.auto_graph_outlined, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                'Rekomendasi AI',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildKeyValueRow(
            'Harga Saran',
            item.aiSuggestedPrice == null
                ? '-'
                : _formatCurrency(item.aiSuggestedPrice!.toDouble()),
            valueColor: accent,
          ),
          const SizedBox(height: 6),
          _buildKeyValueRow(
            'Margin',
            item.aiSuggestedMargin == null
                ? '-'
                : '${item.aiSuggestedMargin!.toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 6),
          _buildKeyValueRow(
            'Markup',
            item.aiSuggestedMarkup == null
                ? '-'
                : '${item.aiSuggestedMarkup!.toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 12),
          if (item.aiRecommendation != null && item.aiRecommendation!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                item.aiRecommendation!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Text(
              'Belum ada rekomendasi AI. Coba refresh di bawah.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow(HppItem item, Color accent) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openEditSheet(item),
            icon: const Icon(Icons.edit_outlined),
            label: Text(
              'Edit',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _refreshAiRecommendation,
            icon: const Icon(Icons.refresh),
            label: Text(
              'Refresh AI',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
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

  Future<void> _fetchDetail() async {
    final accessToken = context.read<AuthProvider>().accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final item = await _hppApi.fetchItem(
        accessToken: accessToken,
        id: widget.itemId,
      );
      if (mounted) {
        setState(() => _item = item);
      }
    } on HppApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
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

  Future<void> _refreshAiRecommendation() async {
    final accessToken = context.read<AuthProvider>().accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final updated = await _hppApi.updateItem(
        accessToken: accessToken,
        id: widget.itemId,
        payload: {'refreshAi': true},
      );
      if (mounted) {
        setState(() => _item = updated);
      }
      widget.onUpdated?.call(updated);
      _showSnack('Rekomendasi AI diperbarui.');
    } on HppApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Gagal refresh AI: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openEditSheet(HppItem item) {
    final nameController = TextEditingController(text: item.name);
    final qtyController =
        TextEditingController(text: item.quantity.toStringAsFixed(2));
    final unitController = TextEditingController(text: item.unit ?? '');
    final materialController =
        TextEditingController(text: item.materialCost.toString());
    final laborController = TextEditingController(text: item.laborCost.toString());
    final overheadController =
        TextEditingController(text: item.overheadCost.toString());
    final otherController = TextEditingController(text: item.otherCost.toString());

    String type = item.type.toUpperCase();
    bool refreshAi = false;
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
                      'Edit HPP',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Nama Produk/Jasa',
                      controller: nameController,
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
                                RegExp(r'[0-9\.]'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            label: 'Unit',
                            controller: unitController,
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
                      value: refreshAi,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Refresh rekomendasi AI',
                        style: GoogleFonts.poppins(fontSize: 12.5),
                      ),
                      onChanged: (value) =>
                          setSheetState(() => refreshAi = value),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setSheetState(() => isSaving = true);
                              final updated = await _updateItem(
                                name: nameController.text,
                                type: type,
                                quantity: qtyController.text,
                                unit: unitController.text,
                                materialCost: materialController.text,
                                laborCost: laborController.text,
                                overheadCost: overheadController.text,
                                otherCost: otherController.text,
                                refreshAi: refreshAi,
                              );
                              if (updated != null && mounted) {
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
                              'Simpan Perubahan',
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

  Future<HppItem?> _updateItem({
    required String name,
    required String type,
    required String quantity,
    required String unit,
    required String materialCost,
    required String laborCost,
    required String overheadCost,
    required String otherCost,
    required bool refreshAi,
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
        if (refreshAi) 'refreshAi': true,
      };

      final updated = await _hppApi.updateItem(
        accessToken: accessToken,
        id: widget.itemId,
        payload: payload,
      );

      if (mounted) {
        setState(() => _item = updated);
      }
      widget.onUpdated?.call(updated);
      _showSnack('HPP berhasil diperbarui.');
      return updated;
    } on HppApiException catch (e) {
      _showSnack(e.message, isError: true);
      return null;
    } catch (e) {
      _showSnack('Gagal update HPP: $e', isError: true);
      return null;
    }
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
