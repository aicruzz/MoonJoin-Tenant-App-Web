import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class WalletRepository implements WalletRepositoryInterface {
  final ApiClient apiClient;
  WalletRepository({required this.apiClient});

  @override
  Future<Response> fetchBalance() {
    // 8 s timeout — this is the polled endpoint, must fail fast.
    return apiClient.getData(
      AppConstants.walletBalanceUri,
      handleError: false,
      timeoutSeconds: 8,
    );
  }

  @override
  Future<Response> fetchTransactions({
    int offset = 0,
    int limit = 20,
    String? type,
    String? direction,
  }) {
    final query = <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (type != null) 'type': type,
      if (direction != null) 'direction': direction,
    };
    return apiClient.getData(
      AppConstants.walletTransactionsUri,
      query: query,
      handleError: false,
    );
  }

  @override
  Future<Response> initiateFund({
    required String provider,
    required double amount,
  }) {
    return apiClient.postData(
      AppConstants.walletFundInitiateUri,
      {'provider': provider, 'amount': amount},
      handleError: false,
    );
  }

  @override
  Future<Response> verifyFund({
    required String provider,
    required String reference,
  }) {
    // Build the URI manually so the ?provider=&reference= encoding matches
    // what Phase A `WalletController::verifyFund` validates.
    final uri = '${AppConstants.walletFundInitiateUri.replaceAll('/initiate', '/verify')}'
        '?provider=${Uri.encodeQueryComponent(provider)}'
        '&reference=${Uri.encodeQueryComponent(reference)}';
    return apiClient.getData(uri, handleError: false, timeoutSeconds: 20);
  }

  @override
  Future<Response> fetchVirtualAccounts() {
    return apiClient.getData(
      AppConstants.walletVirtualAccountUri,
      handleError: false,
    );
  }
}
