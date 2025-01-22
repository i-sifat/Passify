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
    required this.icon,
  });

  // Add the fromJson method to convert JSON into a PasswordEntry
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      name: json['name'] as String,
      url: json['url'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isCompromised: json['isCompromised'] as bool? ?? false,
      icon: IconData(json['icon'] as int),
    );
  }

  // Convert to JSON method (already defined)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'email': email,
      'password': password,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isCompromised': isCompromised,
      'icon': icon.codePoint,
    };
  }
}
