import 'dart:async';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/services/ai_usage/ai_usage_tracking_service.dart';
import 'package:deenhub/core/services/ai_usage/models/ai_usage_data.dart';
import 'package:deenhub/features/auth/data/repositories/auth_repository.dart';
import 'package:deenhub/features/auth/data/services/memorization_sync_service.dart';
import 'package:deenhub/features/auth/domain/models/user_model.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../subscription/data/services/subscription_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final MemorizationSyncService _memorizationSyncService;
  final SharedPrefsHelper _prefsHelper;
  StreamSubscription? _authStateSubscription;
  StreamSubscription<bool>? _subscriptionStatusSub; // ADD: Subscription status subscription

  AuthBloc(
      this._authRepository, this._memorizationSyncService, this._prefsHelper)
      : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        checkAuthStatus: (e) => _checkAuthStatus(e, emit),
        signIn: (e) => _signIn(e, emit),
        signUp: (e) => _signUp(e, emit),
        signInWithGoogle: (e) => _signInWithGoogle(e, emit),
        signInWithApple: (e) => _signInWithApple(e, emit),
        signOut: (e) => _signOut(e, emit),
        resetPassword: (e) => _resetPassword(e, emit),
        updateSubscription: (e) => _updateSubscription(e, emit),
      );
    });

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges().listen(
      (user) {
        debugPrint(
            'AuthBloc: Auth state change detected: User is ${user != null ? 'logged in' : 'logged out'}');
        if (user != null) {
          // Always check auth status when user is detected, regardless of current state
          // This ensures Google sign-in completes properly even when in loading state
          add(const AuthEvent.checkAuthStatus());
        } else {
          // Only emit unauthenticated if not already in that state
          if (!state.maybeMap(
              unauthenticated: (_) => true, orElse: () => false)) {
            // This is fine to emit directly in listener since we're not in event handler
            // Add event to ensure proper state transition
            add(AuthEvent.checkAuthStatus());
          }
        }
      },
      onError: (error) {
        debugPrint('AuthBloc: Auth state stream error: $error');
        // Add error event instead of direct emit to avoid testing visibility warning
        add(AuthEvent.checkAuthStatus());
      },
    );

    // Check auth status on init
    add(const AuthEvent.checkAuthStatus());

    // ADD: Subscribe to subscription status changes
    _subscriptionStatusSub = getIt<SubscriptionService>().subscriptionStatusStream.listen(
      (hasSubscription) {
        // Update user's subscription status in the auth state
        final currentState = state;
        if (currentState is _Authenticated) {
          final updatedUser = currentState.user.copyWith(hasSubscription: hasSubscription);
          emit(AuthState.authenticated(updatedUser));
        }
      },
      onError: (error) {
        debugPrint('AuthBloc: Error in subscription status stream: $error');
      },
    );
  }

  Future<void> _checkAuthStatus(
      _CheckAuthStatus event, Emitter<AuthState> emit) async {
    debugPrint('Checking auth status...');
    emit(const AuthState.loading());
    try {
      // First check if we have user ID in shared preferences
      final storedUserId = _prefsHelper.userId;
      final isStoredAsLoggedIn = _prefsHelper.isLoggedIn;

      debugPrint(
          'Stored user ID: $storedUserId, Stored login state: $isStoredAsLoggedIn');

      // Then check with the repository
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        debugPrint('User is authenticated: ${user.email}');

        // Check if we're switching to a different user
        if (storedUserId != null && storedUserId != user.id) {
          debugPrint(
              'User switch detected during auth check: $storedUserId -> ${user.id}. Clearing old user data.');
          final memorizationService = getIt<MemorizationService>();
          await memorizationService.clearAllData();
          await memorizationService.initialize();
        }

        // Update shared preferences
        _prefsHelper.setIsLoggedIn = true;
        _prefsHelper.setUserId = user.id;

        emit(AuthState.authenticated(user));

        // Initialize memorization sync in background without blocking auth
        _initializeMemorizationSync(user.id);

        // Fetch and sync subscription status from API
        _fetchAndSyncSubscriptionStatus(user.id);
      } else {
        debugPrint('User is not authenticated, clearing auth data');
        // Clear shared preferences
        _prefsHelper.clearAuthData();

        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _signIn(_SignIn event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithEmail(
        event.email,
        event.password,
      );

      // Update shared preferences
      _prefsHelper.setIsLoggedIn = true;
      _prefsHelper.setUserId = user.id;

      emit(AuthState.authenticated(user));

      // Initialize memorization sync in background without blocking auth
      _initializeMemorizationSync(user.id);

      // Fetch and sync subscription status from API
      _fetchAndSyncSubscriptionStatus(user.id);

      debugPrint('Login successful for user: ${user.email}');
    } catch (e) {
      debugPrint('Error signing in: $e');
      String errorMessage = 'Login failed';

      // Handle specific error cases
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('email not confirmed') ||
          errorString.contains('email_not_confirmed') ||
          errorString.contains('email verification')) {
        errorMessage =
            'Please check your email and click the verification link before signing in.';
      } else if (errorString.contains('invalid login credentials') ||
          errorString.contains('invalid_credentials')) {
        errorMessage =
            'Invalid email or password. Please check your credentials and try again.';
      } else if (errorString.contains('too many requests') ||
          errorString.contains('rate_limit')) {
        errorMessage =
            'Too many login attempts. Please wait a few minutes and try again.';
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      emit(AuthState.error(errorMessage));
    }
  }

  Future<void> _signUp(_SignUp event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      // Create the user account
      await _authRepository.signUpWithEmail(
        event.email,
        event.password,
        event.fullName,
      );

      // DO NOT save authentication data or log the user in
      // User needs to verify email first

      // Use a special error message to indicate signup success but email verification needed
      emit(const AuthState.error('SIGNUP_SUCCESS_VERIFY_EMAIL'));

      debugPrint(
          'Signup successful for email: ${event.email} - verification required');
    } catch (e) {
      debugPrint('Error signing up: $e');
      String errorMessage = 'Registration failed';

      // Handle specific error cases
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('email already exists') ||
          errorString.contains('email_address_already_in_use') ||
          errorString.contains('user already exists')) {
        errorMessage =
            'An account with this email already exists. Please try signing in instead.';
      } else if (errorString.contains('weak password') ||
          errorString.contains('password_too_weak')) {
        errorMessage =
            'Password is too weak. Please use at least 8 characters with mixed case, numbers, and symbols.';
      } else if (errorString.contains('invalid email') ||
          errorString.contains('invalid_email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      emit(AuthState.error(errorMessage));
    }
  }

  Future<void> _signInWithGoogle(
      _SignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      debugPrint('Starting Google sign-in process...');

      // Add timeout to prevent hanging - reduced for faster response
      await _authRepository.signInWithGoogle().timeout(
        const Duration(seconds: 20), // Reduced from 30 to 20 seconds
        onTimeout: () {
          throw Exception('Google sign-in timed out. Please try again.');
        },
      );

      debugPrint('Google sign-in repository call completed');

      // Wait a moment for auth state to update, then check if user is authenticated
      await Future.delayed(const Duration(milliseconds: 1000));

      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        logger.i('Google sign-in successful: ${currentUser.email}');
        // The auth state listener should handle this, but ensure we're not stuck in loading
      } else {
        debugPrint('Google sign-in completed but no user found');
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      String errorMessage = 'Google login failed';

      if (e.toString().contains('cancelled') ||
          e.toString().contains('canceled')) {
        errorMessage = 'Google sign-in was cancelled';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Google sign-in timed out. Please try again.';
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      emit(AuthState.error(errorMessage));
    }
  }

  Future<void> _signInWithApple(
      _SignInWithApple event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      debugPrint('Starting Apple sign-in process...');

      // Add timeout to prevent hanging
      await _authRepository.signInWithApple().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Apple sign-in timed out. Please try again.');
        },
      );

      debugPrint('Apple sign-in repository call completed');

      // Wait a moment for auth state to update, then check if user is authenticated
      await Future.delayed(const Duration(milliseconds: 1000));

      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        logger.i('Apple sign-in successful: ${currentUser.email}');
        // The auth state listener should handle this, but ensure we're not stuck in loading
      } else {
        debugPrint('Apple sign-in completed but no user found');
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      String errorMessage = 'Apple login failed';

      if (e.toString().contains('cancelled') ||
          e.toString().contains('canceled')) {
        errorMessage = 'Apple sign-in was cancelled';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Apple sign-in timed out. Please try again.';
      } else if (e.toString().contains('not available')) {
        errorMessage = 'Apple Sign In is not available on this device.';
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      emit(AuthState.error(errorMessage));
    }
  }

  Future<void> _signOut(_SignOut event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: Starting sign out process');
    emit(const AuthState.loading());
    try {
      // Make sure to sync memorization data before signing out
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        debugPrint('AuthBloc: Starting background upload before signing out');
        // Start upload in background without blocking logout
        _performBackgroundUpload(currentUser.id);
      }

      // Handle user logout (clears data and notifies UI)
      await _memorizationSyncService.handleUserLogout();

      await _authRepository.signOut();

      // Clear shared preferences
      _prefsHelper.clearAuthData();

      emit(const AuthState.unauthenticated());

      debugPrint('AuthBloc: User signed out successfully');
    } catch (e) {
      debugPrint('AuthBloc: Error signing out: $e');
      String errorMessage = 'Failed to sign out';

      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      // Even if there's an error, ensure we're logged out
      _prefsHelper.clearAuthData();
      await _memorizationSyncService.handleUserLogout();

      emit(const AuthState.unauthenticated());
      debugPrint('AuthBloc: Sign out error handled: $errorMessage');
    }
  }

  Future<void> _resetPassword(
      _ResetPassword event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const AuthState.unauthenticated());

      debugPrint('Password reset email sent to: ${event.email}');
    } catch (e) {
      debugPrint('Error resetting password: $e');
      String errorMessage = 'Failed to reset password';

      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      emit(AuthState.error(errorMessage));
    }
  }

  Future<void> _updateSubscription(
      _UpdateSubscription event, Emitter<AuthState> emit) async {
    try {
      final currentState = state;
      if (currentState is _Authenticated) {
        final user = currentState.user;

        // Update subscription status locally
        final updatedUser =
            user.copyWith(hasSubscription: event.hasSubscription);
        emit(AuthState.authenticated(updatedUser));

        // Update subscription status in database
        await _authRepository.updateUserSubscription(
            user.id, event.hasSubscription);

        debugPrint('Subscription status updated: ${event.hasSubscription}');
      }
    } catch (e) {
      debugPrint('Error updating subscription: $e');
      String errorMessage = 'Failed to update subscription';

      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      emit(AuthState.error(errorMessage));
    }
  }

  // Helper method to initialize memorization sync without blocking auth
  void _initializeMemorizationSync(String userId) async {
    try {
      logger.i('Initializing memorization sync for user: $userId');

      // Use the new handleUserLogin method which handles user switching
      await _memorizationSyncService.handleUserLogin(userId);
    } catch (e) {
      debugPrint('Error initializing memorization sync: $e');
      // Don't rethrow to avoid affecting the authentication flow
    }
  }

  // Helper method to perform background upload without blocking logout
  void _performBackgroundUpload(String userId) async {
    try {
      debugPrint('AuthBloc: Performing background upload for user: $userId');
      // Use shorter timeout to prevent hanging during logout
      await _memorizationSyncService
          .uploadMemorizationData(userId)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint(
            'AuthBloc: Background upload timeout - logout will continue');
      });
    } catch (syncError) {
      debugPrint('AuthBloc: Background upload failed: $syncError');
      // Continue silently - logout should not be blocked by sync failures
    }
  }

  // Helper method to fetch subscription status from API and sync to local storage
  void _fetchAndSyncSubscriptionStatus(String userId) async {
    try {
      logger.i('AuthBloc: Fetching subscription status for user: $userId');

      // Get subscription status and AI usage data from Supabase
      final supabase = getIt<SupabaseProvider>().client;
      final response = await supabase
          .from('user_profiles')
          .select('has_subscription, subscription_status, subscription_expiry, ai_usage_data')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        // Parse and save subscription data to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
            'isSubscribed', response['has_subscription'] ?? false);
        await prefs.setString(
            'subscriptionType', response['subscription_status'] ?? '');
        logger.i('subscriptionType: ${response['subscription_status']}');

        if (response['subscription_expiry'] != null) {
          await prefs.setString(
              'subscriptionExpiry', response['subscription_expiry']);
        }

        // Sync AI usage data if available
        if (response['ai_usage_data'] != null) {
          final aiUsageData = response['ai_usage_data'] as Map<String, dynamic>;
          await _syncAIUsageData(aiUsageData);
        }

        debugPrint('AuthBloc: Subscription and AI usage data synced successfully');
      }
    } catch (e) {
      logger.e('AuthBloc: Error fetching subscription status: $e');
      // Don't throw to avoid affecting the authentication flow
    }
  }

  // Helper method to sync AI usage data from Supabase to shared preferences
  Future<void> _syncAIUsageData(Map<String, dynamic> aiUsageData) async {
    try {
      final aiUsageTracker = AIUsageTrackingService();

      // Create AIUsageData object from Supabase data
      final usageData = AIUsageData(
        monthlyTokens: aiUsageData['monthly_tokens'] ?? 0,
        totalRequests: aiUsageData['total_requests'] ?? 0,
        lastResetDate: aiUsageData['last_reset_date'] ?? DateTime.now().toIso8601String(),
        lastUsed: aiUsageData['last_used'],
      );

      // Save to shared preferences using the new method
      await aiUsageTracker.saveAIUsageDataToPrefs(usageData);

      logger.i('AuthBloc: AI usage data synced successfully');
    } catch (e) {
      logger.e('AuthBloc: Error syncing AI usage data: $e');
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    _subscriptionStatusSub?.cancel(); // ADD: Cancel subscription status subscription
    return super.close();
  }
}
