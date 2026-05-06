import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  });
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? location,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fetchUserModel(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Sign in failed');
    }
  }

  @override
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? location,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (location != null) updates['location'] = location;
      if (updates.isEmpty) return;
      await _firestore.collection('users').doc(uid).update(updates);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update profile');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final userModel = UserModel(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        blockedUsers: const [],
      );
      await _firestore.collection('users').doc(uid).set(userModel.toFirestore());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Sign out failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchUserModel(firebaseUser.uid);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to send reset email');
    }
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw const ServerException('User data not found');
    return UserModel.fromFirestore(doc.data()!, uid);
  }
}