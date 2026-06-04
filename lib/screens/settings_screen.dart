import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleDeleteAccount(BuildContext context, AuthProvider auth) async {
    final password = await showDialog<String>(
      context: context,
      builder: (context) => DeleteAccountDialog(auth: auth),
    );
    if (password == null) return;

    auth.clearError();
    await auth.deleteAccountWithPassword(password);

    if (context.mounted) {
      if (auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account successfully deleted.'),
            backgroundColor: AppTheme.teal,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    final user = auth.user;
    final email = user?.email ?? 'Anonymous User';
    final uid = user?.uid ?? 'No UID';

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF002D26), Color(0xFF121212), Color(0xFF0A1513)],
            stops: [0.0, 0.6, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFF5F5F5), Color(0xFFB2DFDB)],
            stops: [0.0, 0.7, 1.0],
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.deepTeal),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: AppTheme.glassMorphism(
                  baseColor: isDark ? Colors.grey.shade900 : Colors.white,
                  opacity: isDark ? 0.35 : 0.75,
                  blur: 24,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.teal.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.alternate_email_rounded,
                        size: 40,
                        color: AppTheme.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.deepTeal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.amber : AppTheme.teal).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Email Authentication',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.amber : AppTheme.deepTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'UID: $uid',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Category Title
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  'PREFERENCES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.white60 : AppTheme.deepTeal.withValues(alpha: 0.7),
                  ),
                ),
              ),

              // Theme Settings
              Container(
                decoration: AppTheme.glassMorphism(
                  baseColor: isDark ? Colors.grey.shade900 : Colors.white,
                  opacity: isDark ? 0.2 : 0.6,
                  blur: 10,
                ),
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark themes'),
                  secondary: const Icon(Icons.palette_rounded, color: AppTheme.teal),
                  value: isDark,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                  activeThumbColor: AppTheme.amber,
                  activeTrackColor: AppTheme.amber.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 24),

              // Account Category Title
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  'ACCOUNT ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.white60 : AppTheme.deepTeal.withValues(alpha: 0.7),
                  ),
                ),
              ),

              // Action buttons Container
              Container(
                decoration: AppTheme.glassMorphism(
                  baseColor: isDark ? Colors.grey.shade900 : Colors.white,
                  opacity: isDark ? 0.2 : 0.6,
                  blur: 10,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: AppTheme.teal),
                      title: const Text('Sign Out'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                      onTap: auth.isLoading ? null : () => _handleDeleteAccount(context, auth),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  final AuthProvider auth;
  const DeleteAccountDialog({super.key, required this.auth});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Verify Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'To delete your account, please verify your identity by entering your password.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                floatingLabelStyle: const TextStyle(color: AppTheme.teal),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.teal, width: 2),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Password is required to proceed';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _passwordController.text);
            }
          },
          child: const Text('Delete Account'),
        ),
      ],
    );
  }
}
