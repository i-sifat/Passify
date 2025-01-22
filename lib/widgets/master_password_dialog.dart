import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/master_password_service.dart';

class MasterPasswordDialog extends ConsumerStatefulWidget {
  final bool isInitialSetup;

  const MasterPasswordDialog({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  ConsumerState<MasterPasswordDialog> createState() =>
      _MasterPasswordDialogState();
}

class _MasterPasswordDialogState extends ConsumerState<MasterPasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  final _masterPasswordService = MasterPasswordService();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (widget.isInitialSetup) {
      if (_passwordController.text.length < 8) {
        setState(
            () => _errorMessage = 'Password must be at least 8 characters');
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _errorMessage = 'Passwords do not match');
        return;
      }

      await _masterPasswordService.saveMasterPassword(_passwordController.text);
      if (mounted) Navigator.of(context).pop(true);
    } else {
      final isValid = await _masterPasswordService.verifyMasterPassword(
        _passwordController.text,
      );
      if (isValid) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = 'Invalid master password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isInitialSetup ? 'Set Master Password' : 'Enter Master Password',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Master Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          if (widget.isInitialSetup) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Confirm Master Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(widget.isInitialSetup ? 'SET PASSWORD' : 'UNLOCK'),
        ),
      ],
    );
  }
}
