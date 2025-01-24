// Update the profile screen to include the new sections
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/update_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'backup_restore_screen.dart';
import 'master_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final isAutofillEnabled = ref.watch(autofillProvider);
    final updateService = UpdateService();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROFILE',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name.isEmpty ? 'User' : profile.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      profile.email.isEmpty ? 'No email set' : profile.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha(179),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              _buildMenuItem(
                context,
                'Update Profile',
                Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Master Password',
                Icons.lock_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MasterPasswordScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Backup and Restore',
                Icons.backup_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupRestoreScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Autofill',
                Icons.password_outlined,
                trailing: Switch(
                  value: isAutofillEnabled,
                  onChanged: (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AutofillSettingsScreen(),
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AutofillSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Check for Updates',
                Icons.system_update_outlined,
                onTap: () async {
                  final updateInfo = await updateService.checkForUpdates();
                  if (context.mounted) {
                    if (updateInfo != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Update Available'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('New version: ${updateInfo.latestVersion}'),
                              const SizedBox(height: 8),
                              const Text('Release Notes:'),
                              Text(updateInfo.releaseNotes),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('LATER'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('UPDATE NOW'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You are using the latest version'),
                        ),
                      );
                    }
                  }
                },
              ),
              _buildMenuItem(
                context,
                isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(
                        isDarkMode ? ThemeMode.light : ThemeMode.dark,
                      );
                },
              ),
              const Spacer(),
              _buildMenuItem(
                context,
                'Logout',
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  await ref.read(profileProvider.notifier).clearProfile();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'v 0.1.2',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha(128),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
