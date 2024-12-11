import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_dabang/providers/secure_storage_provider.dart';
import 'package:synchronized/synchronized.dart';

final secretValueProvider =
    StateNotifierProviderFamily<SecretValueStateNotifier, String?, String>(
        (ref, key) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SecretValueStateNotifier(
    key: key,
    secureStorage: secureStorage,
  );
});

class SecretValueStateNotifier extends StateNotifier<String?> {
  final String key;
  final FlutterSecureStorage secureStorage;
  final _lock = Lock();
  DateTime? _lastFetchTime;

  SecretValueStateNotifier({
    required this.key,
    required this.secureStorage,
  }) : super(null);

  Future<String?> fetch() async {
    try {
      _lastFetchTime = DateTime.now();
      await _lock.synchronized(() async {
        state = await secureStorage.read(key: key);
      });
      return state;
    } catch (e) {
      debugPrint('Failed to fetch secret key: $key value: $e');
      await clearAll();
      return null;
    }
  }

  Future<String?> fetchIf(
      [Duration duration = const Duration(minutes: 5)]) async {
    if (_lastFetchTime == null ||
        state == null ||
        DateTime.now().difference(_lastFetchTime!) > duration) {
      return await fetch();
    }
    return state;
  }

  Future<void> setValue(String value) async {
    try {
      await _lock.synchronized(() async {
        await secureStorage.write(key: key, value: value);
      });
      state = value;
    } catch (e) {
      debugPrint('Failed to set secret key: $key value: $e');
      await clearAll();
    }
  }

  Future<void> clearAll() async {
    await _lock.synchronized(() async {
      await secureStorage.deleteAll();
    });
    state = null;
  }

  Future<void> clear() async {
    await _lock.synchronized(() async {
      await secureStorage.delete(key: key);
    });
    state = null;
  }
}
