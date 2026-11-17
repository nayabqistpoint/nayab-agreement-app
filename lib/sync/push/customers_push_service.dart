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

          if (boxName == BoxNames.customersBox) {
            final photo = payload['photoUrl']?.toString().trim() ?? '';
            if (photo.isNotEmpty &&
                photo != 'null' &&
                !photo.startsWith('http')) {
              final cleanCnic = docId.replaceAll(RegExp(r'[^0-9]'), '');
              final url = await CloudinaryStorageService.uploadImageFile(
                filePath: photo,
                subFolder:
                    'customers/${cleanCnic.isEmpty ? docId : cleanCnic}/profile',
                customPublicId:
                    'profile_${DateTime.now().millisecondsSinceEpoch}',
              );
              if (url != null) {
                payload['photoUrl'] = url;
              }
            }
          }

          if (boxName == BoxNames.customerDealsBox) {
            final cnic = payload['customerCnic']?.toString() ?? '';

            if (payload['deliveryPhotoPaths'] is List) {
              final rawList = (payload['deliveryPhotoPaths'] as List)
                  .map((e) => e.toString())
                  .where((e) => e.trim().isNotEmpty)
                  .toList();
              final List<String> uploadedDeliv = [];
              for (int i = 0; i < rawList.length; i++) {
                final item = rawList[i];
                if (item.startsWith('http')) {
                  uploadedDeliv.add(item);
                } else {
                  final url =
                      await CloudinaryStorageService.uploadCustomerDealPhoto(
                    customerCnic: cnic,
                    dealId: docId,
                    filePath: item,
                    photoType: 'delivery_${i + 1}',
                  );
                  uploadedDeliv.add(url ?? item);
                }
              }
              payload['deliveryPhotoPaths'] = uploadedDeliv;
              if (uploadedDeliv.isNotEmpty) {
                payload['deliveryPhotoPath'] = uploadedDeliv.first;
              }
            }

            if (payload['signedDocPhotoPaths'] is List) {
              final rawList = (payload['signedDocPhotoPaths'] as List)
                  .map((e) => e.toString())
                  .where((e) => e.trim().isNotEmpty)
                  .toList();
              final List<String> uploadedSigned = [];
              for (int i = 0; i < rawList.length; i++) {
                final item = rawList[i];
                if (item.startsWith('http')) {
                  uploadedSigned.add(item);
                } else {
                  final url =
                      await CloudinaryStorageService.uploadCustomerDealPhoto(
                    customerCnic: cnic,
                    dealId: docId,
                    filePath: item,
                    photoType: 'signed_stamp_${i + 1}',
                  );
                  uploadedSigned.add(url ?? item);
                }
              }
              payload['signedDocPhotoPaths'] = uploadedSigned;
              if (uploadedSigned.isNotEmpty) {
                payload['signedDocPhotoPath'] = uploadedSigned.first;
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