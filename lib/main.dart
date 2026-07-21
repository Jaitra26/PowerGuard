import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/energy_provider.dart';
import 'providers/prediction_provider.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure engine binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core, catching duplicate app errors if native layer auto-initialized it
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // If it throws duplicate-app, it means the native layer already initialized it.
    debugPrint('Firebase initialization warning: $e');
  }

  // Set system UI styling (status bar transparent, light icons)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppTheme.surfaceContainerLow,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Lock orientation to portrait for structured mobile dashboards
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => EnergyProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
      ],
      child: const PowerGuardApp(),
    ),
  );
}

