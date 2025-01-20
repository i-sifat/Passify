import 'package:flutter/material.dart';
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
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[200]
              : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(entry.icon),
      ),
      title: Text(
        entry.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(
        Icons.content_copy,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}