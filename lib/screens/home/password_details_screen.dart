import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/password_entry.dart';
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
                'Not Compromised',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.green,
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
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.person,
                'Email / Username',
                entry.email,
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.lock,
                'Password',
                entry.password,
                showCopy: true,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement delete
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

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool showCopy = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
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
            if (showCopy)
              IconButton(
                icon: Icon(
                  Icons.content_copy,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // TODO: Implement copy
                },
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