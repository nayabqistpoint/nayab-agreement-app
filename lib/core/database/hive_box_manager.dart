import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/box_names.dart';

class HiveBoxManager {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(BoxNames.agreementDraftBox),
      Hive.openBox<dynamic>(BoxNames.templatesBox),
      Hive.openBox<dynamic>(BoxNames.customerProfilesBox),
      Hive.openBox<dynamic>(BoxNames.customerDealsBox),
      Hive.openBox<dynamic>(BoxNames.tagsBox),
      Hive.openBox<dynamic>(BoxNames.syncStatusBox),
      Hive.openBox<dynamic>(BoxNames.appConfigBox),
      Hive.openBox<dynamic>(BoxNames.stockBox),
      Hive.openBox<dynamic>(BoxNames.shopOrdersBox),
      Hive.openBox<dynamic>(BoxNames.posDevicesBox),
    ]);
  }

  static Box<dynamic> getBox(String boxName) {
    return Hive.box<dynamic>(boxName);
  }

  static Future<void> putBatch({
    required String boxName,
    required Map<String, dynamic> entries,
  }) async {
    if (entries.isEmpty) return;
    final box = getBox(boxName);
    await box.putAll(entries);
  }

  static Future<void> deleteKey({
    required String boxName,
    required String key,
  }) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  static Future<void> clearBox(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  static ValueListenable<Box<dynamic>> listenToBox(String boxName) {
    return getBox(boxName).listenable();
  }
}