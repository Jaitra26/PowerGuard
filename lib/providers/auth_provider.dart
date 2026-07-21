import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _subscription;

  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isManualAuthInProgress = false;

  AuthProvider(this._authService) {
    _status = AuthStatus.loading;
    _subscription = _authService.authStateChanges.listen((User? firebaseUser) async {
      if (_isManualAuthInProgress) return;

      if (firebaseUser == null) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // User is logged in — fetch their Firestore profile
      try {
        final userModel = await _authService
            .getUserProfile(firebaseUser.uid)
            .timeout(const Duration(seconds: 5));

        if (userModel != null) {
          _currentUser = userModel;
        } else {
          // Firestore doc missing — create a fallback UserModel from
          // Firebase Auth data so the app still opens
          _currentUser = UserModel(
            uid: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? '',
            phone: '',
            role: 'operator',
            facilityName: '',
            location: '',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            notificationsOn: true,
            autoRefresh: true,
            profileImageUrl: firebaseUser.photoURL ?? '',
          );

          // Also write this fallback doc to Firestore so next login works
          await _authService.createUserProfile(_currentUser!);
        }
      } catch (e) {
        // Firestore fetch timed out or failed — still open the app
        // using Firebase Auth data as fallback
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          phone: '',
          role: 'operator',
          facilityName: '',
          location: '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          notificationsOn: true,
          autoRefresh: true,
          profileImageUrl: firebaseUser.photoURL ?? '',
        );
      }

      // Always resolve to authenticated — NEVER leave status on loading
      _status = AuthStatus.authenticated;
      _isInitialized = true;
      notifyListeners();
    });
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isInitialized => _isInitialized;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Clear errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh User Profile
  Future<void> refreshUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      final profile = await _authService.getUserProfile(firebaseUser.uid);
      if (profile != null) {
        _currentUser = profile;
        notifyListeners();
      }
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isManualAuthInProgress = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);
      
      if (result.success) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        return false;
      }
    } finally {
      _isManualAuthInProgress = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String fullName, String email, String phone, String password) async {
    _isManualAuthInProgress = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      if (result.success) {
        // Return true, but wait for user validation.
        // Sign out immediately so they have to login with verified mail
        await _authService.logout();
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        return false;
      }
    } finally {
      _isManualAuthInProgress = false;
      notifyListeners();
    }
  }

  // Google Sign In
  Future<bool> loginWithGoogle() async {
    _isManualAuthInProgress = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();

      if (result.success) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        return false;
      }
    } finally {
      _isManualAuthInProgress = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isManualAuthInProgress = true;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      _isManualAuthInProgress = false;
      notifyListeners();
    }
  }

  // Send Password Reset
  Future<bool> sendPasswordReset(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.sendPasswordResetEmail(email);

      if (result.success) {
        _status = AuthStatus.unauthenticated;
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        return false;
      }
    } finally {
      notifyListeners();
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? facilityName,
    String? location,
    bool? notificationsOn,
    bool? autoRefresh,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        uid: uid,
        fullName: fullName,
        phone: phone,
        facilityName: facilityName,
        location: location,
        notificationsOn: notificationsOn,
        autoRefresh: autoRefresh,
      );

      if (result.success) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        return false;
      }
    } finally {
      notifyListeners();
    }
  }

  // Change Password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.success) {
        _status = AuthStatus.authenticated;
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        return false;
      }
    } finally {
      notifyListeners();
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    _isManualAuthInProgress = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.deleteAccount();

      if (result.success) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        return false;
      }
    } finally {
      _isManualAuthInProgress = false;
      notifyListeners();
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  // Verification flag helper
  bool get isEmailVerified => _authService.isEmailVerified;
}
