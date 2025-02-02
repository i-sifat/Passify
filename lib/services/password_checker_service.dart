import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class PasswordCheckerService {
  static const String _baseUrl = 'https://api.pwnedpasswords.com/range/';

  /// Checks if a password has been exposed in data breaches
  /// Returns the number of times the password was found in breaches
  /// Returns -1 if there was an error checking the password
  static Future<int> checkPassword(String password) async {
    try {
      // Generate SHA-1 hash of the password
      final bytes = utf8.encode(password);
      final digest = sha1.convert(bytes);
      final hash = digest.toString().toUpperCase();

      // Get the first 5 characters of the hash (prefix)
      final prefix = hash.substring(0, 5);
      // Get the remaining characters (suffix)
      final suffix = hash.substring(5);

      // Make API request with k-anonymity
      final response = await http.get(
        Uri.parse('$_baseUrl$prefix'),
        headers: {
          'User-Agent': 'Passify/1.0',
        },
      );

      if (response.statusCode == 200) {
        // Parse response and check for matches
        final hashes = response.body.split('\r\n');
        for (final line in hashes) {
          final parts = line.split(':');
          if (parts.length == 2) {
            final hashSuffix = parts[0];
            if (hashSuffix.trim() == suffix) {
              return int.parse(parts[1].trim());
            }
          }
        }
        return 0; // Password not found in breaches
      }
      
      throw Exception('Failed to check password: ${response.statusCode}');
    } catch (e) {
      print('Error checking password: $e');
      return -1; // Error occurred
    }
  }
}