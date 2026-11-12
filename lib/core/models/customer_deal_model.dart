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
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

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
      'deliveryPhotoPath': deliveryPhotoPath,
      'signedDocPhotoPath': signedDocPhotoPath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory CustomerDealModel.fromMap(Map<dynamic, dynamic> map) {
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
      deliveryPhotoPath: map['deliveryPhotoPath']?.toString(),
      signedDocPhotoPath: map['signedDocPhotoPath']?.toString(),
      createdAt: map['createdAt']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString() ?? '',
      isSynced: map['isSynced'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  CustomerDealModel copyWith({
    String? deliveryPhotoPath,
    String? signedDocPhotoPath,
    String? updatedAt,
    bool? isSynced,
  }) {
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
      deliveryPhotoPath: deliveryPhotoPath ?? this.deliveryPhotoPath,
      signedDocPhotoPath: signedDocPhotoPath ?? this.signedDocPhotoPath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted,
    );
  }
}