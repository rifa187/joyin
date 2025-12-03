import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;

// Import Model User
import '../core/user_model.dart'; 

class UserProvider with ChangeNotifier {
  User? _user; 

  User? get user => _user;

  // --- FUNGSI 1: LOAD DATA DARI FIRESTORE ---
  Future<void> loadUserData(String uid) async {
    try {
      // Ambil dokumen dari koleksi 'users' berdasarkan UID
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        // Konversi data JSON dari Firestore ke Model User
        _user = User.fromJson(doc.data() as Map<String, dynamic>);
        
        notifyListeners(); 
        
        // --- DEBUGGING PENTING ---
        // Cek Terminal setelah login: Apakah role terbaca sebagai 'admin'?
        debugPrint("✅ User Data Loaded: ${_user?.name}");
        debugPrint("✅ User Role: ${_user?.role}"); 
        // -------------------------
        
      } else {
        debugPrint("❌ User Data not found in Firestore for uid: $uid");
      }
    } catch (e) {
      debugPrint("❌ Error loading user data: $e");
    }
  }

  // --- FUNGSI 2: SET MANUAL ---
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // --- FUNGSI 3: REFRESH DATA (Panggil ini saat buka halaman Profil) ---
  Future<void> refreshUser() async {
    final currentUser = fbAuth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      debugPrint("🔄 Refreshing user data for: ${currentUser.uid}");
      await loadUserData(currentUser.uid);
    }
  }

  // --- FUNGSI 4: CLEAR DATA (SAAT LOGOUT) ---
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}