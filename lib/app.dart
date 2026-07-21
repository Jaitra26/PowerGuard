import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/load_prediction_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/main_shell.dart';

class PowerGuardApp extends StatefulWidget {
  const PowerGuardApp({super.key});

  @override
  State<PowerGuardApp> createState() => _PowerGuardAppState();
}

class _PowerGuardAppState extends State<PowerGuardApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final status = authProvider.status;
        final loc = state.matchedLocation;

        final publicRoutes = ['/login', '/register', '/forgot-password'];
        final isPublic = publicRoutes.contains(loc) || loc == '/splash';

        // Only block on loading if coming from splash
        if (status == AuthStatus.loading && loc == '/splash') return null;

        // If still loading anywhere else, do not redirect — wait
        if (status == AuthStatus.loading) return null;

        if (status == AuthStatus.unauthenticated && !isPublic) {
          return '/login';
        }
        if (status == AuthStatus.authenticated && isPublic) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        // Splash Route
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        // Auth Routes
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ForgotPasswordScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        // Shell Route with persistent BottomNavigationBar wrapped in MainShell
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(
              child: Scaffold(
                body: SafeArea(child: navigationShell),
                bottomNavigationBar: BottomNavBar(navigationShell: navigationShell),
              ),
            );
          },
          branches: [
            // Branch 1: Dashboard
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  pageBuilder: (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const DashboardScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
            // Branch 2: Analytics
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/analytics',
                  pageBuilder: (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const AnalyticsScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
            // Branch 3: Predict
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/prediction',
                  pageBuilder: (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const LoadPredictionScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
            // Branch 4: Alerts
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/alerts',
                  pageBuilder: (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const AlertsScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
            // Branch 5: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  pageBuilder: (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const ProfileScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Global error boundary logging
    FlutterError.onError = (details) {
      debugPrint("PowerGuard Global Error: ${details.exceptionAsString()}");
    };

    return MaterialApp.router(
      title: 'PowerGuard',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
