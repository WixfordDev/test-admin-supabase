import 'package:deenhub/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String? fullName);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Stream<UserModel?> authStateChanges();
  Future<void> updateUserSubscription(String userId, bool hasSubscription);
} 