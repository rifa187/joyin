class User {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? dateOfBirth;
  final String? phoneNumber;
  final bool hasPurchasedPackage;
  final int? packageDurationMonths;
  final DateTime? createdAt;
  final String role; // PENTING: Untuk membedakan 'admin' dan 'user'

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
    this.role = 'user', // Default role adalah 'user'
  });

  // --- 1. FACTORY FROM JSON (Membaca dari Firestore) ---
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      
      // FALLBACK CERDAS: Cek 'name' dulu, kalau kosong cek 'displayName' (punya temanmu)
      name: json['name'] ?? json['displayName'] ?? 'No Name', 
      
      photoUrl: json['photoUrl'],
      dateOfBirth: json['dateOfBirth'],
      
      // FALLBACK CERDAS: Cek 'phoneNumber' dulu, kalau kosong cek 'phone' (punya temanmu)
      phoneNumber: json['phoneNumber'] ?? json['phone'], 
      
      hasPurchasedPackage: json['hasPurchasedPackage'] ?? false,
      packageDurationMonths: json['packageDurationMonths'],
      
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
          
      // Baca role dari database, jika tidak ada anggap 'user'
      role: json['role'] ?? 'user', 
    );
  }

  // --- 2. METHOD TO JSON (Menyimpan ke Firestore) ---
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber, // Kita standarkan pakai 'phoneNumber'
      'hasPurchasedPackage': hasPurchasedPackage,
      'packageDurationMonths': packageDurationMonths,
      'createdAt': createdAt?.toIso8601String(),
      'role': role, // Simpan role ke database
    };
  }

  // --- 3. COPY WITH (Update State) ---
  User copyWith({
    String? name,
    String? email,
    String? dateOfBirth,
    String? phoneNumber,
    String? photoUrl,
    bool? hasPurchasedPackage,
    int? packageDurationMonths,
    String? role,
  }) {
    return User(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      hasPurchasedPackage: hasPurchasedPackage ?? this.hasPurchasedPackage,
      packageDurationMonths: packageDurationMonths ?? this.packageDurationMonths,
      createdAt: createdAt,
      role: role ?? this.role,
    );
  }
}