import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/services/cloudinary_storage_service.dart';
import '../../core/time/time_status_service.dart';

class CustomersPushService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> pushUnsynced() async {
    if (!await ConnectivityService.isOnline) return;
    await _pushBox(BoxNames.customersBox);
    await _pushBox(BoxNames.customerDealsBox);
  }

  static Future<void> _pushBox(String boxName) async {
    try {
      final box = HiveBoxManager.getBox(boxName);
      final WriteBatch batch = _firestore.batch();
      final Map<String, dynamic> syncedLocalUpdates = {};
      int count = 0;

      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map && raw['isSynced'] == false) {
          final docId = key.toString();
          final payload = Map<String, dynamic>.from(raw);

          if (boxName == BoxNames.customerDealsBox) {
            final cnic = payload['customerCnic']?.toString() ?? '';
            final delivPath = payload['deliveryPhotoPath']?.toString() ?? '';
            if (delivPath.isNotEmpty && !delivPath.startsWith('http')) {
              final url =
                  await CloudinaryStorageService.uploadCustomerDealPhoto(
                customerCnic: cnic,
                dealId: docId,
                filePath: delivPath,
                photoType: 'delivery',
              );
              if (url != null) {
                payload['deliveryPhotoUrl'] = url;
              }
            }

            final signedPath = payload['signedDocPhotoPath']?.toString() ?? '';
            if (signedPath.isNotEmpty && !signedPath.startsWith('http')) {
              final url =
                  await CloudinaryStorageService.uploadCustomerDealPhoto(
                customerCnic: cnic,
                dealId: docId,
                filePath: signedPath,
                photoType: 'signed_stamp',
              );
              if (url != null) {
                payload['signedDocPhotoUrl'] = url;
              }
            }
          }

          payload['id'] = docId;
          payload['isSynced'] = true;
          payload['syncedAt'] = TimeStatusService.nowUtcIso();

          final docRef = _firestore.collection(boxName).doc(docId);
          batch.set(docRef, payload, SetOptions(merge: true));
          syncedLocalUpdates[docId] = payload;
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        await HiveBoxManager.putBatch(
          boxName: boxName,
          entries: syncedLocalUpdates,
        );
        debugPrint(
            '✅ CustomersPushService [$boxName]: $count ریکارڈز کلاؤڈ پر سنک ہو گئے');
      }
    } catch (e) {
      debugPrint('❌ CustomersPushService Error [$boxName]: $e');
    }
  }
}