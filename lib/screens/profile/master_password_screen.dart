import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/master_password_service.dart';

class MasterPasswordScreen extends ConsumerStatefulWidget {
  const MasterPasswordScreen({super.key});

  @override
  ConsumerState<MasterPasswordScreen> createState() =>
      _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends ConsumerState<MasterPasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isLoading = false;
  final _masterPasswordService = MasterPasswordService();

  @override
  void initState() {
    super.initState();
    _initializeMasterPasswordService();
  }

  Future<void> _initializeMasterPasswordService() async {
    await _masterPasswordService.initialize();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    if (password.length < 8) {
      setState(
          () => _errorMessage = 'Password must be at least 8 characters long');
      return false;
    }

    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUpperCase ||
        !hasLowerCase ||
        !hasNumbers ||
        !hasSpecialCharacters) {
      setState(() => _errorMessage =
          'Password must contain uppercase, lowercase, numbers, and special characters');
      return false;
    }

    return true;
  }

  Future<void> _updateMasterPassword() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Verify current password
      final isCurrentPasswordValid = await _masterPasswordService
          .verifyMasterPassword(_currentPasswordController.text);

      if (!isCurrentPasswordValid) {
        setState(() {
          _errorMessage = 'Current password is incorrect';
          _isLoading = false;
        });
        return;
      }

      // Validate new password
      if (!_validatePassword(_newPasswordController.text)) {
        setState(() => _isLoading = false);
        return;
      }

      // Check if passwords match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'New passwords do not match';
          _isLoading = false;
        });
        return;
      }

      // Save new password
      await _masterPasswordService
          .saveMasterPassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master password updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update master password. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHANGE MASTER\nPASSWORD',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your master password is used to encrypt all your stored passwords. Make sure to choose a strong password that you can remember.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _buildPasswordField(
                  'CURRENT PASSWORD',
                  _currentPasswordController,
                  _obscureCurrentPassword,
                  () => setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                const SizedBox(height: 24),
                _buildPasswordField(
                  'NEW PASSWORD',
                  _newPasswordController,
                  _obscureNewPassword,
                  () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword),
                ),
                const SizedBox(height: 24),
                _buildPasswordField(
                  'CONFIRM NEW PASSWORD',
                  _confirmPasswordController,
                  _obscureConfirmPassword,
                  () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateMasterPassword,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('UPDATE PASSWORD'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback onToggleVisibility,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Colors.grey[800],
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
