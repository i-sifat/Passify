import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const String _keyPrefix = 'secure_';
  final SharedPreferences _prefs;
  late final encrypt.Encrypter _encrypter;
  late final encrypt.IV _iv;

  SecureStorageService._(this._prefs) {
    // Generate a fixed IV (not ideal for production, but okay for this demo)
    _iv = encrypt.IV.fromLength(16);

    // Generate encryption key from a fixed secret
    final secret = 'your_secret_key_here';
    final key = encrypt.Key.fromUtf8(
        sha256.convert(utf8.encode(secret)).toString().substring(0, 32));
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  static Future<SecureStorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SecureStorageService._(prefs);
  }

  Future<void> write(String key, String value) async {
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await _prefs.setString('$_keyPrefix$key', encrypted.base64);
  }

  Future<String?> read(String key) async {
    final encrypted = _prefs.getString('$_keyPrefix$key');
    if (encrypted == null) return null;

    try {
      final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(String key) async {
    await _prefs.remove('$_keyPrefix$key');
  }

  Future<void> deleteAll() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
