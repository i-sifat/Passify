import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'secure_storage_service.dart';

class MasterPasswordService {
  static const _masterPasswordKey = 'master_password';
  late final SecureStorageService _storage;

  Future<void> initialize() async {
    _storage = await SecureStorageService.getInstance();
  }

  Future<void> saveMasterPassword(String password) async {
    final hashedPassword = _hashPassword(password);
    await _storage.write(_masterPasswordKey, hashedPassword);
  }

  Future<bool> verifyMasterPassword(String password) async {
    final storedHash = await _storage.read(_masterPasswordKey);
    if (storedHash == null) return false;

    final inputHash = _hashPassword(password);
    return storedHash == inputHash;
  }

  Future<bool> hasMasterPassword() async {
    final storedHash = await _storage.read(_masterPasswordKey);
    return storedHash != null;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
