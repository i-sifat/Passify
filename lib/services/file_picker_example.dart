import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:passify/models/password_entry.dart';

class FilePickerExample {
  // Pick a file and save JSON
  Future<void> pickAndSaveFile(List<PasswordEntry> passwords) async {
    try {
      // Serialize passwords to JSON
      final jsonString =
          jsonEncode(passwords.map((entry) => entry.toJson()).toList());

      // Ask the user to pick a location to save the file
      String? selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: "Save your password file",
        fileName: "passwords.json",
      );

      if (selectedPath != null) {
        // Write JSON data to the selected file
        final file = File(selectedPath);
        await file.writeAsString(jsonString);

        debugPrint("Passwords saved to: $selectedPath");
      } else {
        debugPrint("File save was canceled.");
      }
    } catch (e) {
      debugPrint("Error while saving file: $e");
    }
  }
}
