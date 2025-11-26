import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Warna Utama (Sesuai tema aplikasi Anda)
  final Color _primaryColor = const Color(0xFF4ECDC4);

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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Background abu-abu muda
      // Body dibungkus SingleChildScrollView agar bisa discroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KARTU 1: PENGATURAN UMUM ---
            _buildSectionCard(
              title: "Pengaturan Umum",
              children: [
                _buildTextField(
                  label: "Nama Bot", 
                  controller: _botNameController,
                  hint: "Masukkan nama bot kamu",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: "Pesan Selamat Datang", 
                  controller: _welcomeMsgController,
                  maxLines: 3,
                  hint: "Halo! Ada yang bisa saya bantu?",
                ),
                const SizedBox(height: 20),
                _buildSwitchRow("Aktifkan Bot", _isBotActive, (val) {
                  setState(() => _isBotActive = val);
                }),
              ],
            ),

            const SizedBox(height: 20),

            // --- KARTU 2: BALASAN OTOMATIS ---
            _buildSectionCard(
              title: "Pengaturan Balasan Otomatis",
              children: [
                _buildTextField(
                  label: "Pesan balasan saat bot tidak tahu", 
                  controller: _fallbackMsgController,
                  maxLines: 3,
                  hint: "Maaf, saya belum mengerti maksud Anda.",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: "Jeda balasan otomatis (detik)", 
                  controller: _delayController,
                  keyboardType: TextInputType.number,
                  hint: "Contoh: 2",
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- KARTU 3: JAM KERJA ---
            _buildSectionCard(
              title: "Jam Kerja",
              children: [
                _buildSwitchRow("Aktifkan Jam Kerja", _isWorkingHoursActive, (val) {
                  setState(() => _isWorkingHoursActive = val);
                }),
                const SizedBox(height: 16),
                // Input ini hanya aktif jika switch jam kerja ON (Opsional UX)
                Opacity(
                  opacity: _isWorkingHoursActive ? 1.0 : 0.5,
                  child: _buildTextField(
                    label: "Pesan di luar jam kerja", 
                    controller: _outOfHoursMsgController,
                    maxLines: 3,
                    enabled: _isWorkingHoursActive,
                    hint: "Kami sedang tutup, silakan kembali jam 08.00",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Panggil fungsi API untuk simpan data ke Backend Bun.js
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pengaturan berhasil disimpan!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(
                  "Simpan Perubahan",
                  style: GoogleFonts.poppins(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50), // Spasi bawah
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER (Supaya kodingan rapi & tidak berulang) ---

  // 1. Widget Kartu Putih Pembungkus
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // 2. Widget Input Text (Kotak isian)
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label di atas kotak (Opsional, di gambar Anda labelnya di dalam kotak)
        // Kita pakai label di dalam border (labelText) agar mirip Material Design modern
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            labelText: label, // Label melayang di garis
            hintText: hint,
            floatingLabelBehavior: FloatingLabelBehavior.always, // Label selalu di atas
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  // 3. Widget Switch (Tombol Geser)
  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primaryColor,
            activeTrackColor: _primaryColor.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}