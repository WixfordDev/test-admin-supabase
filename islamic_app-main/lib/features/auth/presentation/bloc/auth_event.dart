part of 'auth_bloc.dart';

@freezed
abstract class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkAuthStatus() = _CheckAuthStatus;
  const factory AuthEvent.signIn({
    required String email,
    required String password,
  }) = _SignIn;
  const factory AuthEvent.signUp({
    required String email,
    required String password,
    String? fullName,
  }) = _SignUp;
  const factory AuthEvent.signInWithGoogle() = _SignInWithGoogle;
  const factory AuthEvent.signInWithApple() = _SignInWithApple;
  const factory AuthEvent.signOut() = _SignOut;
  const factory AuthEvent.resetPassword(String email) = _ResetPassword;
  const factory AuthEvent.updateSubscription(bool hasSubscription) = _UpdateSubscription;
} 