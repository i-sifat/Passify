import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import '../models/password_entry.dart';

final passwordProvider =
    StateNotifierProvider<PasswordNotifier, List<PasswordEntry>>((ref) {
  return PasswordNotifier();
});

class PasswordNotifier extends StateNotifier<List<PasswordEntry>> {
  PasswordNotifier() : super([]) {
    _loadPasswords();
  }

  static const _passwordsKey = 'stored_passwords';

  Future<void> _loadPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = prefs.getStringList(_passwordsKey) ?? [];

    state = passwordsJson.map((json) {
      final Map<String, dynamic> data = jsonDecode(json);
      return PasswordEntry(
        name: data['name'],
        url: data['url'],
        email: data['email'],
        password: data['password'],
        lastUpdated: DateTime.parse(data['lastUpdated']),
        isCompromised: data['isCompromised'] ?? false,
        // Use a constant IconData
        icon: Icons.lock_outline,
      );
    }).toList();
  }

  Future<void> _savePasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = state
        .map((entry) => jsonEncode({
              'name': entry.name,
              'url': entry.url,
              'email': entry.email,
              'password': entry.password,
              'lastUpdated': entry.lastUpdated.toIso8601String(),
              'isCompromised': entry.isCompromised,
              // No need to store icon data as we'll use a constant
            }))
        .toList();

    await prefs.setStringList(_passwordsKey, passwordsJson);
  }

  Future<void> addPassword(PasswordEntry entry) async {
    state = [...state, entry];
    await _savePasswords();
  }

  Future<void> updatePassword(
      PasswordEntry oldEntry, PasswordEntry newEntry) async {
    state = state
        .map((entry) => entry.name == oldEntry.name &&
                entry.url == oldEntry.url &&
                entry.email == oldEntry.email
            ? newEntry
            : entry)
        .toList();
    await _savePasswords();
  }

  Future<void> deletePassword(PasswordEntry entry) async {
    state = state
        .where((e) =>
            e.name != entry.name ||
            e.url != entry.url ||
            e.email != entry.email)
        .toList();
    await _savePasswords();
  }

  Future<void> clearPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordsKey);
    state = [];
  }
}
