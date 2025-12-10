class User {
  final String id; // Changed from uid to id to match backend
  final String email;
  final String displayName; // Mapped from 'name'
  final String? photoUrl; // Mapped from 'avatar'
  final String? dateOfBirth; // Mapped from 'birthDate'
  final String? phoneNumber; // Mapped from 'phone'
  final String? role; // 'USER', 'ADMIN'
  final String? plan; // 'FREE', 'PREMIUM', etc.
  final bool hasPurchasedPackage; // Logic can be derived from 'plan'

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.role,
    this.plan,
    this.hasPurchasedPackage = false,
  });

  // Factory untuk membuat User dari JSON Backend
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      displayName: json['name'] ?? 'No Name',
      phoneNumber: json['phone'],
      dateOfBirth: json['birthDate'],
      role: json['role'],
      plan: json['plan'],
      photoUrl: json['avatar'],
      // Logic sederhana: jika plan bukan null/free, anggap sudah beli (sesuaikan kebutuhan)
      hasPurchasedPackage: json['plan'] != null && json['plan'] != 'free',
    );
  }

  User copyWith({
    String? displayName,
    String? dateOfBirth,
    String? phoneNumber,
    String? photoUrl,
    String? role,
    String? plan,
    bool? hasPurchasedPackage,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      hasPurchasedPackage: hasPurchasedPackage ?? this.hasPurchasedPackage,
    );
  }

  // Helper
  bool get isAdmin => role == 'ADMIN';
}
