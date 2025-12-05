// This file contains the dummy User model to be used throughout the app
// after removing Firebase.

class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? dateOfBirth;
  final String? phoneNumber;
  final bool hasPurchasedPackage;
  final int? packageDurationMonths;
  final bool isAdmin;

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.hasPurchasedPackage = false,
    this.packageDurationMonths,
    this.isAdmin = false,
  });

  User copyWith({
    String? displayName,
    String? dateOfBirth,
    String? phoneNumber,
    String? photoUrl,
    bool? hasPurchasedPackage,
    int? packageDurationMonths,
    bool? isAdmin,
  }) {
    return User(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      hasPurchasedPackage: hasPurchasedPackage ?? this.hasPurchasedPackage,
      packageDurationMonths:
          packageDurationMonths ?? this.packageDurationMonths,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class UserCredential {
  final User? user;

  UserCredential({this.user});
}
