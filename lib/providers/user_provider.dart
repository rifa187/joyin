import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth; 

// --- PERBAIKAN DI SINI ---
// Hapus kata '/config'. File kamu ada di dalam core langsung.
import 'package:joyin/core/user_model.dart'; 

class UserProvider with ChangeNotifier {
  User? _user; 

  User? get user => _user;

  // --- FUNGSI LOAD DATA ---
  Future<void> loadUserData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        // Karena import sudah benar, fromJson sekarang pasti dikenali
        _user = User.fromJson(doc.data() as Map<String, dynamic>);
        
        notifyListeners(); 
        // name juga akan dikenali karena class User sudah terbaca
        debugPrint("User Data Loaded: ${_user?.name ?? 'No Name'}");
      } else {
        debugPrint("User Data not found in Firestore for uid: $uid");
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final currentUser = fbAuth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await loadUserData(currentUser.uid);
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}