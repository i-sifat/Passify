import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneratePasswordScreen extends ConsumerStatefulWidget {
  const GeneratePasswordScreen({super.key});

  @override
  ConsumerState<GeneratePasswordScreen> createState() =>
      _GeneratePasswordScreenState();
}

class _GeneratePasswordScreenState extends ConsumerState<GeneratePasswordScreen> {
  String _generatedPassword = '';
  int _passwordLength = 10;
  bool _includeSymbols = true;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = letters + numbers;
    if (_includeSymbols) {
      chars += symbols;
    }

    final random = Random.secure();
    _generatedPassword = List.generate(_passwordLength,
            (index) => chars[random.nextInt(chars.length)]).join();
    setState(() {});
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GENERATE NEW',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _generatedPassword,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PASSWORD LENGTH',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _passwordLength,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[100]
                          : Colors.grey[800],
                    ),
                    items: [8, 10, 12, 14, 16, 18, 20]
                        .map((length) => DropdownMenuItem(
                              value: length,
                              child: Text(length.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _passwordLength = value;
                          _generatePassword();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INCLUDE SYMBOLS',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: _includeSymbols,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[100]
                          : Colors.grey[800],
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Yes'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('No'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _includeSymbols = value;
                          _generatePassword();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _generatePassword,
                      child: const Text('RANDOMIZE'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _generatedPassword),
                        );
                        Navigator.pop(context, _generatedPassword);
                      },
                      child: const Text('COPY'),
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
}