import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../domain/entities/tafakor_user.dart';

final tafakorLocalDataSourceProvider = Provider<TafakorLocalDataSource>((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesInstanceProvider);
  } catch (_) {
    prefs = null;
  }
  return TafakorLocalDataSource(prefs: prefs);
});

class TafakorLocalDataSource {
  final FlutterSecureStorage _storage;
  final SharedPreferences? prefs;

  static String? inMemoryToken;

  static const String _keyToken = 'tafakor_auth_token';
  static const String _keyPhone = 'tafakor_user_phone';
  static const String _keyFirstName = 'tafakor_user_first_name';
  static const String _keyLastName = 'tafakor_user_last_name';
  static const String _keyTelegram = 'tafakor_is_telegram';
  static const String _keyBale = 'tafakor_is_bale';
  static const String _keyPersonalKhatmLastSyncedAt = 'personal_khatm_last_synced_at';

  const TafakorLocalDataSource({
    FlutterSecureStorage? storage,
    this.prefs,
  }) : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  TafakorUser? getUserSync() {
    final token = inMemoryToken ?? prefs?.getString(_keyToken);
    final phone = prefs?.getString(_keyPhone);
    if (token == null || token.isEmpty || phone == null || phone.isEmpty) {
      return null;
    }
    inMemoryToken = token;
    final firstName = prefs?.getString(_keyFirstName) ?? '';
    final lastName = prefs?.getString(_keyLastName) ?? '';
    final telegram = prefs?.getBool(_keyTelegram) ?? false;
    final bale = prefs?.getBool(_keyBale) ?? false;

    return TafakorUser(
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      token: token,
      isTelegramConnected: telegram,
      isBaleConnected: bale,
    );
  }

  Future<void> saveUser(TafakorUser user) async {
    inMemoryToken = user.token;
    if (user.token != null) {
      await _storage.write(key: _keyToken, value: user.token!);
      await prefs?.setString(_keyToken, user.token!);
    }
    await _storage.write(key: _keyPhone, value: user.phone);
    await prefs?.setString(_keyPhone, user.phone);
    await _storage.write(key: _keyFirstName, value: user.firstName);
    await prefs?.setString(_keyFirstName, user.firstName);
    await _storage.write(key: _keyLastName, value: user.lastName);
    await prefs?.setString(_keyLastName, user.lastName);
    await _storage.write(key: _keyTelegram, value: user.isTelegramConnected ? 'true' : 'false');
    await prefs?.setBool(_keyTelegram, user.isTelegramConnected);
    await _storage.write(key: _keyBale, value: user.isBaleConnected ? 'true' : 'false');
    await prefs?.setBool(_keyBale, user.isBaleConnected);
  }

  Future<TafakorUser?> getUser() async {
    final syncUser = getUserSync();
    if (syncUser != null) {
      return syncUser;
    }

    final token = await _storage.read(key: _keyToken);
    final phone = await _storage.read(key: _keyPhone);
    inMemoryToken = token;
    if (token == null || phone == null) return null;

    final firstName = await _storage.read(key: _keyFirstName) ?? '';
    final lastName = await _storage.read(key: _keyLastName) ?? '';
    final telegram = await _storage.read(key: _keyTelegram);
    final bale = await _storage.read(key: _keyBale);

    await prefs?.setString(_keyToken, token);
    await prefs?.setString(_keyPhone, phone);
    await prefs?.setString(_keyFirstName, firstName);
    await prefs?.setString(_keyLastName, lastName);
    await prefs?.setBool(_keyTelegram, telegram == 'true');
    await prefs?.setBool(_keyBale, bale == 'true');

    return TafakorUser(
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      token: token,
      isTelegramConnected: telegram == 'true',
      isBaleConnected: bale == 'true',
    );
  }

  Future<String?> getToken() async {
    if (inMemoryToken != null && inMemoryToken!.isNotEmpty) {
      return inMemoryToken;
    }
    final prefsToken = prefs?.getString(_keyToken);
    if (prefsToken != null && prefsToken.isNotEmpty) {
      inMemoryToken = prefsToken;
      return prefsToken;
    }
    inMemoryToken = await _storage.read(key: _keyToken);
    return inMemoryToken;
  }

  Future<void> clear() async {
    inMemoryToken = null;
    await prefs?.remove(_keyToken);
    await prefs?.remove(_keyPhone);
    await prefs?.remove(_keyFirstName);
    await prefs?.remove(_keyLastName);
    await prefs?.remove(_keyTelegram);
    await prefs?.remove(_keyBale);
    await prefs?.remove(_keyPersonalKhatmLastSyncedAt);

    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyPhone);
    await _storage.delete(key: _keyFirstName);
    await _storage.delete(key: _keyLastName);
    await _storage.delete(key: _keyTelegram);
    await _storage.delete(key: _keyBale);
  }
}
