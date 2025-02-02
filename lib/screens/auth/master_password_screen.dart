import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/master_password_service.dart';
import '../home/home_screen.dart';

class MasterPasswordScreen extends ConsumerStatefulWidget {
  final bool isInitialSetup;

  const MasterPasswordScreen({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  ConsumerState<MasterPasswordScreen> createState() =>
      _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends ConsumerState<MasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
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
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      final isValid = await _masterPasswordService
          .verifyMasterPassword(_passwordController.text);
      if (isValid) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() => _errorMessage = 'Invalid master password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isInitialSetup
                    ? 'SET MASTER\nPASSWORD'
                    : 'ENTER MASTER\nPASSWORD',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              Text(
                widget.isInitialSetup
                    ? 'Create a master password to secure your data. This password will be required every time you open the app.'
                    : 'Enter your master password to access your passwords.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
              _buildTextField(
                context,
                widget.isInitialSetup ? 'NEW PASSWORD' : 'MASTER PASSWORD',
                _passwordController,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              if (widget.isInitialSetup) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  'CONFIRM PASSWORD',
                  _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child:
                      Text(widget.isInitialSetup ? 'SET PASSWORD' : 'UNLOCK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
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
