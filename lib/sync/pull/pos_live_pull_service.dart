import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';

class PosLivePullService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final List<StreamSubscription> _subscriptions = [];

  static void startRealtimeListeners() {
    stopListeners();
    for (final boxName in [
      BoxNames.appConfigBox,
      BoxNames.stockBox,
      BoxNames.shopOrdersBox,
      BoxNames.tagsBox,
      BoxNames.posDevicesBox,
    ]) {
      _subscriptions.add(
        _firestore.collection(boxName).snapshots().listen(
          (snapshot) => _mirrorSnapshotToHive(boxName, snapshot),
          onError: (e) => debugPrint('LivePull Error [$boxName]: $e'),
        ),
      );
    }
  }

  static Future<void> _mirrorSnapshotToHive(
    String boxName,
    QuerySnapshot snapshot,
  ) async {
    if (snapshot.docs.isEmpty) return;
    final box = HiveBoxManager.getBox(boxName);
    final Map<String, dynamic> updates = {};
    for (final doc in snapshot.docs) {
      final rawData = doc.data();
      if (rawData is! Map) continue;
      final cloudData = Map<String, dynamic>.from(rawData);
      cloudData['id'] = doc.id;
      cloudData['isSynced'] = true;
      final localRaw = box.get(doc.id);
      if (localRaw is Map) {
        if (localRaw['isSynced'] == false) continue;
        final localUpdated = localRaw['updatedAt']?.toString() ?? '';
        final cloudUpdated = cloudData['updatedAt']?.toString() ?? '';
        if (localUpdated == cloudUpdated && localRaw['isSynced'] == true) {
          continue;
        }
      }
      updates[doc.id] = cloudData;
    }
    if (updates.isNotEmpty) {
      await HiveBoxManager.putBatch(boxName: boxName, entries: updates);
    }
  }

  static void stopListeners() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}