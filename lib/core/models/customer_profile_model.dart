class CustomerProfileModel {
  final String id; // عموماً شناختی کارڈ نمبر
  final String fullName;
  final String fatherName;
  final String cnic;
  final String phone;
  final String address;
  final String role; // 'گاہک' یا 'ضامن'
  final bool isSynced;
  final String updatedAt;
  final String createdAt;
  final bool isDeleted;

  CustomerProfileModel({
    required this.id,
    required this.fullName,
    required this.fatherName,
    required this.cnic,
    required this.phone,
    required this.address,
    this.role = 'گاہک',
    this.isSynced = false,
    required this.updatedAt,
    required this.createdAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'fatherName': fatherName,
      'cnic': cnic,
      'phone': phone,
      'address': address,
      'role': role,
      'isSynced': isSynced,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }

  factory CustomerProfileModel.fromMap(Map<String, dynamic> map) {
    return CustomerProfileModel(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      fatherName: map['fatherName']?.toString() ?? '',
      cnic: map['cnic']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      role: map['role']?.toString() ?? 'گاہک',
      isSynced: map['isSynced'] as bool? ?? false,
      updatedAt: map['updatedAt']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}