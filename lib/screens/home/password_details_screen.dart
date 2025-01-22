import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/password_entry.dart';
import '../../providers/password_provider.dart';
import 'update_password_screen.dart';

class PasswordDetailsScreen extends ConsumerWidget {
  final PasswordEntry entry;

  const PasswordDetailsScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.isCompromised ? 'Compromised' : 'Not Compromised',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: entry.isCompromised ? Colors.red : Colors.green,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.name.toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              _buildDetailRow(
                context,
                Icons.calendar_today,
                'Last Updated',
                '${entry.lastUpdated.day} ${_getMonth(entry.lastUpdated.month)} ${entry.lastUpdated.year}',
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.link,
                'URL',
                entry.url,
                showCopy: true,
                onCopy: () => _copyToClipboard(context, entry.url),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.person,
                'Email / Username',
                entry.email,
                showCopy: true,
                onCopy: () => _copyToClipboard(context, entry.email),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.lock,
                'Password',
                entry.password,
                showCopy: true,
                onCopy: () => _copyToClipboard(context, entry.password),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Password'),
                            content: const Text(
                              'Are you sure you want to delete this password?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(passwordProvider.notifier)
                                      .deletePassword(entry);
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pop(context); // Go back to home
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('DELETE'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('DELETE'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdatePasswordScreen(
                              entry: entry,
                            ),
                          ),
                        );
                      },
                      child: const Text('UPDATE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool showCopy = false,
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(value),
            ),
            if (showCopy && onCopy != null)
              IconButton(
                icon: Icon(
                  Icons.content_copy,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: onCopy,
              ),
          ],
        ),
      ],
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
