import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/password_entry.dart';
import '../../providers/password_provider.dart';
import 'generate_password_screen.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  final PasswordEntry entry;

  const UpdatePasswordScreen({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _urlController = TextEditingController(text: widget.entry.url);
    _emailController = TextEditingController(text: widget.entry.email);
    _passwordController = TextEditingController(text: widget.entry.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    if (_nameController.text.isEmpty ||
        _urlController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final updatedPassword = PasswordEntry(
      name: _nameController.text,
      url: _urlController.text,
      email: _emailController.text,
      password: _passwordController.text,
      lastUpdated: DateTime.now(),
      icon: widget.entry.icon,
      isCompromised: widget.entry.isCompromised,
    );

    await ref
        .read(passwordProvider.notifier)
        .updatePassword(widget.entry, updatedPassword);

    if (mounted) {
      Navigator.pop(context); // Remove loading indicator
      Navigator.pop(context); // Go back to previous screen
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
                  'UPDATE',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                if (widget.entry.isCompromised) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'This password has been found in data breaches. Please update it to a secure password.',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _buildTextField(
                  context,
                  'NAME',
                  _nameController,
                  hintText: 'Website/App Name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  'URL',
                  _urlController,
                  hintText: 'Website/App Link',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  'EMAIL / USERNAME',
                  _emailController,
                  hintText: 'Email / Username',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  'PASSWORD',
                  _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    final password = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeneratePasswordScreen(),
                      ),
                    );
                    if (password != null) {
                      _passwordController.text = password;
                    }
                  },
                  child: const Text('GENERATE NEW'),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updatePassword,
                    child: const Text('SAVE CHANGES'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    String? hintText,
    bool obscureText = false,
    Widget? suffixIcon,
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
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Colors.grey[800],
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}