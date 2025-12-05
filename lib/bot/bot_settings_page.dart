import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import '../package/package_theme.dart';

class BotSettingsPage extends StatefulWidget {
  const BotSettingsPage({super.key});

  @override
  State<BotSettingsPage> createState() => _BotSettingsPageState();
}

class _BotSettingsPageState extends State<BotSettingsPage> {
  // --- CONTROLLERS (Untuk mengambil teks input) ---
  final TextEditingController _botNameController = TextEditingController();
  final TextEditingController _welcomeMsgController = TextEditingController();
  final TextEditingController _fallbackMsgController = TextEditingController();
  final TextEditingController _delayController = TextEditingController();
  final TextEditingController _outOfHoursMsgController = TextEditingController();

  // --- STATES (Untuk Switch On/Off) ---
  bool _isBotActive = true;
  bool _isWorkingHoursActive = false;

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar tidak memakan memori
    _botNameController.dispose();
    _welcomeMsgController.dispose();
    _fallbackMsgController.dispose();
    _delayController.dispose();
    _outOfHoursMsgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage = packageProvider.currentUserPackage != null &&
        packageProvider.currentUserPackage!.isNotEmpty;
    final packageTheme = PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final double topPadding = MediaQuery.of(context).padding.top;
    const double headerHeight = 200;
    final double contentTop = topPadding + 100;
    final double contentHeight = MediaQuery.of(context).size.height - contentTop;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: packageTheme.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: packageTheme.headerGradient,
                ),
              ),
              padding: EdgeInsets.only(top: topPadding + 16, left: 20, right: 20),
              alignment: Alignment.topCenter,
              child: Text(
                'Pengaturan Bot',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: contentTop),
              height: contentHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: hasPackage
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildSectionCard(
                              title: "Pengaturan Umum",
                              accent: packageTheme.accent,
                              children: [
                                _buildTextField(
                                  label: "Nama Bot",
                                  controller: _botNameController,
                                  hint: "Masukkan nama bot kamu",
                                  accent: packageTheme.accent,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  label: "Pesan Selamat Datang",
                                  controller: _welcomeMsgController,
                                  maxLines: 3,
                                  hint: "Halo! Ada yang bisa saya bantu?",
                                  accent: packageTheme.accent,
                                ),
                                const SizedBox(height: 20),
                                _buildSwitchRow("Aktifkan Bot", _isBotActive, (val) {
                                  setState(() => _isBotActive = val);
                                }, packageTheme.accent),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSectionCard(
                              title: "Pengaturan Balasan Otomatis",
                              accent: packageTheme.accent,
                              children: [
                                _buildTextField(
                                  label: "Pesan Fallback",
                                  controller: _fallbackMsgController,
                                  maxLines: 3,
                                  hint: "Maaf, kami akan segera menghubungi kamu!",
                                  accent: packageTheme.accent,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  label: "Delay Balasan (detik)",
                                  controller: _delayController,
                                  keyboardType: TextInputType.number,
                                  hint: "Contoh: 3",
                                  accent: packageTheme.accent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSectionCard(
                              title: "Jam Kerja Bot",
                              accent: packageTheme.accent,
                              children: [
                                _buildSwitchRow(
                                    "Aktifkan Jam Kerja", _isWorkingHoursActive, (val) {
                                  setState(() => _isWorkingHoursActive = val);
                                }, packageTheme.accent),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  label: "Pesan di luar jam kerja",
                                  controller: _outOfHoursMsgController,
                                  maxLines: 3,
                                  hint: "Halo! Tim kami akan balas di jam kerja.",
                                  accent: packageTheme.accent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: packageTheme.accent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Simpan Pengaturan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: LockedFeatureWidget(
                        title: 'Fitur Terkunci',
                        message: 'Upgrade paketmu untuk membuka pengaturan bot.',
                        icon: Icons.smart_toy_outlined,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    Color? accent,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent ?? Colors.teal, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: accent.withOpacity(0.4),
          inactiveThumbColor: Colors.grey[300],
          inactiveTrackColor: Colors.grey[300],
          thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return const Icon(Icons.check, color: Colors.white, size: 16);
              }
              return const Icon(Icons.close, size: 16);
            },
          ),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ],
    );
  }
}
