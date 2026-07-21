import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/scale_on_press.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Live password strength tracker
  final ValueNotifier<int> _passwordStrength = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateStrength);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    
    _passwordStrength.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final pass = _passwordController.text;
    if (pass.isEmpty) {
      _passwordStrength.value = 0;
      return;
    }
    if (pass.length < 8) {
      _passwordStrength.value = 1; // Weak
      return;
    }
    final hasUpper = pass.contains(RegExp(r'[A-Z]'));
    final hasNumber = pass.contains(RegExp(r'[0-9]'));
    
    if (hasUpper && hasNumber) {
      _passwordStrength.value = 4; // Strong
    } else if (hasUpper || hasNumber) {
      _passwordStrength.value = 3; // Good
    } else {
      _passwordStrength.value = 2; // Fair
    }
  }

  void _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final auth = context.read<AuthProvider>();

      final success = await auth.register(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.mark_email_read, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Account created! Please verify your email.",
                      style: TextStyle(color: AppTheme.success),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.surfaceContainerHighest,
              duration: const Duration(seconds: 5),
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
                      auth.errorMessage ?? "Registration failed. Please try again.",
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

  Widget _buildStrengthSegment(int strength) {
    Color color = AppTheme.outlineVariant.withValues(alpha: 0.3);
    String label = "";

    switch (strength) {
      case 1:
        color = AppTheme.error;
        label = "WEAK";
        break;
      case 2:
        color = AppTheme.warning;
        label = "FAIR";
        break;
      case 3:
        color = Colors.green;
        label = "GOOD";
        break;
      case 4:
        color = AppTheme.primary;
        label = "STRONG";
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Password Strength",
                  style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                ),
                Text(
                  label,
                  style: AppTheme.geistMonoStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: List.generate(4, (index) {
            final segmentIndex = index + 1;
            Color segmentColor = AppTheme.outlineVariant.withValues(alpha: 0.3);
            if (segmentIndex <= strength) {
              segmentColor = color;
            }
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 4.0 : 0.0),
                decoration: BoxDecoration(
                  color: segmentColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                                size: 26,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "PowerGuard",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppTheme.outlineVariant),
                          const SizedBox(height: 16),

                          // Title
                          const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Enter details to request facility operator credentials.",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Full Name
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            enabled: !auth.isLoading,
                            style: const TextStyle(color: AppTheme.onSurface),
                            onChanged: (_) => auth.clearError(),
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Full name is required";
                              }
                              if (value.trim().length < 2) {
                                return "Full name must be at least 2 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email Address
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            enabled: !auth.isLoading,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppTheme.onSurface),
                            onChanged: (_) => auth.clearError(),
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

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            enabled: !auth.isLoading,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: AppTheme.onSurface),
                            onChanged: (_) => auth.clearError(),
                            decoration: const InputDecoration(
                              labelText: "Phone Number",
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Phone number is required";
                              }
                              final digitsOnly = RegExp(r'^\d+$');
                              if (!digitsOnly.hasMatch(value.trim())) {
                                return "Phone number must contain digits only";
                              }
                              if (value.trim().length != 10) {
                                return "Phone number must be exactly 10 digits";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            enabled: !auth.isLoading,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppTheme.onSurface),
                            onChanged: (_) => auth.clearError(),
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
                              if (value.length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              final hasUpper = value.contains(RegExp(r'[A-Z]'));
                              final hasDigit = value.contains(RegExp(r'[0-9]'));
                              if (!hasUpper || !hasDigit) {
                                return "Requires at least 1 uppercase and 1 number";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Live Password Strength Row
                          ValueListenableBuilder<int>(
                            valueListenable: _passwordStrength,
                            builder: (context, val, child) {
                              return _buildStrengthSegment(val);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            enabled: !auth.isLoading,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(color: AppTheme.onSurface),
                            onChanged: (_) => auth.clearError(),
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          ScaleOnPress(
                            onTap: auth.isLoading ? null : _submitRegister,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _submitRegister,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                              ),
                              child: auth.isLoading
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
                                        Icon(Icons.person_add_outlined, color: Colors.black, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "CREATE ACCOUNT",
                                          style: TextStyle(letterSpacing: 1.5),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Link to Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: auth.isLoading
                                    ? null
                                    : () {
                                        context.pop();
                                      },
                                child: const Text(
                                  "Sign In",
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
