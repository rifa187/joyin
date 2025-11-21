class AppValidators {
  // 1. Validasi Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    // Regex sederhana untuk cek format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null; // null artinya Valid (Tidak ada error)
  }

  // 2. Validasi Password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // 3. Validasi Nama
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama terlalu pendek';
    }
    return null;
  }

  // 4. Validasi No HP
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    // Cek apakah isinya angka semua
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Hanya boleh angka';
    }
    if (value.length < 10) {
      return 'Nomor tidak valid (min 10 digit)';
    }
    return null;
  }
  
  // 5. Validasi Konfirmasi Password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak sama';
    }
    return null;
  }
}