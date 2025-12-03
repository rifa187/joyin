class User {
  final String uid;
  final String email;
  final String name; // Diubah dari displayName agar sesuai dengan error log
  final String? photoUrl;
  final String? dateOfBirth;
  final String? phoneNumber;
  final bool hasPurchasedPackage;
  final int? packageDurationMonths;
  final DateTime? createdAt; // Ditambahkan agar support penyimpanan tanggal buat akun

  User({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.hasPurchasedPackage = false,
    this.packageDurationMonths,
    this.createdAt,
  });

  // --- 1. FACTORY FROM JSON (Untuk Membaca dari Firestore) ---
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      // Cek 'name', kalau kosong cek 'displayName', kalau kosong pakai 'No Name'
      name: json['name'] ?? json['displayName'] ?? 'No Name', 
      photoUrl: json['photoUrl'],
      dateOfBirth: json['dateOfBirth'],
      phoneNumber: json['phoneNumber'],
      hasPurchasedPackage: json['hasPurchasedPackage'] ?? false,
      packageDurationMonths: json['packageDurationMonths'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  // --- 2. METHOD TO JSON (Untuk Menyimpan ke Firestore) ---
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'hasPurchasedPackage': hasPurchasedPackage,
      'packageDurationMonths': packageDurationMonths,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // --- 3. COPY WITH (Untuk Update State Local) ---
  User copyWith({
    String? name,
    String? email,
    String? dateOfBirth,
    String? phoneNumber,
    String? photoUrl,
    bool? hasPurchasedPackage,
    int? packageDurationMonths,
  }) {
    return User(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      hasPurchasedPackage: hasPurchasedPackage ?? this.hasPurchasedPackage,
      packageDurationMonths:
          packageDurationMonths ?? this.packageDurationMonths,
      createdAt: createdAt,
    );
  }
}