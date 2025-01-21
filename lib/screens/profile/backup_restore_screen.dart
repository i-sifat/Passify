import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/backup_provider.dart';
import '../../providers/password_provider.dart';
import '../../models/password_entry.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  final _masterPasswordController = TextEditingController();
  List<PasswordEntry>? _backupPasswords;
  bool _showMasterPasswordInput = false;
  bool _isRestore = false;
  String? _errorMessage;

  @override
  void dispose() {
    _masterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleBackup() async {
    if (_masterPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a master password');
      return;
    }

    final currentPasswords = ref.read(passwordProvider);
    final success = await ref.read(backupProvider.notifier).backup(
          currentPasswords,
          _masterPasswordController.text,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup completed successfully')),
        );
        setState(() {
          _showMasterPasswordInput = false;
          _masterPasswordController.clear();
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Backup failed. Please try again.');
      }
    }
  }

  Future<void> _handleRestore() async {
    if (_masterPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a master password');
      return;
    }

    final restoredPasswords = await ref.read(backupProvider.notifier).restore(
          _masterPasswordController.text,
        );

    if (mounted) {
      if (restoredPasswords != null) {
        setState(() {
          _backupPasswords = restoredPasswords;
          _showMasterPasswordInput = false;
          _masterPasswordController.clear();
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Restore failed. Please try again.');
      }
    }
  }

  void _handleMerge(bool replace) {
    if (_backupPasswords == null) return;

    if (replace) {
      ref.read(passwordProvider.notifier).clearPasswords();
      for (var password in _backupPasswords!) {
        ref.read(passwordProvider.notifier).addPassword(password);
      }
    } else {
      for (var password in _backupPasswords!) {
        ref.read(passwordProvider.notifier).addPassword(password);
      }
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passwords restored successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupProvider);
    final currentPasswords = ref.watch(passwordProvider);

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
                'BACKUP &\nRESTORE',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              if (backupState.lastBackupDate != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Last backup: ${_formatDate(backupState.lastBackupDate!)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (_showMasterPasswordInput) ...[
                Text(
                  'MASTER PASSWORD',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _masterPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '********',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: backupState.isProcessing
                        ? null
                        : () {
                            if (_isRestore) {
                              _handleRestore();
                            } else {
                              _handleBackup();
                            }
                          },
                    child: Text(_isRestore ? 'RESTORE' : 'BACKUP'),
                  ),
                ),
              ] else if (_backupPasswords != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT PASSWORDS (${currentPasswords.length})',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildPasswordList(currentPasswords),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'BACKUP PASSWORDS (${_backupPasswords!.length})',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildPasswordList(_backupPasswords!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleMerge(false),
                        child: const Text('APPEND'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleMerge(true),
                        child: const Text('REPLACE ALL'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showMasterPasswordInput = true;
                        _isRestore = false;
                      });
                    },
                    child: const Text('BACKUP NOW'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showMasterPasswordInput = true;
                        _isRestore = true;
                      });
                    },
                    child: const Text('RESTORE FROM BACKUP'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordList(List<PasswordEntry> passwords) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final password = passwords[index];
          return ListTile(
            title: Text(password.name),
            subtitle: Text(password.email),
            trailing: Text(
              _formatDate(password.lastUpdated),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}';
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
