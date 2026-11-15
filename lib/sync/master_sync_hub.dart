import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/box_names.dart';
import '../core/database/hive_box_manager.dart';
import '../core/network/connectivity_service.dart';
import 'pull/customers_pull_service.dart';
import 'pull/pos_live_pull_service.dart';
import 'pull/templates_pull_service.dart';
import 'push/customers_push_service.dart';
import 'push/pos_atomic_push_service.dart';
import 'push/templates_push_service.dart';

class MasterSyncHub {
  static StreamSubscription? _connectivitySub;
  static bool _isWatcherStarted = false;

  static void startWatcher() {
    if (_isWatcherStarted) return;
    _isWatcherStarted = true;

    // 1. کلاؤڈ سے لائیو ڈیٹا سننا شروع کریں
    PosLivePullService.startRealtimeListeners();

    // 2. لوکل باکسز میں تبدیلی پر فوری پش ٹریگر کریں (مع tagsBox)
    for (final boxName in [
      BoxNames.appConfigBox,
      BoxNames.stockBox,
      BoxNames.shopOrdersBox,
      BoxNames.tagsBox,
    ]) {
      HiveBoxManager.getBox(boxName).watch().listen((event) {
        final val = event.value;
        if (val is Map && val['isSynced'] == false) {
          PosAtomicPushService.pushAllUnsynced();
        }
      });
    }

    // 3. انٹرنیٹ آن ہوتے ہی بقایا ریکارڈز پش کریں
    _connectivitySub = ConnectivityService.onConnectivityChanged.listen((online) {
      if (online) {
        syncAll();
      }
    });

    // ابتدائی سنک چلائیں
    syncAll();
  }

  static Future<void> syncAll() async {
    try {
      await PosAtomicPushService.pushAllUnsynced();
      await TemplatesPushService.pushUnsynced();
      await CustomersPushService.pushUnsynced();
      await TemplatesPullService.pullAll();
      await CustomersPullService.pullAll();
    } catch (e) {
      debugPrint('MasterSyncHub Error: $e');
    }
  }

  static void dispose() {
    _connectivitySub?.cancel();
    PosLivePullService.stopListeners();
    _isWatcherStarted = false;
  }
}