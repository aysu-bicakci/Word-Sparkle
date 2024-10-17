import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      print('Mail kutunuzu kontrol ediniz');
    } catch (e) {
      print('Forgot password error $e');
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Kullanıcı Bulunamadı';
      } else if (e.code == 'wrong-password') {
        return 'Sifre Yanlıs';
      } else if (e.code == 'user-disabled') {
        return 'Kullanıcı Pasif';
      }
      return 'Bilinmeyen Hata';
    }
  }
}
