import 'package:get/get.dart';

abstract class WalletRepositoryInterface {
  /// `GET /api/v1/merchant/wallet/balance`
  Future<Response> fetchBalance();

  /// `GET /api/v1/merchant/wallet/transactions?offset=&limit=&type=&direction=`
  Future<Response> fetchTransactions({
    int offset = 0,
    int limit = 20,
    String? type,
    String? direction,
  });

  /// `POST /api/v1/merchant/wallet/fund/initiate`
  Future<Response> initiateFund({
    required String provider,
    required double amount,
  });

  /// `GET /api/v1/merchant/wallet/fund/verify?provider=&reference=`
  Future<Response> verifyFund({
    required String provider,
    required String reference,
  });

  /// `GET /api/v1/merchant/wallet/virtual-account`
  Future<Response> fetchVirtualAccounts();
}
