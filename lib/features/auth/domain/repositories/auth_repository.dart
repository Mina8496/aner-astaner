import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;

  Future<User?> signInWithGoogle({bool ensureProfile = true});

  Future<User?> registerWithEmail(String email, String password);

  Future<User?> createUserWithProfile({
    required String email,
    required String password,
    required Map<String, dynamic> profile,
  });

  Future<User?> signInWithEmail(String email, String password);

  Future<Map<String, dynamic>?> getUserProfile(User user);

  Future<void> ensureUserProfile(User user);

  Future<void> createBasicUserProfile(User user);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<String?> getUserRole(User user);
}