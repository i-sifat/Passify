

import 'package:flutter/material.dart';

class PasswordEntry {
  final String name;
  final String url;
  final String email;
  final String password;
  final DateTime lastUpdated;
  final bool isCompromised;
  final IconData icon;

  PasswordEntry({
    required this.name,
    required this.url,
    required this.email,
    required this.password,
    required this.lastUpdated,
    this.isCompromised = false,
    this.icon = Icons.lock_outline, // Make it a constant default value
  });

  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      name: json['name'] as String,
      url: json['url'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isCompromised: json['isCompromised'] as bool? ?? false,
      icon: Icons.lock_outline, // Always use a constant icon
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'email': email,
      'password': password,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isCompromised': isCompromised,
      // Don't store the icon since we'll always use lock_outline
    };
  }
}
