import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/password_entry.dart';

class BackupService {
  static const String fileExtension = 'passifybackup';

  Future<String?> backupPasswords(
      List<PasswordEntry> passwords, String masterPassword) async {
    try {
      // Convert passwords to JSON
      final passwordsJson = passwords.map((p) => p.toJson()).toList();

      // Generate encryption key and IV
      final key = _generateKey(masterPassword);
      final iv = _generateIV();

      // Encrypt the data
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(jsonEncode(passwordsJson), iv: iv);

      // Create backup content
      final backupContent = jsonEncode({
        'iv': base64Encode(iv.bytes),
        'data': encrypted.base64,
      });

      // Prompt the user to save the file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Passify Backup',
        fileName:
            'passify_backup_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        type: FileType.custom,
        allowedExtensions: [fileExtension],
      );

      if (outputFile == null) {
        return null;
      }

      // Write content to the file
      await File(outputFile).writeAsString(backupContent);
      return outputFile;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return null;
    }
  }

  Future<List<PasswordEntry>?> restorePasswords(String masterPassword) async {
    try {
      // Let the user pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [fileExtension],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return null;
      }

      final fileContent = await File(filePath).readAsString();
      final Map<String, dynamic> backupData = jsonDecode(fileContent);

      // Extract IV and encrypted data
      final iv = encrypt.IV(base64Decode(backupData['iv'] as String));
      final encryptedData = backupData['data'] as String;

      // Decrypt the data
      final key = _generateKey(masterPassword);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter
          .decrypt(encrypt.Encrypted.fromBase64(encryptedData), iv: iv);

      // Parse JSON back to a list of PasswordEntry objects
      final List<dynamic> passwordsJson = jsonDecode(decrypted);
      return passwordsJson
          .map((json) => PasswordEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return null;
    }
  }

  encrypt.Key _generateKey(String masterPassword) {
    final key = List<int>.generate(32,
        (i) => i < masterPassword.length ? masterPassword.codeUnitAt(i) : 0);
    return encrypt.Key(Uint8List.fromList(key));
  }

  encrypt.IV _generateIV() {
    final random = encrypt.SecureRandom(16);
    return encrypt.IV(random.bytes);
  }
}
