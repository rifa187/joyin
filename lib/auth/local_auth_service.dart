import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:joyin/core/user_model.dart';

class LocalAuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _emailKey = 'local_email';
  static const _passwordKey = 'local_password';
  static const _displayNameKey = 'local_display_name';
  static const _phoneNumberKey = 'local_phone_number';
  static const _dateOfBirthKey = 'local_date_of_birth';

  Future<User?> signUp(String email, String password, {String? displayName, String? phoneNumber}) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
    if (displayName != null) {
      await _secureStorage.write(key: _displayNameKey, value: displayName);
    }
    if (phoneNumber != null) {
      await _secureStorage.write(key: _phoneNumberKey, value: phoneNumber);
    }
    return User(
      id: 'local_user',
      email: email,
      displayName: displayName ?? email,
      role: email.toLowerCase().contains('admin') ? 'ADMIN' : 'USER',
      hasPurchasedPackage: false,
    );
  }

  Future<User?> signIn(String email, String password) async {
    final storedEmail = await _secureStorage.read(key: _emailKey);
    final storedPassword = await _secureStorage.read(key: _passwordKey);

    if (email == storedEmail && password == storedPassword) {
      final displayName = await _secureStorage.read(key: _displayNameKey);
      final phoneNumber = await _secureStorage.read(key: _phoneNumberKey);
      final dateOfBirth = await _secureStorage.read(key: _dateOfBirthKey);

      return User(
        id: 'local_user',
        email: email,
        displayName: displayName ?? email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        role: email.toLowerCase().contains('admin') ? 'ADMIN' : 'USER',
        hasPurchasedPackage: false,
      );
    }
    return null;
  }

  Future<void> saveUserProfile(User user) async {
    if (user.displayName.isNotEmpty) {
      await _secureStorage.write(key: _displayNameKey, value: user.displayName);
    }
    if (user.phoneNumber != null) {
      await _secureStorage.write(key: _phoneNumberKey, value: user.phoneNumber);
    }
    if (user.dateOfBirth != null) {
      await _secureStorage.write(key: _dateOfBirthKey, value: user.dateOfBirth);
    }
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
    await _secureStorage.delete(key: _displayNameKey);
    await _secureStorage.delete(key: _phoneNumberKey);
    await _secureStorage.delete(key: _dateOfBirthKey);
  }

  Future<void> deleteAccount() async {
    await _secureStorage.deleteAll();
  }
}
