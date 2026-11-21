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
  static final List<StreamSubscription> _boxSubs = [];
  static bool _isWatcherStarted = false;
  static bool _isSyncing = false;
  static bool _hasQueuedSync = false;

  static void startWatcher() {
    if (_isWatcherStarted) return;
    _isWatcherStarted = true;
    PosLivePullService.startRealtimeListeners();
    for (final boxName in [
      BoxNames.appConfigBox,
      BoxNames.stockBox,
      BoxNames.shopOrdersBox,
      BoxNames.tagsBox,
      BoxNames.posDevicesBox,
    ]) {
      _boxSubs.add(
        HiveBoxManager.getBox(boxName).watch().listen((event) {
          final val = event.value;
          if (val is Map && val['isSynced'] == false) {
            syncAll();
          }
        }),
      );
    }
    for (final boxName in [
      BoxNames.customersBox,
      BoxNames.customerDealsBox,
    ]) {
      _boxSubs.add(
        HiveBoxManager.getBox(boxName).watch().listen((event) {
          final val = event.value;
          if (val is Map && val['isSynced'] == false) {
            CustomersPushService.pushUnsynced();
          }
        }),
      );
    }
    _connectivitySub = ConnectivityService.onConnectivityChanged.listen((online) {
      if (online) {
        PosLivePullService.startRealtimeListeners();
        syncAll();
      }
    });
    syncAll();
  }

  static Future<void> syncAll() async {
    if (_isSyncing) {
      _hasQueuedSync = true;
      return;
    }
    _isSyncing = true;
    try {
      do {
        _hasQueuedSync = false;
        await PosAtomicPushService.pushAllUnsynced();
        await CustomersPushService.pushUnsynced();
        await TemplatesPushService.pushUnsynced();
        await TemplatesPullService.pullAll();
        await CustomersPullService.pullAll();
      } while (_hasQueuedSync);
    } catch (e) {
      debugPrint('MasterSyncHub Error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  static void dispose() {
    _connectivitySub?.cancel();
    for (final sub in _boxSubs) {
      sub.cancel();
    }
    _boxSubs.clear();
    PosLivePullService.stopListeners();
    _isWatcherStarted = false;
  }
}