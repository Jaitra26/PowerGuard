import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/scale_on_press.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      // Unfocus keyboard
      FocusScope.of(context).unfocus();
      
      final auth = context.read<AuthProvider>();
      
      final success = await auth.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // GoRouter redirect logic handles navigating to /dashboard automatically
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text("Welcome back, ${auth.currentUser?.fullName.split(' ')[0] ?? 'Operator'}!"),
                ],
              ),
              backgroundColor: AppTheme.surfaceContainerHighest,
            ),
          );
        } else {
          // Show custom SnackBar on failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.surfaceContainerHighest,
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.errorMessage ?? "Failed to authenticate.",
                      style: const TextStyle(color: AppTheme.onSurface),
                    ),
                  ),
                ],
              ),
              action: SnackBarAction(
                label: "DISMISS",
                textColor: AppTheme.primary,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    }
  }

  void _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text("Google sign-in successful!"),
              ],
            ),
            backgroundColor: AppTheme.surfaceContainerHighest,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.surfaceContainerHighest,
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppTheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auth.errorMessage ?? "Google sign-in failed.",
                    style: const TextStyle(color: AppTheme.onSurface),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: "DISMISS",
              textColor: AppTheme.primary,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glow Effect behind card header
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.12),
                        AppTheme.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                
                // Centered Main Card
                Card(
                  color: AppTheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App logo row inside card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bolt,
                                color: AppTheme.primary,
                                size: 30,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "PowerGuard",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Precision Energy Monitoring",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppTheme.outlineVariant),
                          const SizedBox(height: 16),
                          
                          // Header
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Enter your credentials to access the dashboard.",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Email Textfield
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            enabled: !authProvider.isLoading,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppTheme.onSurface),
                            onChanged: (_) => authProvider.clearError(),
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email address is required";
                              }
                              final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!regex.hasMatch(value.trim())) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Password Textfield
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            enabled: !authProvider.isLoading,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppTheme.onSurface),
                            onChanged: (_) => authProvider.clearError(),
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: authProvider.isLoading
                                  ? null
                                  : () {
                                      context.push('/forgot-password');
                                    },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          ScaleOnPress(
                            onTap: authProvider.isLoading ? null : _submitLogin,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _submitLogin,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, color: Colors.black, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "SIGN IN",
                                          style: TextStyle(letterSpacing: 1.5),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // OR Separator
                          const Row(
                            children: [
                              Expanded(child: Divider(color: AppTheme.outlineVariant)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppTheme.outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Google Sign In Button
                          ScaleOnPress(
                            onTap: authProvider.isLoading ? null : _googleLogin,
                            child: OutlinedButton(
                              onPressed: authProvider.isLoading ? null : _googleLogin,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppTheme.primary.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(18, 18),
                                    painter: GoogleLogoPainter(),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Link to Register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: authProvider.isLoading
                                    ? null
                                    : () {
                                        context.push('/register');
                                      },
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Bottom Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Protected by PowerGuard Security",
                      style: AppTheme.geistMonoStyle(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Vector Google Logo Painter
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;
    final center = Offset(r, h / 2);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;
    
    final rect = Rect.fromCircle(center: center, radius: r * 0.78);
    
    // Red arc (top-left to top-right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.4, 1.6, false, paint);
    
    // Yellow arc (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -4.0, 1.6, false, paint);
    
    // Green arc (bottom-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.8, 1.2, false, paint);
    
    // Blue arc (middle right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.8, 1.6, false, paint);
    
    // Draw horizontal bar of 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx, center.dy - w * 0.11, r * 0.82, w * 0.22), barPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
