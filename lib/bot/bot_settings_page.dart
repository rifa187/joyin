import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import '../package/package_theme.dart';
import '../widgets/typing_text.dart';

class BotSettingsPage extends StatefulWidget {
  const BotSettingsPage({super.key});

  @override
  State<BotSettingsPage> createState() => _BotSettingsPageState();
}

class _BotSettingsPageState extends State<BotSettingsPage> with SingleTickerProviderStateMixin {
  // --- CONTROLLERS (Untuk mengambil teks input) ---
  final TextEditingController _botNameController = TextEditingController();
  final TextEditingController _welcomeMsgController = TextEditingController();
  final TextEditingController _fallbackMsgController = TextEditingController();
  final TextEditingController _delayController = TextEditingController();
  final TextEditingController _outOfHoursMsgController = TextEditingController();

  late final AnimationController _entranceController;
  late final Animation<double> _cardSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  // --- STATES (Untuk Switch On/Off) ---
  bool _isBotActive = true;
  bool _isWorkingHoursActive = false;
  bool _escalateLowConfidence = true;
  bool _collectFeedback = true;
  String _selectedTone = 'Ramah';
  double _replyDelay = 3;
  final List<String> _tones = ['Ramah', 'Profesional', 'Santai', 'Singkat', 'Lengkap'];

