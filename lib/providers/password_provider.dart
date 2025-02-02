import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/password_checker_service.dart';
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
            }))
        .toList();

    await prefs.setStringList(_passwordsKey, passwordsJson);
  }

  Future<void> addPassword(PasswordEntry entry) async {
    // Check if password is compromised
    final compromisedCount = await PasswordCheckerService.checkPassword(entry.password);
    final isCompromised = compromisedCount > 0;
    
    final newEntry = PasswordEntry(
      name: entry.name,
      url: entry.url,
      email: entry.email,
      password: entry.password,
      lastUpdated: entry.lastUpdated,
      isCompromised: isCompromised,
      icon: entry.icon,
    );

    state = [...state, newEntry];
    await _savePasswords();
  }

  Future<void> updatePassword(PasswordEntry oldEntry, PasswordEntry newEntry) async {
    // Check if new password is compromised
    final compromisedCount = await PasswordCheckerService.checkPassword(newEntry.password);
    final isCompromised = compromisedCount > 0;
    
    final updatedEntry = PasswordEntry(
      name: newEntry.name,
      url: newEntry.url,
      email: newEntry.email,
      password: newEntry.password,
      lastUpdated: newEntry.lastUpdated,
      isCompromised: isCompromised,
      icon: newEntry.icon,
    );

    state = state
        .map((entry) => entry.name == oldEntry.name &&
                entry.url == oldEntry.url &&
                entry.email == oldEntry.email
            ? updatedEntry
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

  Future<void> checkAllPasswords() async {
    List<PasswordEntry> updatedEntries = [];
    
    for (var entry in state) {
      final compromisedCount = await PasswordCheckerService.checkPassword(entry.password);
      final isCompromised = compromisedCount > 0;
      
      updatedEntries.add(PasswordEntry(
        name: entry.name,
        url: entry.url,
        email: entry.email,
        password: entry.password,
        lastUpdated: entry.lastUpdated,
        isCompromised: isCompromised,
        icon: entry.icon,
      ));
    }
    
    state = updatedEntries;
    await _savePasswords();
  }
}