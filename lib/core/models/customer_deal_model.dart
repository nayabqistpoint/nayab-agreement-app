class CustomerDealModel {
  final String id;
  final String customerCnic;
  final String customerName;
  final String mobileModel;
  final String imei;
  final String totalAmount;
  final String advancePayment;
  final String monthlyInstallment;
  final String duration;
  final List<String> bundledTemplates;
  final Map<String, String> snapshotFieldValues;
  final String? deliveryPhotoPath;
  final String? signedDocPhotoPath;
  final List<String> deliveryPhotoPaths;
  final List<String> signedDocPhotoPaths;
  final String createdAt;
  final String updatedAt;
  final bool isSynced;
  final bool isDeleted;

  CustomerDealModel({
    required this.id,
    required this.customerCnic,
    required this.customerName,
    required this.mobileModel,
    required this.imei,
    required this.totalAmount,
    required this.advancePayment,
    required this.monthlyInstallment,
    required this.duration,
    required this.bundledTemplates,
    required this.snapshotFieldValues,
    this.deliveryPhotoPath,
    this.signedDocPhotoPath,
    List<String>? deliveryPhotoPaths,
    List<String>? signedDocPhotoPaths,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  })  : deliveryPhotoPaths = deliveryPhotoPaths ??
            (deliveryPhotoPath != null && deliveryPhotoPath.trim().isNotEmpty
                ? [deliveryPhotoPath.trim()]
                : []),
        signedDocPhotoPaths = signedDocPhotoPaths ??
            (signedDocPhotoPath != null && signedDocPhotoPath.trim().isNotEmpty
                ? [signedDocPhotoPath.trim()]
                : []);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerCnic': customerCnic,
      'customerName': customerName,
      'mobileModel': mobileModel,
      'imei': imei,
      'totalAmount': totalAmount,
      'advancePayment': advancePayment,
      'monthlyInstallment': monthlyInstallment,
      'duration': duration,
      'bundledTemplates': bundledTemplates,
      'snapshotFieldValues': snapshotFieldValues,
      'deliveryPhotoPath':
          deliveryPhotoPaths.isNotEmpty ? deliveryPhotoPaths.first : deliveryPhotoPath,
      'signedDocPhotoPath':
          signedDocPhotoPaths.isNotEmpty ? signedDocPhotoPaths.first : signedDocPhotoPath,
      'deliveryPhotoPaths': deliveryPhotoPaths,
      'signedDocPhotoPaths': signedDocPhotoPaths,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory CustomerDealModel.fromMap(Map<dynamic, dynamic> map) {
    final singleDeliv = map['deliveryPhotoPath']?.toString();
    final singleSigned = map['signedDocPhotoPath']?.toString();

    final List<String> delivList = map['deliveryPhotoPaths'] is List
        ? (map['deliveryPhotoPaths'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList()
        : (singleDeliv != null && singleDeliv.trim().isNotEmpty
            ? [singleDeliv.trim()]
            : []);

    final List<String> signedList = map['signedDocPhotoPaths'] is List
        ? (map['signedDocPhotoPaths'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList()
        : (singleSigned != null && singleSigned.trim().isNotEmpty
            ? [singleSigned.trim()]
            : []);

    return CustomerDealModel(
      id: map['id']?.toString() ?? '',
      customerCnic: map['customerCnic']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      mobileModel: map['mobileModel']?.toString() ?? '',
      imei: map['imei']?.toString() ?? '',
      totalAmount: map['totalAmount']?.toString() ?? '',
      advancePayment: map['advancePayment']?.toString() ?? '',
      monthlyInstallment: map['monthlyInstallment']?.toString() ?? '',
      duration: map['duration']?.toString() ?? '',
      bundledTemplates: map['bundledTemplates'] != null
          ? List<String>.from(map['bundledTemplates'])
          : [],
      snapshotFieldValues: map['snapshotFieldValues'] != null
          ? Map<String, String>.from(map['snapshotFieldValues'])
          : {},
      deliveryPhotoPath: delivList.isNotEmpty ? delivList.first : singleDeliv,
      signedDocPhotoPath:
          signedList.isNotEmpty ? signedList.first : singleSigned,
      deliveryPhotoPaths: delivList,
      signedDocPhotoPaths: signedList,
      createdAt: map['createdAt']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString() ?? '',
      isSynced: map['isSynced'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  CustomerDealModel copyWith({
    String? deliveryPhotoPath,
    String? signedDocPhotoPath,
    List<String>? deliveryPhotoPaths,
    List<String>? signedDocPhotoPaths,
    String? updatedAt,
    bool? isSynced,
  }) {
    final nextDelivList = deliveryPhotoPaths ?? this.deliveryPhotoPaths;
    final nextSignedList = signedDocPhotoPaths ?? this.signedDocPhotoPaths;
    return CustomerDealModel(
      id: id,
      customerCnic: customerCnic,
      customerName: customerName,
      mobileModel: mobileModel,
      imei: imei,
      totalAmount: totalAmount,
      advancePayment: advancePayment,
      monthlyInstallment: monthlyInstallment,
      duration: duration,
      bundledTemplates: bundledTemplates,
      snapshotFieldValues: snapshotFieldValues,
      deliveryPhotoPath: nextDelivList.isNotEmpty
          ? nextDelivList.first
          : (deliveryPhotoPath ?? this.deliveryPhotoPath),
      signedDocPhotoPath: nextSignedList.isNotEmpty
          ? nextSignedList.first
          : (signedDocPhotoPath ?? this.signedDocPhotoPath),
      deliveryPhotoPaths: nextDelivList,
      signedDocPhotoPaths: nextSignedList,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted,
    );
  }
}