  @override
  void initState() {
    super.initState();
    _botNameController.text = 'Joyin Bot';
    _welcomeMsgController.text = 'Halo! Ada yang bisa saya bantu?';
    _fallbackMsgController.text = 'Maaf, aku belum paham. Tim kami akan bantu.';
    _delayController.text = _replyDelay.round().toString();
    _outOfHoursMsgController.text = 'Halo! Kami balas saat jam kerja ya.';
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _cardSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1, curve: Curves.easeOutBack),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 1, curve: Curves.easeOut),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar tidak memakan memori
    _botNameController.dispose();
    _welcomeMsgController.dispose();
    _fallbackMsgController.dispose();
    _delayController.dispose();
    _outOfHoursMsgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage = packageProvider.currentUserPackage != null &&
        packageProvider.currentUserPackage!.isNotEmpty;
    final packageTheme = PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: packageTheme.backgroundGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(topPadding, packageTheme),
              Transform.translate(
                offset: const Offset(0, -80),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_cardSlide),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: packageTheme.accent.withOpacity(0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: hasPackage
                        ? FadeTransition(
                            opacity: _contentFade,
                            child: SlideTransition(
                              position: _contentSlide,
                              child: _buildBotBody(packageTheme),
                            ),
                          )
                        : const LockedFeatureWidget(
                            title: 'Fitur Terkunci',
                            message: 'Upgrade paketmu untuk membuka pengaturan bot.',
                            icon: Icons.smart_toy_outlined,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(double topPadding, PackageTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 48, 24, 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.headerGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypingText(
            text: 'Pengaturan Bot',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            duration: const Duration(milliseconds: 900),
            delay: const Duration(milliseconds: 80),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              'Atur auto-reply, jam kerja, dan gaya percakapan bot supaya respon tetap konsisten 24/7.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotBody(PackageTheme packageTheme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildStatusRow(packageTheme.accent),
        const SizedBox(height: 20),
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
            const SizedBox(height: 12),
            _buildDelaySlider(packageTheme.accent),
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
        _buildSectionCard(
          title: "Gaya & Proteksi",
          accent: packageTheme.accent,
          children: [
            _buildToneSelector(packageTheme.accent),
            const SizedBox(height: 12),
            _buildSwitchRow(
              "Auto-eskalasi jika bot ragu",
              _escalateLowConfidence,
              (val) => setState(() => _escalateLowConfidence = val),
              packageTheme.accent,
            ),
            const SizedBox(height: 12),
            _buildSwitchRow(
              "Kumpulkan feedback jawaban",
              _collectFeedback,
              (val) => setState(() => _collectFeedback = val),
              packageTheme.accent,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildPreviewCard(packageTheme),
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
      ],
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

  Widget _buildStatusRow(Color accent) {
    return Column(
      children: [
        _buildStatusTile(
          accent: accent,
          icon: Icons.smart_toy_outlined,
          title: 'Status Bot',
          statusText: _isBotActive ? 'Aktif' : 'Nonaktif',
          description: _isBotActive
              ? 'Bot akan membalas otomatis sesuai pengaturan.'
              : 'Aktifkan untuk mulai menjawab pelanggan.',
          trailing: _buildStyledSwitch(_isBotActive, (val) => setState(() => _isBotActive = val), accent),
        ),
        const SizedBox(height: 12),
        _buildStatusTile(
          accent: accent,
          icon: Icons.schedule_rounded,
          title: 'Jam Kerja',
          statusText: _isWorkingHoursActive ? 'Terjadwal' : '24/7',
          description: _isWorkingHoursActive
              ? 'Bot balas hanya di jam kerja, di luar kirim pesan otomatis.'
              : 'Bot balas kapan saja; pesan luar jam kerja diabaikan.',
          trailing: _buildStyledSwitch(_isWorkingHoursActive, (val) => setState(() => _isWorkingHoursActive = val), accent),
        ),
      ],
    );
  }

  Widget _buildStatusTile({
    required Color accent,
    required IconData icon,
    required String title,
    required String statusText,
    required String description,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accent),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _buildToneSelector(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gaya balasan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tones.map((tone) {
            final selected = tone == _selectedTone;
            return GestureDetector(
              onTap: () => setState(() => _selectedTone = tone),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? accent.withOpacity(0.12) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? accent : Colors.grey.shade300),
                ),
                child: Text(
                  tone,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: selected ? accent : Colors.grey[800],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDelaySlider(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delay Balasan (${_replyDelay.round()} detik)', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Slider(
          value: _replyDelay,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: accent,
          inactiveColor: accent.withOpacity(0.2),
          label: '${_replyDelay.round()} dtk',
          onChanged: (val) {
            setState(() {
              _replyDelay = val;
              _delayController.text = val.round().toString();
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreviewCard(PackageTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: theme.headerGradient),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.accent.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview Balasan Bot',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewBubble(
            sender: _botNameController.text.isEmpty ? 'Joyin Bot' : _botNameController.text,
            message: _welcomeMsgController.text.isEmpty
                ? 'Halo! Ada yang bisa saya bantu?'
                : _welcomeMsgController.text,
            isBot: true,
          ),
          const SizedBox(height: 8),
          _buildPreviewBubble(
            sender: 'Pengguna',
            message: 'Apa saja yang bisa kamu lakukan?',
            isBot: false,
          ),
          const SizedBox(height: 8),
          _buildPreviewBubble(
            sender: _botNameController.text.isEmpty ? 'Joyin Bot' : _botNameController.text,
            message: _fallbackMsgController.text.isEmpty
                ? 'Maaf, aku belum paham. Tim kami akan bantu.'
                : _fallbackMsgController.text,
            isBot: true,
          ),
          const SizedBox(height: 4),
          Text(
            'Gaya: $_selectedTone - Delay: ${_replyDelay.round()} dtk',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBubble({
    required String sender,
    required String message,
    required bool isBot,
  }) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isBot ? Colors.white.withOpacity(0.16) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBot ? Colors.white.withOpacity(0.24) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: isBot ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: isBot ? Colors.white.withOpacity(0.9) : Colors.black87,
              ),
            ),
          ],
        ),
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
        _buildStyledSwitch(value, onChanged, accent),
      ],
    );
  }

  Switch _buildStyledSwitch(bool value, ValueChanged<bool> onChanged, Color accent) {
    return Switch(
      value: value,
      onChanged: onChanged,
      trackColor: MaterialStateProperty.resolveWith<Color?>(
        (states) => states.contains(MaterialState.selected) ? accent : Colors.grey.shade300,
      ),
      thumbColor: MaterialStateProperty.resolveWith<Color?>(
        (states) => states.contains(MaterialState.selected) ? Colors.white : Colors.grey.shade50,
      ),
      trackOutlineColor: MaterialStateProperty.resolveWith<Color?>(
        (states) => states.contains(MaterialState.selected) ? accent.withOpacity(0.4) : Colors.transparent,
      ),
    );
  }
}
