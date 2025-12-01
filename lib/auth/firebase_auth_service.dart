import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter agar UI bisa memantau status login secara realtime (Stream)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Getter untuk mengambil user yang sedang login saat ini
  User? get currentUser => _firebaseAuth.currentUser;

  // ===========================================================================
  // 1. REGISTER MANUAL
  // ===========================================================================
  Future<User?> signUpWithEmailAndData({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // A. Buat Akun di Authentication
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;

      if (user != null) {
        // B. Simpan Biodata di Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'hasPurchasedPackage': false,
          'photoUrl': '',
        });
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mendaftar: $e');
    }
  }

  // ===========================================================================
  // 2. LOGIN MANUAL
  // ===========================================================================
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  // ===========================================================================
  // 3. GOOGLE SIGN IN (UPDATED - LEBIH AMAN)
  // ===========================================================================
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Paksa pemilihan akun setiap kali dengan membersihkan session Google sebelumnya.
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();

      // A. Mulai proses login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Login dibatalkan.');

      // B. Ambil token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // C. Masuk ke Firebase Auth
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      // D. CEK DATABASE (Perbaikan Logika)
      // Cek apakah data profil sudah ada di Firestore?
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        // Jika data BELUM ADA (User baru atau data terhapus), buat baru.
        if (!userDoc.exists) {
           await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': googleUser.email,
            'name': googleUser.displayName ?? 'No Name',
            'phone': '', // Google jarang memberikan no HP, jadi kosongkan
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
            'hasPurchasedPackage': false,
            'photoUrl': googleUser.photoUrl ?? '',
          });
        }
      }
      
      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Gagal login Google: $e');
    }
  }

  // ===========================================================================
  // 4. AMBIL DATA USER (Get User Data)
  // ===========================================================================
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data profil: $e');
    }
  }

  // ===========================================================================
  // 5. UPDATE DATA USER
  // ===========================================================================
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Gagal mengupdate data: $e');
    }
  }

  // ===========================================================================
  // 6. HAPUS AKUN (Delete Account)
  // ===========================================================================
  Future<void> deleteAccount() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        // Hapus data di Database dulu
        await _firestore.collection('users').doc(user.uid).delete();
        // Hapus akun Login
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
       throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Gagal menghapus akun: $e');
    }
  }

  // ===========================================================================
  // 7. LOGOUT & RESET PASSWORD
  // ===========================================================================
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out Google dulu
    await _firebaseAuth.signOut(); // Baru Firebase
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Gagal mengirim email reset: $e');
    }
  }

  // ===========================================================================
  // HELPER: Pesan Error Bahasa Indonesia
  // ===========================================================================
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email': return 'Format email tidak valid.';
      case 'user-disabled': return 'Pengguna ini telah dinonaktifkan.';
      case 'user-not-found': return 'Email tidak terdaftar.';
      case 'wrong-password': return 'Password salah.';
      case 'email-already-in-use': return 'Email sudah digunakan oleh akun lain.';
      case 'weak-password': return 'Password terlalu lemah (minimal 6 karakter).';
      case 'requires-recent-login': return 'Silakan login ulang sebelum melakukan aksi ini.';
      case 'network-request-failed': return 'Masalah koneksi internet.';
      case 'credential-already-in-use': return 'Akun ini sudah terhubung dengan pengguna lain.';
      default: return 'Terjadi kesalahan: $errorCode';
    }
  }
}
