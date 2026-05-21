class MerchantModel {
  final String? id;
  final String? publicId;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? status;
  final String? avatarUrl;
  final DateTime? emailVerifiedAt;

  MerchantModel({
    this.id,
    this.publicId,
    this.companyName,
    this.email,
    this.phone,
    this.status,
    this.avatarUrl,
    this.emailVerifiedAt,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id']?.toString(),
      publicId: json['public_id']?.toString(),
      companyName: json['company_name'] ?? json['name'],
      email: json['email'],
      phone: json['phone'],
      status: json['status'],
      avatarUrl: json['avatar_url'] ?? json['logo'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'public_id': publicId,
        'company_name': companyName,
        'email': email,
        'phone': phone,
        'status': status,
        'avatar_url': avatarUrl,
      };
}
