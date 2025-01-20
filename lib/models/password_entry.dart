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
}