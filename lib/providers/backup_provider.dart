import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../models/password_entry.dart';

final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier();
});

class BackupState {
  final DateTime? lastBackupDate;
  final bool isProcessing;
  final String? error;

  BackupState({
    this.lastBackupDate,
    this.isProcessing = false,
    this.error,
  });

  BackupState copyWith({
    DateTime? lastBackupDate,
    bool? isProcessing,
    String? error,
  }) {
    return BackupState(
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}

class BackupNotifier extends StateNotifier<BackupState> {
  BackupNotifier() : super(BackupState()) {
    _loadLastBackupDate();
  }

  final _backupService = BackupService();
  static const _lastBackupKey = 'last_backup_date';

  Future<void> _loadLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastBackupKey);
    if (timestamp != null) {
      state = state.copyWith(
        lastBackupDate: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
    }
  }

  Future<void> _saveLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt(_lastBackupKey, now.millisecondsSinceEpoch);
    state = state.copyWith(lastBackupDate: now);
  }

  Future<bool> performBackup(
      List<PasswordEntry> passwords, String masterPassword) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);
      final result = await _backupService.backupPasswords(
        passwords,
        masterPassword,
      );
      if (result != null) {
        await _saveLastBackupDate();
        state = state.copyWith(isProcessing: false);
        return true;
      }
      state = state.copyWith(isProcessing: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<List<PasswordEntry>?> restore(String masterPassword) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);
      final passwords = await _backupService.restorePasswords(masterPassword);
      state = state.copyWith(isProcessing: false);
      return passwords;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      return null;
    }
  }
}
