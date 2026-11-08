import 'package:flutter/foundation.dart';
import 'pull/customers_pull_service.dart';
import 'pull/templates_pull_service.dart';
import 'push/customers_push_service.dart';
import 'push/templates_push_service.dart';

class MasterSyncHub {
  static Future<void> syncAll() async {
    try {
      await TemplatesPushService.pushUnsynced();
      await CustomersPushService.pushUnsynced();
      await TemplatesPullService.pullAll();
      await CustomersPullService.pullAll();
    } catch (e) {
      debugPrint('MasterSyncHub Error: $e');
    }
  }
}