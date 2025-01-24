import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/master_password_service.dart';

final masterPasswordProvider =
    StateNotifierProvider<MasterPasswordNotifier, bool>((ref) {
  return MasterPasswordNotifier();
});

class MasterPasswordNotifier extends StateNotifier<bool> {
  MasterPasswordNotifier() : super(false) {
    _initialize();
  }

  final _masterPasswordService = MasterPasswordService();

  Future<void> _initialize() async {
    await _masterPasswordService.initialize();
    state = await _masterPasswordService.hasMasterPassword();
  }

  Future<bool> verifyMasterPassword(String password) async {
    return _masterPasswordService.verifyMasterPassword(password);
  }

  Future<void> setMasterPassword(String password) async {
    await _masterPasswordService.saveMasterPassword(password);
    state = true;
  }
}