import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/fund_session_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/virtual_account_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_balance_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_transaction_model.dart';

abstract class WalletServiceInterface {
  Future<ResponseModel> getBalance();
  Future<ResponseModel> getTransactions({
    int offset = 0,
    int limit = 20,
    String? type,
    String? direction,
  });
  Future<ResponseModel> getVirtualAccounts();
  Future<ResponseModel> initiateFund({
    required String provider,
    required double amount,
  });
  Future<ResponseModel> verifyFund({
    required String provider,
    required String reference,
  });
}

/// Typed payloads returned via ResponseModel.data — services unwrap the Phase A
/// envelope so controllers never touch raw JSON.

class WalletBalancePayload {
  final WalletBalanceModel balance;
  const WalletBalancePayload(this.balance);
}

class WalletTransactionsPayload {
  final List<WalletTransactionModel> items;
  final PageMeta meta;
  const WalletTransactionsPayload({required this.items, required this.meta});
}

class VirtualAccountsPayload {
  final List<VirtualAccountModel> items;
  const VirtualAccountsPayload(this.items);
}

class FundInitiationPayload {
  final FundSessionModel session;
  const FundInitiationPayload(this.session);
}

class FundVerificationPayload {
  final String status;
  final double amount;
  final String reference;
  final WalletBalanceModel? balance;
  const FundVerificationPayload({
    required this.status,
    required this.amount,
    required this.reference,
    required this.balance,
  });
}
