import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'i_hive_service.dart';

class HiveServiceImpl implements IHiveService {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
  }

  @override
  Future<Box<T>> openBox<T>(String boxName) async {
    return await Hive.openBox<T>(boxName);
  }

  @override
  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  @override
  Future<void> closeAll() async {
    await Hive.close();
  }

  @override
  bool containsKey(String key, {required String boxName}) {
    final box = Hive.box(boxName);
    return box.containsKey(key);
  }

  @override
  T? get<T>(String key, {required String boxName, T? defaultValue}) {
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  @override
  Future<void> put<T>(String key, T value, {required String boxName}) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  @override
  Future<void> delete(String key, {required String boxName}) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  @override
  List<dynamic> getKeys({required String boxName}) {
    final box = Hive.box(boxName);
    return box.keys.toList();
  }

  @override
  List<dynamic> getValues({required String boxName}) {
    final box = Hive.box(boxName);
    return box.values.toList();
  }

  @override
  Future<void> clear({required String boxName}) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  @override
  ValueListenable<Box<dynamic>> getListenable({required String boxName}) {
    final box = Hive.box(boxName);
    return box.listenable();
  }
}
