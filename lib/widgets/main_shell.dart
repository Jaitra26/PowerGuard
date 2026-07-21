import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'scale_on_press.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _isBannerDismissed = false;

  void _resendEmail(AuthProvider auth) async {
    try {
      await auth.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Verification email sent! Check your inbox."),
            backgroundColor: AppTheme.success.withValues(alpha: 0.8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error sending verification email. Try again later."),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // Check if user is logged in but email is not verified
    final showBanner = auth.currentUser != null && !auth.isEmailVerified && !_isBannerDismissed;

    return Scaffold(
      body: Column(
        children: [
          if (showBanner)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                border: const Border(
                  bottom: BorderSide(
                    color: AppTheme.warning,
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Please verify your email to unlock all features.",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ScaleOnPress(
                      onTap: () => _resendEmail(auth),
                      child: TextButton(
                        onPressed: () => _resendEmail(auth),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Resend Email",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.onSurfaceVariant,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _isBannerDismissed = true;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
