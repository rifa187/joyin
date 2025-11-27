import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORT FILE KAMU (Sesuaikan path-nya)
import '../../../core/app_colors.dart'; // Naik 3 level karena ada di lib/profile/widgets
import '../../../providers/auth_provider.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // State Visibility (Mata) - Default True (Tersembunyi)
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Ubah Kata Sandi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. PASSWORD LAMA
              TextFormField(
                controller: currentPassController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOld ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 15),

              // 2. PASSWORD BARU
              TextFormField(
                controller: newPassController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (value) => value!.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 15),

              // 3. KONFIRMASI PASSWORD
              TextFormField(
                controller: confirmPassController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) {
                  if (value != newPassController.text) return 'Password tidak sama';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
        ),
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.joyin,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        await auth.changePassword(
                          currentPassword: currentPassController.text,
                          newPassword: newPassController.text,
                          context: context,
                        );
                      }
                    },
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
            );
          },
        ),
      ],
    );
  }
}