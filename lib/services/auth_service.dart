import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  const AuthResult.success({this.user})
      : success = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : success = false,
        user = null;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current firebase user
  User? get currentUser => _auth.currentUser;

  // Check email verification status
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Re-send verification email
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Register
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Create firebase auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const AuthResult.failure("User registration failed.");
      }

      // 2. Send email verification
      await firebaseUser.sendEmailVerification();

      // 3. Update display name
      await firebaseUser.updateDisplayName(fullName.trim());

      // 4. Save profile in Firestore users/{uid}
      final userModel = UserModel(
        uid: firebaseUser.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: "operator",
        facilityName: "",
        location: "",
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        notificationsOn: true,
        autoRefresh: true,
        profileImageUrl: "",
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore());

      return AuthResult.success(user: userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Login
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const AuthResult.failure("Login failed.");
      }

      // Update lastLoginAt in Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });

      // Get profile
      final userModel = await getUserProfile(firebaseUser.uid);
      return AuthResult.success(user: userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Google Sign In
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger OAuth flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult.failure("Google sign-in cancelled by user.");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return const AuthResult.failure("Google login failed.");
      }

      // Check if user already has a document in Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      UserModel userModel;

      if (!userDoc.exists) {
        // Create new user profile document
        userModel = UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? googleUser.displayName ?? "Operator",
          email: firebaseUser.email ?? googleUser.email,
          phone: firebaseUser.phoneNumber ?? "",
          role: "operator",
          facilityName: "",
          location: "",
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          notificationsOn: true,
          autoRefresh: true,
          profileImageUrl: firebaseUser.photoURL ?? googleUser.photoUrl ?? "",
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toFirestore());
      } else {
        userModel = UserModel.fromFirestore(userDoc);
        // Update last login
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });
        userModel = userModel.copyWith(lastLoginAt: DateTime.now());
      }

      return AuthResult.success(user: userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // Password reset
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Fetch user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('getUserProfile failed: $e');
      return null;  // Never throw — caller handles null
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // Fail silently — app still works without Firestore doc
      debugPrint('createUserProfile failed: $e');
    }
  }

  // Update profile variables
  Future<AuthResult> updateProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? facilityName,
    String? location,
    bool? notificationsOn,
    bool? autoRefresh,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (fullName != null) {
        updates['fullName'] = fullName.trim();
        // Also update firebase user display name
        await _auth.currentUser?.updateDisplayName(fullName.trim());
      }
      if (phone != null) updates['phone'] = phone.trim();
      if (facilityName != null) updates['facilityName'] = facilityName.trim();
      if (location != null) updates['location'] = location.trim();
      if (notificationsOn != null) updates['notificationsOn'] = notificationsOn;
      if (autoRefresh != null) updates['autoRefresh'] = autoRefresh;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }

      final updatedModel = await getUserProfile(uid);
      return AuthResult.success(user: updatedModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return const AuthResult.failure("No active session.");
    }

    try {
      final uid = firebaseUser.uid;
      // 1. Delete document
      await _firestore.collection('users').doc(uid).delete();
      
      // 2. Delete auth credentials
      await firebaseUser.delete();
      
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return const AuthResult.failure("User session not found.");
    }

    try {
      // Re-authenticate
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Error mappings
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'requires-recent-login':
        return 'Please log in again to continue.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
