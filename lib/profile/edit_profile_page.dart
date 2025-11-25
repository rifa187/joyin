import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// IMPORT PROVIDERS & MODEL
import '../core/user_model.dart';
import '../providers/auth_provider.dart'; 
import '../providers/user_provider.dart'; 
import '../widgets/custom_text_field.dart'; 
import 'widgets/profile_avatar.dart'; 

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key}); 

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  bool _hasChanges = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    // Ambil Data Awal dari UserProvider
    final user = Provider.of<UserProvider>(context, listen: false).user;

    _nameController = TextEditingController(text: user?.displayName);
    _emailController = TextEditingController(text: user?.email);
    _dobController = TextEditingController(text: user?.dateOfBirth);
    _phoneController = TextEditingController(text: user?.phoneNumber);

    // Deteksi Perubahan
    _nameController.addListener(_updateChangesStatus);
    _dobController.addListener(_updateChangesStatus);
    _phoneController.addListener(_updateChangesStatus);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateChangesStatus() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    final bool currentHasChanges =
        _nameController.text != (user.displayName ?? '') ||
        _dobController.text != (user.dateOfBirth ?? '') ||
        _phoneController.text != (user.phoneNumber ?? '');

    if (currentHasChanges != _hasChanges) {
      setState(() => _hasChanges = currentHasChanges);
    }
  }

  // --- LOGIC 1: UPLOAD FOTO ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source, 
        imageQuality: 70, 
        maxWidth: 800
      );

      if (pickedFile != null && mounted) {
        await Provider.of<AuthProvider>(context, listen: false)
            .uploadProfilePicture(context, pickedFile);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // --- LOGIC 2: SIMPAN DATA TEKS (DIPERBARUI) ---
  Future<void> _saveProfile() async {
    // Validasi
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan No. Telepon tidak boleh kosong')),
      );
      return;
    }

    // Panggil AuthProvider untuk Update Data
    await Provider.of<AuthProvider>(context, listen: false).updateUserData(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      dob: _dobController.text.trim(),
      context: context,
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library), 
                title: const Text('Ambil dari Galeri'), 
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera), 
                title: const Text('Gunakan Kamera'), 
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }
              ),
            ],
          ),
        );
      },
    );
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
        _updateChangesStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, AuthProvider>(
      builder: (context, userProvider, authProvider, _) {
        final user = userProvider.user;
        final isLoading = authProvider.isLoading;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF63D1BE), Color(0xFFD6F28F)], 
                begin: Alignment.topCenter, 
                end: Alignment.bottomCenter
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white), 
                      onPressed: () => Navigator.of(context).pop()
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
                            child: _buildProfileForm(isLoading),
                          ),
                        ),
                        
                        // Widget Avatar Terpisah
                        ProfileAvatar(
                          photoUrl: user?.photoUrl,
                          isLoading: isLoading,
                          onEditTap: () => _showPicker(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileForm(bool isLoading) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 18)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  _nameController.text.isNotEmpty ? _nameController.text : 'Enter Your Name',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text.isNotEmpty ? _emailController.text : 'Enter Email Address',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          CustomTextField(controller: _nameController, label: 'Nama', hintText: 'Enter Your Name'),
          const SizedBox(height: 24),
          CustomTextField(controller: _emailController, label: 'Email', readOnly: true, hintText: 'Enter Your Email'),
          const SizedBox(height: 24),
          CustomTextField(controller: _phoneController, label: 'No. Telepon', keyboardType: TextInputType.phone, hintText: '0812-3456-7890'),
          const SizedBox(height: 24),
          CustomTextField(controller: _dobController, label: 'Tanggal Lahir', readOnly: true, onTap: _selectDate, hintText: 'YYYY-MM-DD'),
          
          const SizedBox(height: 32),
          
          // TOMBOL SIMPAN
          ElevatedButton(
            onPressed: (_hasChanges && !isLoading) ? _saveProfile : null, // Logic Simpan Disini
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? const Color(0xFF63D1BE) : const Color(0xFFB0BEC5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 54),
            ),
            child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Simpan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}