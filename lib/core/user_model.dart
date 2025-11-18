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

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.hasPurchasedPackage = false,
    this.packageDurationMonths,
  });

  User copyWith({
    String? displayName,
    String? dateOfBirth,
    String? phoneNumber,
    String? photoUrl,
    bool? hasPurchasedPackage,
    int? packageDurationMonths,
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
    );
  }
}

class UserCredential {
  final User? user;

  UserCredential({this.user});
}
