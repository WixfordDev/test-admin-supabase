import 'dart:io';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/auth/data/repositories/auth_repository.dart';
import 'package:deenhub/features/auth/domain/models/user_model.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseProvider _supabaseProvider;

  AuthRepositoryImpl(this._supabaseProvider);

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabaseProvider.supabase.auth.currentUser;
      if (user == null) return null;

      final userData = await _getUserData(user.id);
      return _mapToUserModel(user, userData);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabaseProvider.supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login failed: No user returned');
      }

      final userData = await _getUserData(user.id);
      return _mapToUserModel(user, userData);
    } catch (e) {
      debugPrint('Error signing in with email: $e');

      // More descriptive error messages
      if (e is AuthException) {
        switch (e.statusCode) {
          case '400':
            throw Exception('Invalid email or password. Please try again.');
          case '401':
            throw Exception('Invalid credentials. Please check your email and password.');
          case '404':
            throw Exception('Account not found. Please check your email or create a new account.');
          case '429':
            throw Exception('Too many login attempts. Please try again later.');
          default:
            throw Exception('Login failed: ${e.message}');
        }
      }

      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String? fullName) async {
    try {
      final response = await _supabaseProvider.supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Registration failed: No user returned');
      }

      // Create user profile in the database
      await _createUserProfile(user.id, email, fullName);

      final userData = await _getUserData(user.id);
      return _mapToUserModel(user, userData);
    } catch (e) {
      debugPrint('Error signing up with email: $e');

      // More descriptive error messages
      if (e is AuthException) {
        switch (e.statusCode) {
          case '400':
            if (e.message.contains('already registered')) {
              throw Exception('This email is already registered. Please sign in instead.');
            }
            throw Exception('Invalid registration details: ${e.message}');
          case '422':
            throw Exception('Password is too weak. Please choose a stronger password.');
          case '429':
            throw Exception('Too many signup attempts. Please try again later.');
          default:
            throw Exception('Registration failed: ${e.message}');
        }
      }

      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign In process...');
      
      // Initialize Google Sign In with configuration
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        clientId: '1031438051281-4uemg3422hkpo4c0h9c65pq19m3qlb83.apps.googleusercontent.com',
        serverClientId: '1031438051281-2e87rokfit4of2ugec8ltp79o9g5qbqk.apps.googleusercontent.com',
      );

      // Sign out first to ensure a fresh login attempt
      await googleSignIn.signOut();
      logger.i('Google Sign In: Signed out previous session');

      // Attempt authentication with timeout
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate().timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          debugPrint('Google Sign In: Timeout during user selection');
          throw Exception('Google sign-in timed out. Please try again.');
        },
      );
      
      if (googleUser == null) {
        debugPrint('Google Sign In: User cancelled the sign-in');
        throw Exception('Google sign in was cancelled by user');
      }

      debugPrint('Google Sign In: User selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      // For Supabase, we can pass null for accessToken as idToken is sufficient
      final String? accessToken = null;

      if (idToken == null) {
        debugPrint('Google Sign In: Failed to get ID token');
        throw Exception('Failed to get Google ID token');
      }

      logger.i('Google Sign In: Got ID token, proceeding with Supabase auth');

      // Use Supabase signInWithIdToken
      final response = await _supabaseProvider.supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        logger.i('Google Sign In: No user returned from Supabase');
        throw Exception('Google login failed: No user returned from Supabase');
      }

      logger.i('Google Sign In: Successfully authenticated with Supabase for user: ${response.user!.email}');

      // Ensure user profile exists
      await _createUserProfile(
        response.user!.id,
        response.user!.email ?? googleUser.email,
        googleUser.displayName,
      );
      
      logger.i('Google Sign In: User profile ensured, sign-in complete');
    } catch (e) {
      debugPrint('Error signing in with Google: $e');

      if (e is AuthException) {
        throw Exception('Google login failed: ${e.message}');
      }

      // Provide more helpful error message
      String errorMessage = e.toString();
      if (errorMessage.contains('network_error') || errorMessage.contains('NetworkException')) {
        throw Exception('Network error. Please check your internet connection and try again.');
      } else if (errorMessage.contains('popup_closed') || errorMessage.contains('cancelled')) {
        throw Exception('Google sign-in was cancelled. Please try again.');
      } else if (errorMessage.contains('timeout')) {
        throw Exception('Google sign-in timed out. Please try again.');
      } else if (errorMessage.contains('code=0')) {
        throw Exception(
            'Google sign-in failed. Please verify your SHA-1 key is correctly configured in your project.');
      }

      throw Exception('Google login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      // Check if running on iOS
      if (!Platform.isIOS) {
        throw Exception('Apple Sign In is only available on iOS');
      }
      
      debugPrint('Starting Apple Sign In process...');
      
      // Check if Apple Sign In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }

      // Request credential from Apple (native iOS flow)
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        throw Exception('Failed to get Apple ID token');
      }

      debugPrint('Apple Sign In: Got credential, proceeding with Supabase auth');

      // Use Supabase signInWithIdToken
      final response = await _supabaseProvider.supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        accessToken: credential.authorizationCode,
      );

      if (response.user == null) {
        throw Exception('Apple login failed: No user returned from Supabase');
      }

      logger.i('Apple Sign In: Successfully authenticated with Supabase for user: ${response.user!.email}');

      // Create user profile with Apple user info
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
        if (fullName.isEmpty) fullName = null;
      }

      // Ensure user profile exists
      await _createUserProfile(
        response.user!.id,
        response.user!.email ?? credential.email ?? '',
        fullName,
      );
      
      logger.i('Apple Sign In: User profile ensured, sign-in complete');
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');

      if (e is AuthException) {
        throw Exception('Apple login failed: ${e.message}');
      }

      // Provide more helpful error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('AuthorizationErrorCode.canceled') || 
          errorMessage.contains('cancelled')) {
        throw Exception('Apple sign-in was cancelled. Please try again.');
      } else if (errorMessage.contains('network_error') || 
                 errorMessage.contains('NetworkException')) {
        throw Exception('Network error. Please check your internet connection and try again.');
      } else if (errorMessage.contains('not available')) {
        throw Exception('Apple Sign In is not available on this device.');
      }

      throw Exception('Apple login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseProvider.supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseProvider.supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _supabaseProvider.supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      debugPrint('Auth state change: $user');
      if (user == null) return null;

      // We need to fetch user data from the database
      // Since we can't do async operations in a sync map function,
      // we'll return a basic user model and let the UI refetch complete data
      return UserModel(
        id: user.id,
        email: user.email,
        hasSubscription: false, // Default value, will be updated when data is fetched
      );
    });
  }

  @override
  Future<void> updateUserSubscription(String userId, bool hasSubscription) async {
    try {
      await _supabaseProvider.supabase
          .from('user_profiles')
          .update({'has_subscription': hasSubscription}).eq('user_id', userId);
    } catch (e) {
      debugPrint('Error updating user subscription: $e');
      throw Exception('Failed to update subscription status: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final response = await _supabaseProvider.supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<void> _createUserProfile(String userId, String email, String? fullName) async {
    try {
      // Check if profile already exists
      final existingProfile = await _getUserData(userId);
      if (existingProfile != null) {
        logger.i('User profile already exists, skipping creation');
        return;
      }

      await _supabaseProvider.supabase.from('user_profiles').insert({
        'user_id': userId,
        'email': email,
        'full_name': fullName,
        'has_subscription': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('User profile created successfully');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // We don't throw here to allow the sign-up to complete even if profile creation fails
    }
  }

  UserModel _mapToUserModel(User user, Map<String, dynamic>? userData) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: userData?['full_name'] ?? user.userMetadata?['full_name'],
      createdAt: userData?['created_at'] != null
          ? DateTime.parse(userData!['created_at'])
          : DateTime.parse(user.createdAt),
      hasSubscription: userData?['has_subscription'] ?? false,
    );
  }
}
