import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _loadAuthState();
  }

  static const _authKey = 'is_authenticated';
  static const _firstTimeKey = 'is_first_time';
  static const _userEmailKey = 'user_email';
  static const _onboardingCompletedKey = 'onboarding_completed';

  // Default credentials
  static const defaultEmail = 'passifyadmin@gmail.com';
  static const defaultPassword = 'passifyadmin';

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_authKey) ?? false;
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  Future<String?> login(String email, String password) async {
    if (email.isEmpty || !email.contains('@')) {
      return 'Please enter a valid email address';
    }

    if (password.isEmpty) {
      return 'Please enter your password';
    }

    if (email == defaultEmail && password == defaultPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString(_userEmailKey, email);
      state = true;
      return null;
    }

    return 'Invalid email or password';
  }

  Future<String?> register(String name, String email, String password,
      String confirmPassword) async {
    if (name.isEmpty) {
      return 'Please enter your name';
    }

    if (email.isEmpty || !email.contains('@')) {
      return 'Please enter a valid email address';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, true);
    await prefs.setString(_userEmailKey, email);
    state = true;
    return null;
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    await prefs.remove(_userEmailKey);
    state = false;
  }
}
