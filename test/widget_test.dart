import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:power_load_app/providers/auth_provider.dart';
import 'package:power_load_app/providers/energy_provider.dart';
import 'package:power_load_app/services/auth_service.dart';
import 'package:power_load_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class MockAuthService implements AuthService {
  final StreamController<fb.User?> _authStateController = StreamController<fb.User?>.broadcast();
  fb.User? _currentUser;
  UserModel? _userProfile;

  MockAuthService() {
    scheduleMicrotask(() => _authStateController.add(null));
  }

  @override
  Stream<fb.User?> get authStateChanges => _authStateController.stream;

  @override
  fb.User? get currentUser => _currentUser;

  @override
  bool get isEmailVerified => true;

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final user = UserModel(
      uid: 'mock_uid_123',
      fullName: fullName,
      email: email,
      phone: phone,
      role: 'operator',
      facilityName: '',
      location: '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      notificationsOn: true,
      autoRefresh: true,
      profileImageUrl: '',
    );
    _userProfile = user;
    return AuthResult.success(user: user);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (email == "hiren.patel@powerguard.gov" && password == "password123") {
      final user = UserModel(
        uid: 'mock_uid_123',
        fullName: 'Hiren Patel',
        email: email,
        phone: '1234567890',
        role: 'operator',
        facilityName: 'Vadodara Grid Substation 4',
        location: 'Vadodara, Gujarat',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        notificationsOn: true,
        autoRefresh: true,
        profileImageUrl: '',
      );
      _userProfile = user;
      return AuthResult.success(user: user);
    } else {
      return const AuthResult.failure("Incorrect credentials.");
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    final user = UserModel(
      uid: 'google_uid_123',
      fullName: 'Google Operator',
      email: 'google@powerguard.gov',
      phone: '',
      role: 'operator',
      facilityName: '',
      location: '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      notificationsOn: true,
      autoRefresh: true,
      profileImageUrl: '',
    );
    _userProfile = user;
    return AuthResult.success(user: user);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _userProfile = null;
    _authStateController.add(null);
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    return const AuthResult.success();
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    return _userProfile;
  }

  @override
  Future<void> createUserProfile(UserModel user) async {
    _userProfile = user;
  }

  @override
  Future<AuthResult> updateProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? facilityName,
    String? location,
    bool? notificationsOn,
    bool? autoRefresh,
  }) async {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(
        fullName: fullName,
        phone: phone,
        facilityName: facilityName,
        location: location,
        notificationsOn: notificationsOn,
        autoRefresh: autoRefresh,
      );
      return AuthResult.success(user: _userProfile);
    }
    return const AuthResult.failure("User profile not found.");
  }

  @override
  Future<AuthResult> deleteAccount() async {
    _currentUser = null;
    _userProfile = null;
    return const AuthResult.success();
  }

  @override
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return const AuthResult.success();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PowerGuard Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('AuthProvider Initial and Login Success Test', () async {
      final mockAuth = MockAuthService();
      final authProvider = AuthProvider(mockAuth);

      // Await initialization of status via auth state stream (yields first event on microtask queue)
      await Future.delayed(Duration.zero);
      
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isInitialized, isTrue);

      // Perform login
      final result = await authProvider.login("hiren.patel@powerguard.gov", "password123");
      
      expect(result, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.email, equals("hiren.patel@powerguard.gov"));
      expect(authProvider.currentUser!.fullName, equals("Hiren Patel"));
      
      // Perform logout
      await authProvider.logout();
      expect(authProvider.currentUser, isNull);
      expect(authProvider.status, equals(AuthStatus.unauthenticated));
    });

    test('EnergyProvider Severity Status Test', () async {
      final energyProvider = EnergyProvider();

      // Telemetry readings and alerts should be empty initially
      expect(energyProvider.readings, isEmpty);
      expect(energyProvider.alerts, isEmpty);
      expect(energyProvider.systemStatus, equals("Normal"));

      // Fetch alerts (simulated latency)
      await energyProvider.fetchAlerts();
      
      expect(energyProvider.alerts, isNotEmpty);
      // System has active critical alerts in mock data, so status must be Critical
      expect(energyProvider.systemStatus, equals("Critical"));

      // Find all critical alerts and resolve them
      final criticalAlerts = energyProvider.alerts.where((a) => a.severity == "Critical").toList();
      for (var alert in criticalAlerts) {
        energyProvider.resolveAlert(alert.id);
      }

      // Find all warning alerts and resolve them
      final warningAlerts = energyProvider.alerts.where((a) => a.severity == "Warning").toList();
      for (var alert in warningAlerts) {
        energyProvider.resolveAlert(alert.id);
      }

      // Now all severities should be resolved, so systemStatus should revert to Normal
      expect(energyProvider.systemStatus, equals("Normal"));
    });
  });
}
