import 'package:aner_astaner/features/login/domin/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  User? get currentUser => _authRepository.currentUser;

  Future<User?> signInWithGoogle({bool ensureProfile = true}) {
    return _authRepository.signInWithGoogle(ensureProfile: ensureProfile);
  }

  Future<User?> registerWithEmail(String email, String password) {
    return _authRepository.registerWithEmail(email, password);
  }

  Future<User?> createUserWithProfile({
    required String email,
    required String password,
    required Map<String, dynamic> profile,
  }) {
    return _authRepository.createUserWithProfile(
      email: email,
      password: password,
      profile: profile,
    );
  }

  Future<User?> signInWithEmail(String email, String password) {
    return _authRepository.signInWithEmail(email, password);
  }

  Future<Map<String, dynamic>?> getUserProfile(User user) {
    return _authRepository.getUserProfile(user);
  }

  Future<void> ensureUserProfile(User user) {
    return _authRepository.ensureUserProfile(user);
  }

  Future<void> createBasicUserProfile(User user) {
    return _authRepository.createBasicUserProfile(user);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> signOut() {
    return _authRepository.signOut();
  }

  Future<String?> getUserRole(User user) {
    return _authRepository.getUserRole(user);
  }
}
