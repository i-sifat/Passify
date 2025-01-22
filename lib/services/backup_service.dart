import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class BackupService {
  static const String fileExtension = 'passifybackup';

  /// Generates a backup file for the given passwords.
  Future<String?> backupPasswords(
      List<PasswordEntry> passwords, String masterPassword) async {
    try {
      // Convert passwords to JSON.
      final passwordsJson = passwords.map((p) => p.toJson()).toList();

      // Generate encryption key and IV.
      final key = _generateKey(masterPassword);
      final iv = _generateIV();

      // Encrypt the data.
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(jsonEncode(passwordsJson), iv: iv);

      // Create backup content.
      final backupContent = jsonEncode({
        'iv': base64Encode(iv.bytes),
        'data': encrypted.base64,
      });

      // Prompt the user to save the file.
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Passify Backup',
        fileName:
            'passify_backup_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        type: FileType.custom,
        allowedExtensions: [fileExtension],
      );

      if (outputFile == null || outputFile.isEmpty) {
        debugPrint('Save operation canceled.');
        return null;
      }

      // Write content to the file.
      await File(outputFile).writeAsString(backupContent);
      return outputFile;
    } catch (e, stacktrace) {
      debugPrint('Error creating backup: $e');
      debugPrint('Stacktrace: $stacktrace');
      return null;
    }
  }

  /// Restores passwords from a backup file.
  Future<List<PasswordEntry>?> restorePasswords(String masterPassword) async {
    try {
      // Let the user pick a file.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [fileExtension],
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('No file selected.');
        return null;
      }

      // Read the file content.
      final filePath = result.files.single.path;
      if (filePath == null || filePath.isEmpty) {
        debugPrint('File path is invalid or empty.');
        return null;
      }

      final fileContent = await File(filePath).readAsString();
      final Map<String, dynamic> backupData = jsonDecode(fileContent);

      // Extract IV and encrypted data.
      final iv = encrypt.IV(base64Decode(backupData['iv'] as String));
      final encryptedData = backupData['data'] as String;

      // Decrypt the data.
      final key = _generateKey(masterPassword);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter
          .decrypt(encrypt.Encrypted.fromBase64(encryptedData), iv: iv);

      // Parse JSON back to a list of PasswordEntry objects.
      final List<dynamic> passwordsJson = jsonDecode(decrypted);
      return passwordsJson.map((json) => PasswordEntry.fromJson(json)).toList();
    } catch (e, stacktrace) {
      debugPrint('Error restoring backup: $e');
      debugPrint('Stacktrace: $stacktrace');
      return null;
    }
  }

  /// Generates a 32-byte encryption key from the master password.
  encrypt.Key _generateKey(String masterPassword) {
    final key = List<int>.generate(32,
        (i) => i < masterPassword.length ? masterPassword.codeUnitAt(i) : 0);
    return encrypt.Key(Uint8List.fromList(key));
  }

  /// Generates a 16-byte random IV.
  encrypt.IV _generateIV() {
    final random = encrypt.SecureRandom(16);
    return encrypt.IV(random.bytes);
  }
}

/// A model class representing a password entry.
/// Replace this with your actual implementation.
class PasswordEntry {
  final String title;
  final String username;
  final String password;

  PasswordEntry(
      {required this.title, required this.username, required this.password});

  /// Converts a PasswordEntry to JSON.
  Map<String, dynamic> toJson() => {
        'title': title,
        'username': username,
        'password': password,
      };

  /// Creates a PasswordEntry from JSON.
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      title: json['title'],
      username: json['username'],
      password: json['password'],
    );
  }
}
