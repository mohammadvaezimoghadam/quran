import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Abstract service for local key-value storage operations to support Clean Architecture,
/// true testability (mocking/in-memory substitution), and database independence.
abstract class IHiveService {
  /// Initializes the local database engine.
  Future<void> init();

  /// Opens a storage box asynchronously.
  Future<Box<T>> openBox<T>(String boxName);

  /// Gets an already opened box synchronously.
  Box<T> getBox<T>(String boxName);

  /// Closes all open boxes and releases file locks.
  Future<void> closeAll();

  // ── True Key-Value Operations (Box-agnostic & Decoupled) ──

  /// Checks if a given key exists in the specified box.
  bool containsKey(String key, {required String boxName});

  /// Retrieves a value by key, or returns defaultValue if not found.
  T? get<T>(String key, {required String boxName, T? defaultValue});

  /// Persists a key-value pair in the specified box.
  Future<void> put<T>(String key, T value, {required String boxName});

  /// Removes a key and its associated value from the specified box.
  Future<void> delete(String key, {required String boxName});

  /// Returns all available keys in the specified box.
  List<dynamic> getKeys({required String boxName});

  /// Returns all stored values in the specified box.
  List<dynamic> getValues({required String boxName});

  /// Clears all keys and values from the specified box.
  Future<void> clear({required String boxName});

  /// Returns a [ValueListenable] that emits changes whenever the box is modified.
  ValueListenable<Box<dynamic>> getListenable({required String boxName});
}
