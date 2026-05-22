/// Mirrors the Phase A `VirtualAccountResource` envelope.
class VirtualAccountModel {
  final int id;
  final String provider;
  final String accountNumber;
  final String? accountName;
  final String? bankName;
  final String? bankCode;
  final bool isActive;
  final DateTime? createdAt;

  const VirtualAccountModel({
    required this.id,
    required this.provider,
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.bankCode,
    required this.isActive,
    required this.createdAt,
  });

  factory VirtualAccountModel.fromJson(Map<String, dynamic> json) {
    return VirtualAccountModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      provider: json['provider']?.toString() ?? 'unknown',
      accountNumber: json['account_number']?.toString() ?? '',
      accountName: json['account_name']?.toString(),
      bankName: json['bank_name']?.toString(),
      bankCode: json['bank_code']?.toString(),
      isActive: json['is_active'] == true,
      createdAt: json['created_at'] is String &&
              (json['created_at'] as String).isNotEmpty
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
