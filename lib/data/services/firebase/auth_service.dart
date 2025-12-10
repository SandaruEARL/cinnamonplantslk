import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/utils/constants.dart';
import '../../../domain/entities/user.dart' as app_user;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth. instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<app_user.User> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      final user = app_user.User(
        id: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        userType: userType,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<app_user.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user document
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (! doc.exists) {
        throw Exception('User data not found');
      }

      return app_user.User.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Get user data
  Future<app_user. User?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          . get();

      if (! doc.exists) return null;

      return app_user. User.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String?  name,
    String? phone,
    String? location,
    String? profilePicUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (location != null) updates['location'] = location;
      if (profilePicUrl != null) updates['profilePicUrl'] = profilePicUrl;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}