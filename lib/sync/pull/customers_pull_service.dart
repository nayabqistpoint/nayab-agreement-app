import 'package:flutter/foundation.dart';

class CustomersPullService {
  static Future<void> pullAll() async {
    debugPrint('CustomersPullService: Offline local mode active');
  }
}