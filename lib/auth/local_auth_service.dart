import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:joyin/core/user_model.dart';

class LocalAuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Kunci Penyimpanan
  static const _emailKey = 'local_email';
  static const _passwordKey = 'local_password';
  static const _nameKey = 'local_name'; // Ganti displayName -> name
  static const _phoneNumberKey = 'local_phone_number';
  static const _dateOfBirthKey = 'local_date_of_birth';
  static const _photoUrlKey = 'local_photo_url'; // Tambahan untuk foto

  // --- SIGN UP ---
  Future<User?> signUp({
    required String email, 
    required String password, 
    required String name, // Wajib ada sesuai model baru
    String? phoneNumber
  }) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
    await _secureStorage.write(key: _nameKey, value: name);
    
    if (phoneNumber != null) {
      await _secureStorage.write(key: _phoneNumberKey, value: phoneNumber);
    }

    return User(
      uid: 'local_user_uid', // UID Dummy untuk lokal
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      hasPurchasedPackage: false,
    );
  }

  // --- SIGN IN ---
  Future<User?> signIn(String email, String password) async {
    final storedEmail = await _secureStorage.read(key: _emailKey);
    final storedPassword = await _secureStorage.read(key: _passwordKey);

    if (email == storedEmail && password == storedPassword) {
      final name = await _secureStorage.read(key: _nameKey);
      final phoneNumber = await _secureStorage.read(key: _phoneNumberKey);
      final dateOfBirth = await _secureStorage.read(key: _dateOfBirthKey);
      final photoUrl = await _secureStorage.read(key: _photoUrlKey);

      return User(
        uid: 'local_user_uid',
        email: email,
        name: name ?? 'Local User', // Fallback name
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        photoUrl: photoUrl,
        createdAt: DateTime.now(), // Mock creation date
      );
    }
    return null;
  }

  // --- UPDATE PROFILE ---
  Future<void> saveUserProfile(User user) async {
    await _secureStorage.write(key: _nameKey, value: user.name);
    
    if (user.phoneNumber != null) {
      await _secureStorage.write(key: _phoneNumberKey, value: user.phoneNumber);
    }
    if (user.dateOfBirth != null) {
      await _secureStorage.write(key: _dateOfBirthKey, value: user.dateOfBirth);
    }
    if (user.photoUrl != null) {
      await _secureStorage.write(key: _photoUrlKey, value: user.photoUrl);
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    // Opsional: Hapus data login, atau biarkan agar bisa login lagi nanti
    // Di sini kita hanya menghapus sesi di memori aplikasi (tidak ada kode khusus untuk secure storage kecuali kita mau 'lupa password')
  }

  // --- DELETE ACCOUNT ---
  Future<void> deleteAccount() async {
    await _secureStorage.deleteAll();
  }
}