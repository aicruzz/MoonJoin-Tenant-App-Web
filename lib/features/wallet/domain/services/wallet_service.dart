import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/fund_session_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/virtual_account_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_balance_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_transaction_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:moonjoin_cloud/features/wallet/domain/services/wallet_service_interface.dart';

class WalletService implements WalletServiceInterface {
  final WalletRepositoryInterface walletRepo;
  WalletService({required this.walletRepo});

  @override
  Future<ResponseModel> getBalance() async {
    final response = await walletRepo.fetchBalance();
    if (!_isOk(response)) return _failure(response, 'Could not load balance');

    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        WalletBalancePayload(WalletBalanceModel.fromJson(data)),
      );
    }
    return ResponseModel(false, 'Unexpected balance response');
  }

  @override
  Future<ResponseModel> getTransactions({
    int offset = 0,
    int limit = 20,
    String? type,
    String? direction,
  }) async {
    final response = await walletRepo.fetchTransactions(
      offset: offset,
      limit: limit,
      type: type,
      direction: direction,
    );
    if (!_isOk(response)) return _failure(response, 'Could not load transactions');

    final body = response.body;
    if (body is Map<String, dynamic>) {
      final raw = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? PageMeta.fromJson(Map<String, dynamic>.from(body['meta'] as Map))
          : const PageMeta(offset: 0, limit: 0, total: 0);
      final List<WalletTransactionModel> items = (raw is List)
          ? raw
              .whereType<Map>()
              .map((e) => WalletTransactionModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const [];
      return ResponseModel(
        true,
        'ok',
        WalletTransactionsPayload(items: items, meta: meta),
      );
    }
    return ResponseModel(false, 'Unexpected transactions response');
  }

  @override
  Future<ResponseModel> getVirtualAccounts() async {
    final response = await walletRepo.fetchVirtualAccounts();
    if (!_isOk(response)) return _failure(response, 'Could not load virtual accounts');

    final raw = _data(response);
    if (raw is List) {
      final items = raw
          .whereType<Map>()
          .map((e) =>
              VirtualAccountModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
      return ResponseModel(true, 'ok', VirtualAccountsPayload(items));
    }
    return ResponseModel(false, 'Unexpected virtual-account response');
  }

  @override
  Future<ResponseModel> initiateFund({
    required String provider,
    required double amount,
  }) async {
    final response = await walletRepo.initiateFund(
      provider: provider,
      amount: amount,
    );
    if (!_isOk(response)) return _failure(response, 'Could not start funding');

    final data = _data(response);
    if (data is Map<String, dynamic>) {
      return ResponseModel(
        true,
        'ok',
        FundInitiationPayload(FundSessionModel.fromJson(data)),
      );
    }
    return ResponseModel(false, 'Unexpected funding response');
  }

  @override
  Future<ResponseModel> verifyFund({
    required String provider,
    required String reference,
  }) async {
    final response = await walletRepo.verifyFund(
      provider: provider,
      reference: reference,
    );
    if (!_isOk(response)) return _failure(response, 'Could not verify funding');

    final data = _data(response);
    if (data is Map<String, dynamic>) {
      WalletBalanceModel? balance;
      final balanceRaw = data['balance'];
      if (balanceRaw is Map<String, dynamic>) {
        balance = WalletBalanceModel.fromJson(balanceRaw);
      } else if (balanceRaw is Map) {
        balance = WalletBalanceModel.fromJson(Map<String, dynamic>.from(balanceRaw));
      }
      return ResponseModel(
        true,
        'ok',
        FundVerificationPayload(
          status: data['status']?.toString() ?? 'success',
          amount: _toDouble(data['amount']),
          reference: data['reference']?.toString() ?? reference,
          balance: balance,
        ),
      );
    }
    return ResponseModel(false, 'Unexpected verify response');
  }

  // --- helpers ---

  bool _isOk(Response response) => response.statusCode == 200;

  dynamic _data(Response response) {
    final body = response.body;
    if (body is Map<String, dynamic>) return body['data'] ?? body;
    if (body is Map) return Map<String, dynamic>.from(body)['data'];
    return null;
  }

  ResponseModel _failure(Response response, String fallback) {
    String message = response.statusText ?? fallback;
    final body = response.body;
    if (body is Map) {
      if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
        final first = (body['errors'] as List).first;
        if (first is Map && first['message'] != null) {
          message = first['message'].toString();
        }
      } else if (body['message'] != null) {
        message = body['message'].toString();
      }
    }
    return ResponseModel(false, message);
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
