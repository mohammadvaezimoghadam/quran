import 'package:hive_flutter/hive_flutter.dart';

/// Abstract service for Hive operations to support clean architecture and Dependency Injection.
abstract class IHiveService {
  /// Initializes Hive for Flutter. Should be called before opening any boxes.
  Future<void> init();

  /// Opens a box asynchronously.
  Future<Box<T>> openBox<T>(String boxName);

  /// Gets an already opened box synchronously.
  Box<T> getBox<T>(String boxName);

  /// Closes all open boxes.
  Future<void> closeAll();
}
