import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

class GeneratePasswordScreen extends ConsumerStatefulWidget {
  const GeneratePasswordScreen({super.key});

  @override
  ConsumerState<GeneratePasswordScreen> createState() =>
      _GeneratePasswordScreenState();
}

class _GeneratePasswordScreenState
    extends ConsumerState<GeneratePasswordScreen> {
  String _generatedPassword = '';
  int _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_includeLowercase) chars += lowercase;
    if (_includeUppercase) chars += uppercase;
    if (_includeNumbers) chars += numbers;
    if (_includeSymbols) chars += symbols;

    if (chars.isEmpty) {
      chars = lowercase; // Default to lowercase if nothing is selected
    }

    final random = Random.secure();
    _generatedPassword = List.generate(
        _passwordLength, (index) => chars[random.nextInt(chars.length)]).join();
    setState(() {});
  }

  void _onSliderChanged(double value) {
    Vibration.vibrate(duration: 10);
    setState(() {
      _passwordLength = value.round();
      _generatePassword();
    });
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
              _buildLengthSelector(context),
              const SizedBox(height: 24),
              _buildOptionSwitch(
                context,
                'Include Uppercase Letters',
                _includeUppercase,
                (value) => setState(() {
                  _includeUppercase = value;
                  _generatePassword();
                }),
              ),
              _buildOptionSwitch(
                context,
                'Include Lowercase Letters',
                _includeLowercase,
                (value) => setState(() {
                  _includeLowercase = value;
                  _generatePassword();
                }),
              ),
              _buildOptionSwitch(
                context,
                'Include Numbers',
                _includeNumbers,
                (value) => setState(() {
                  _includeNumbers = value;
                  _generatePassword();
                }),
              ),
              _buildOptionSwitch(
                context,
                'Include Symbols',
                _includeSymbols,
                (value) => setState(() {
                  _includeSymbols = value;
                  _generatePassword();
                }),
              ),
              const Spacer(),
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
                      child: const Text('USE PASSWORD'),
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

  Widget _buildLengthSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASSWORD LENGTH: $_passwordLength',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).primaryColor.withAlpha(51),
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withAlpha(26),
          ),
          child: Slider(
            value: _passwordLength.toDouble(),
            min: 8,
            max: 32,
            divisions: 24,
            onChanged: _onSliderChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSwitch(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
