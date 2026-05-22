/// Mirrors the Phase A `WalletController::initiateFund` JSON response:
/// ```
/// {"data": {
///   "reference": "mw_paystack_xxx",
///   "authorization_url": "https://checkout.paystack.com/...",
///   "provider": "paystack",
///   "callback_url": "https://admin.moonjoin.com/api/v1/merchant/wallet/fund/verify?provider=paystack"
/// }}
/// ```
class FundSessionModel {
  final String reference;
  final String authorizationUrl;
  final String provider;
  final String callbackUrl;

  const FundSessionModel({
    required this.reference,
    required this.authorizationUrl,
    required this.provider,
    required this.callbackUrl,
  });

  factory FundSessionModel.fromJson(Map<String, dynamic> json) {
    return FundSessionModel(
      reference: json['reference']?.toString() ?? '',
      authorizationUrl: json['authorization_url']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      callbackUrl: json['callback_url']?.toString() ?? '',
    );
  }
}
