import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileState {
  final String name;
  final String email;

  ProfileState({
    required this.name,
    required this.email,
  });

  ProfileState copyWith({
    String? name,
    String? email,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState(name: '', email: '')) {
    _loadProfile();
  }

  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? '';
    final email = prefs.getString(_emailKey) ?? '';
    state = ProfileState(name: name, email: email);
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      await prefs.setString(_nameKey, name);
    }

    if (email != null) {
      await prefs.setString(_emailKey, email);
    }

    state = state.copyWith(
      name: name ?? state.name,
      email: email ?? state.email,
    );
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    state = ProfileState(name: '', email: '');
  }
}
