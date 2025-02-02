import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/password_entry.dart';

class PasswordTile extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback onTap;

  const PasswordTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/icons/Dark/Platform=${entry.name}, Color=Negative.png',
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[200]
                      : Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline),
              );
            },
          ),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.content_copy,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: entry.password));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
