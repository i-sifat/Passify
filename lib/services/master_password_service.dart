import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class MasterPasswordService {
  static const _storage = FlutterSecureStorage();
  static const _masterPasswordKey = 'master_password';

  Future<void> saveMasterPassword(String password) async {
    final hashedPassword = _hashPassword(password);
    await _storage.write(key: _masterPasswordKey, value: hashedPassword);
  }

  Future<bool> verifyMasterPassword(String password) async {
    final storedHash = await _storage.read(key: _masterPasswordKey);
    if (storedHash == null) return false;

    final inputHash = _hashPassword(password);
    return storedHash == inputHash;
  }

  Future<bool> hasMasterPassword() async {
    final storedHash = await _storage.read(key: _masterPasswordKey);
    return storedHash != null;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
