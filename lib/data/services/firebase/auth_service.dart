import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/utils/constants.dart';
import '../../../features/auth/domain/entities/user_entity.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
  firebase_auth.User? get currentUser => _auth.currentUser;

  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserEntity(
        id: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        userType: userType,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'userType': user.userType,
        'isVerified': user.isVerified,
        'profilePicUrl': user.profilePicUrl,
        'location': user.location,
        'blockedUsers': user.blockedUsers,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) throw Exception('User data not found');

      final data = {'id': credential.user!.uid, ...doc.data()!};
      return UserEntity(
        id: data['id'] as String,
        email: data['email'] as String,
        name: data['name'] as String,
        phone: data['phone'] as String,
        userType: data['userType'] as String,
        profilePicUrl: data['profilePicUrl'] as String?,
        location: data['location'] as String?,
        isVerified: data['isVerified'] as bool? ?? false,
        blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async => _auth.signOut();

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return {'id': uid, ...doc.data()!};
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
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

  Future<void> blockUser(String currentUserId, String targetUserId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .update({'blockedUsers': FieldValue.arrayUnion([targetUserId])});
  }

  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .update({'blockedUsers': FieldValue.arrayRemove([targetUserId])});
  }
}