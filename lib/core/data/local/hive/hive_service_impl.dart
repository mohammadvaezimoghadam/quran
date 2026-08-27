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
}
