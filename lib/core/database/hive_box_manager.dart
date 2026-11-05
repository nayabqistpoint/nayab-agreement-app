import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/box_names.dart';

class HiveBoxManager {
  /// ہائیو کو شروع کرنا اور مطلوبہ تمام باکسز کو کھولنا
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(BoxNames.agreementDraftBox),
      Hive.openBox<dynamic>(BoxNames.templatesBox),
      Hive.openBox<dynamic>(BoxNames.customerProfilesBox),
      Hive.openBox<dynamic>(BoxNames.tagsBox),
    ]);
  }

  /// باکس تک رسائی
  static Box<dynamic> getBox(String boxName) {
    return Hive.box<dynamic>(boxName);
  }

  /// ایٹامک بیچ رائٹ (Zero Single Writes اصول)
  static Future<void> putBatch({
    required String boxName,
    required Map<String, dynamic> entries,
  }) async {
    final box = getBox(boxName);
    await box.putAll(entries);
  }

  /// کسی خاص ریکارڈ کو ڈیلیٹ کرنا
  static Future<void> deleteKey({
    required String boxName,
    required String key,
  }) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  /// پورا باکس خالی کرنا (صرف ری سیٹ کی صورت میں)
  static Future<void> clearBox(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  /// باکس کو سننا (ValueListenable)
  static ValueListenable<Box<dynamic>> listenToBox(String boxName) {
    return getBox(boxName).listenable();
  }
}