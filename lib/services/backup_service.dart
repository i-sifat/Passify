import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/password_entry.dart';

class BackupService {
  static const String fileExtension = 'passifybackup';

  // Generate encryption key from master password
  encrypt.Key _generateKey(String masterPassword) {
    final bytes = utf8.encode(masterPassword);
    final hash = sha256.convert(bytes);
    return encrypt.Key.fromBase64(base64Encode(hash.bytes));
  }

  // Generate IV for encryption
  encrypt.IV _generateIV() {
    return encrypt.IV.fromSecureRandom(16);
  }

  Future<String?> backupPasswords(
    List<PasswordEntry> passwords,
    String masterPassword,
  ) async {
    try {
      // Convert passwords to JSON
      final passwordsJson = passwords
          .map((p) => {
                'name': p.name,
                'url': p.url,
                'email': p.email,
                'password': p.password,
                'lastUpdated': p.lastUpdated.toIso8601String(),
                'isCompromised': p.isCompromised,
              })
          .toList();

      // Encrypt data
      final key = _generateKey(masterPassword);
      final iv = _generateIV();
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final jsonString = jsonEncode(passwordsJson);
      final encrypted = encrypter.encrypt(jsonString, iv: iv);

      // Create backup data with IV
      final backupData = {
        'iv': base64Encode(iv.bytes),
        'data': encrypted.base64,
      };

      final backupContent = jsonEncode(backupData);

      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'passify_backup_$timestamp.$fileExtension';
      final tempFilePath = '${directory.path}/$fileName';

      // Save the backup file to temp location
      final tempFile = File(tempFilePath);
      await tempFile.writeAsString(backupContent);

      // Let user choose save location
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [fileExtension],
      );

      if (outputPath == null) {
        // User cancelled, clean up temp file
        await tempFile.delete();
        return null;
      }

      // Ensure output path has correct extension
      final String finalPath = outputPath.endsWith('.$fileExtension')
          ? outputPath
          : '$outputPath.$fileExtension';

      // Create output file and write content directly
      final outputFile = File(finalPath);
      await outputFile.writeAsString(backupContent);

      // Clean up temp file
      await tempFile.delete();

      return finalPath;
    } catch (e) {
      debugPrint('Backup error: $e');
      rethrow;
    }
  }

  Future<List<PasswordEntry>> restorePasswords(String masterPassword) async {
    try {
      // Pick backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [fileExtension],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final path = result.files.first.path;
      if (path == null) {
        throw Exception('Invalid file path');
      }

      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Selected file does not exist');
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        throw Exception('Backup file is empty');
      }

      Map<String, dynamic> backupData;
      try {
        backupData = jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid backup file format');
      }

      if (!backupData.containsKey('iv') || !backupData.containsKey('data')) {
        throw Exception('Invalid backup file structure');
      }

      // Decrypt data
      final key = _generateKey(masterPassword);
      final iv = encrypt.IV.fromBase64(backupData['iv'] as String);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      try {
        final decrypted =
            encrypter.decrypt64(backupData['data'] as String, iv: iv);
        final passwordsJson = jsonDecode(decrypted) as List;

        return passwordsJson
            .map((json) => PasswordEntry(
                  name: json['name'] as String,
                  url: json['url'] as String,
                  email: json['email'] as String,
                  password: json['password'] as String,
                  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
                  isCompromised: json['isCompromised'] as bool? ?? false,
                  icon: Icons.lock_outline,
                ))
            .toList();
      } catch (e) {
        throw Exception('Invalid master password or corrupted backup file');
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      rethrow;
    }
  }
}
