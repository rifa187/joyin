import 'package:joyin/auth/local_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late User _user;
  bool _hasChanges = false;
  final LocalAuthService _localAuthService = LocalAuthService();

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _nameController = TextEditingController(text: _user.displayName);
    _emailController = TextEditingController(text: _user.email);
    _dobController = TextEditingController(text: _user.dateOfBirth);
    _phoneController = TextEditingController(text: _user.phoneNumber);

    _nameController.addListener(_updateChangesStatus);
    _dobController.addListener(_updateChangesStatus);
    _phoneController.addListener(_updateChangesStatus);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateChangesStatus);
    _dobController.removeListener(_updateChangesStatus);
    _phoneController.removeListener(_updateChangesStatus);
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateChangesStatus() {
    final bool currentHasChanges =
        _nameController.text != (_user.displayName ?? '') ||
        _dobController.text != (_user.dateOfBirth ?? '') ||
        _phoneController.text != (_user.phoneNumber ?? '');

    if (currentHasChanges != _hasChanges) {
      setState(() {
        _hasChanges = currentHasChanges;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveProfile() async {
    final updatedUser = _user.copyWith(
      displayName: _nameController.text,
      dateOfBirth: _dobController.text,
      phoneNumber: _phoneController.text,
    );
    await _localAuthService.saveUserProfile(updatedUser);
    if (mounted) {
      Navigator.of(context).pop(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF63D1BE), Color(0xFFD6F28F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80, bottom: 32),
                        child: _buildProfileForm(),
                      ),
                    ),
                    _buildProfileAvatar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final photoUrl = _user.photoUrl;
    return SizedBox(
      height: 130,
      width: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 8,
            child: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF63D1BE),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : 'Enter Your Name',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text.isNotEmpty
                      ? _emailController.text
                      : 'Enter Email Address',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _nameController,
            label: 'Nama',
            hintText: 'Enter Your Name',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            readOnly: true,
            hintText: 'Enter Your Email',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _phoneController,
            label: 'No. Telepon',
            keyboardType: TextInputType.phone,
            hintText: '0812-3456-7890',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _dobController,
            label: 'Tanggal Lahir',
            readOnly: true,
            onTap: _selectDate,
            hintText: '01-01-2001',
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hasChanges ? _saveProfile : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges
                  ? const Color(0xFF63D1BE)
                  : const Color(0xFFB0BEC5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 54),
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF63D1BE)),
            ),
          ),
        ),
      ],
    );
  }
}




