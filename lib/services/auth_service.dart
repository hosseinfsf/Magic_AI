import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

/// سرویس احراز هویت با Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // جریان تغییرات کاربر
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // کاربر فعلی
  User? get currentUser => _auth.currentUser;
  
  // آیا کاربر لاگین است؟
  bool get isSignedIn => _auth.currentUser != null;

  /// ورود با Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// ورود با Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // فقط برای iOS و macOS
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw Exception('Sign in with Apple is only available on iOS and macOS');
      }

      // Request credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  /// ورود با ایمیل و پسورد
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  /// ثبت‌نام با ایمیل و پسورد
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  /// خروج
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// حذف حساب کاربری
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  /// ارسال لینک بازنشانی پسورد
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// به‌روزرسانی پروفایل
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}

