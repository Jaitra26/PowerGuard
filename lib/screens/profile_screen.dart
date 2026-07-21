import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../widgets/scale_on_press.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    // Initialize preferences from currentUser if already loaded
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _pushNotifications = user.notificationsOn;
      _autoRefresh = user.autoRefresh;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.statusCritical),
              SizedBox(width: 8),
              Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Are you sure you want to terminate the active monitoring session?",
            style: TextStyle(color: AppTheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ScaleOnPress(
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
                context.go('/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Session terminated. Sign in again to access telemetry."),
                    backgroundColor: AppTheme.warning,
                  ),
                );
              },
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.statusCritical,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {},
                child: const Text("CONFIRM"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditProfileSheet(user: user),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _ChangePasswordSheet(),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DeleteAccountDialog(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.geistMonoStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    final name = user?.fullName ?? "Grid Operator";
    final email = user?.email ?? "operator@powerguard.gov";
    final role = user?.role ?? "Operator";
    final formattedDate = user != null
        ? DateFormat('MMMM yyyy').format(user.createdAt)
        : "January 2024";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. USER HEADER CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppTheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Center(
                        child: Hero(
                          tag: 'profile_avatar',
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              user?.initials ?? "US",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$role | $email",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      ScaleOnPress(
                        onTap: () {},
                        child: OutlinedButton(
                          onPressed: user == null ? null : () => _showEditProfileSheet(context, user),
                          child: const Text("EDIT PROFILE"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. PROJECT INFO CARD
            _buildSectionTitle("Grid Substation Telemetry"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppTheme.surfaceContainerHigh,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.business, color: AppTheme.primary),
                      title: const Text("Facility Name"),
                      subtitle: Text(
                        user != null && user.facilityName.isNotEmpty
                            ? user.facilityName
                            : "Not Specified",
                      ),
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: AppTheme.primary),
                      title: const Text("Location Coordinates"),
                      subtitle: Text(
                        user != null && user.location.isNotEmpty
                            ? user.location
                            : "Not Specified",
                      ),
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    ListTile(
                      leading: const Icon(Icons.calendar_month_outlined, color: AppTheme.primary),
                      title: const Text("Monitoring Since"),
                      subtitle: Text(formattedDate),
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    const ListTile(
                      leading: Icon(Icons.dns_outlined, color: AppTheme.primary),
                      title: Text("API Inference Node"),
                      subtitle: Text("http://localhost:5000"),
                    ),
                  ],
                ),
              ),
            ),

            // 3. SETTINGS CARD
            _buildSectionTitle("Operator Preferences"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppTheme.surfaceContainerHigh,
                child: Column(
                  children: [
                    SwitchListTile(
                      activeThumbColor: AppTheme.primary,
                      title: const Text("Push Notifications"),
                      subtitle: const Text("Alert on critical thefts or load surges"),
                      value: user?.notificationsOn ?? _pushNotifications,
                      onChanged: user == null
                          ? null
                          : (val) async {
                              setState(() {
                                _pushNotifications = val;
                              });
                              final success = await auth.updateProfile(
                                uid: user.uid,
                                notificationsOn: val,
                              );
                              if (!context.mounted) return;
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(auth.errorMessage ?? "Failed to update notification settings."),
                                    backgroundColor: AppTheme.error,
                                  ),
                                );
                              }
                            },
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    SwitchListTile(
                      activeThumbColor: AppTheme.primary,
                      title: const Text("Auto Refresh Data"),
                      subtitle: const Text("Sync active feeds every 5 minutes"),
                      value: user?.autoRefresh ?? _autoRefresh,
                      onChanged: user == null
                          ? null
                          : (val) async {
                              setState(() {
                                _autoRefresh = val;
                              });
                              final success = await auth.updateProfile(
                                uid: user.uid,
                                autoRefresh: val,
                              );
                              if (!context.mounted) return;
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(auth.errorMessage ?? "Failed to update auto-refresh settings."),
                                    backgroundColor: AppTheme.error,
                                  ),
                                );
                              }
                            },
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    const ListTile(
                      title: Text("Telemetry Sync Interval"),
                      trailing: Text(
                        "5 min",
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    ListTile(
                      title: const Text("Export Energy Logs"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Exporting diagnostic JSON array..."),
                            backgroundColor: AppTheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 4. ACCOUNT CARD
            _buildSectionTitle("Security & Account"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppTheme.surfaceContainerHigh,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Change Password"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: user == null ? null : () => _showChangePasswordSheet(context),
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    ListTile(
                      title: const Text("Help & Support Desk"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    ListTile(
                      title: const Text("About PowerGuard Security"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: AppTheme.statusCritical),
                      title: const Text(
                        "Delete Account",
                        style: TextStyle(color: AppTheme.statusCritical),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.statusCritical),
                      onTap: user == null ? null : () => _showDeleteAccountDialog(context),
                    ),
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppTheme.statusCritical),
                      title: const Text(
                        "Sign Out",
                        style: TextStyle(color: AppTheme.statusCritical, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final UserModel user;
  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _facilityController;
  late final TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _facilityController = TextEditingController(text: widget.user.facilityName);
    _locationController = TextEditingController(text: widget.user.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _facilityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Edit Profile",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Please enter your full name.";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              enabled: !_isLoading,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _facilityController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: "Facility Name",
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: "Location Coordinates",
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() == true) {
                        setState(() => _isLoading = true);
                        final auth = context.read<AuthProvider>();
                        final success = await auth.updateProfile(
                          uid: widget.user.uid,
                          fullName: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          facilityName: _facilityController.text.trim(),
                          location: _locationController.text.trim(),
                        );
                        if (!context.mounted) return;
                        setState(() => _isLoading = false);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile updated successfully."),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(auth.errorMessage ?? "Failed to update profile."),
                              backgroundColor: AppTheme.error,
                            ),
                          );
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text("SAVE CHANGES"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Change Password",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentPasswordController,
              enabled: !_isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Please enter your current password.";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              enabled: !_isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                prefixIcon: Icon(Icons.lock_reset),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Please enter a new password.";
                }
                if (val.length < 6) {
                  return "Password must be at least 6 characters.";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              enabled: !_isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
                prefixIcon: Icon(Icons.lock_clock),
              ),
              validator: (val) {
                if (val != _newPasswordController.text) {
                  return "Passwords do not match.";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() == true) {
                        setState(() => _isLoading = true);
                        final auth = context.read<AuthProvider>();
                        final success = await auth.changePassword(
                          _currentPasswordController.text,
                          _newPasswordController.text,
                        );
                        if (!context.mounted) return;
                        setState(() => _isLoading = false);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password changed successfully."),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(auth.errorMessage ?? "Failed to change password."),
                              backgroundColor: AppTheme.error,
                            ),
                          );
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text("CHANGE PASSWORD"),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _confirmController = TextEditingController();
  bool _canDelete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      final isMatch = _confirmController.text.trim() == "DELETE";
      if (isMatch != _canDelete) {
        setState(() => _canDelete = isMatch);
      }
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.statusCritical),
          SizedBox(width: 8),
          Text(
            "Delete Account",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "This action is permanent and will purge your credentials and telemetry profiles. This cannot be undone.",
            style: TextStyle(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const Text(
            "Type \"DELETE\" below to confirm:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: "DELETE",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("CANCEL", style: TextStyle(color: AppTheme.onSurfaceVariant)),
        ),
        ScaleOnPress(
          onTap: _canDelete && !_isLoading ? () {} : null,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusCritical,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: _canDelete && !_isLoading
                ? () async {
                    setState(() => _isLoading = true);
                    final auth = context.read<AuthProvider>();
                    final success = await auth.deleteAccount();
                    if (!context.mounted) return;
                    setState(() => _isLoading = false);
                    if (success) {
                      Navigator.pop(context);
                      context.go('/login');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account permanently deleted."),
                          backgroundColor: AppTheme.statusCritical,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(auth.errorMessage ?? "Failed to delete account."),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                    }
                  }
                : null,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text("DELETE"),
          ),
        ),
      ],
    );
  }
}
