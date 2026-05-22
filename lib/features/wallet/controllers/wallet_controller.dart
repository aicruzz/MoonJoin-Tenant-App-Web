import 'package:moonjoin_cloud/common/controllers/polling_controller.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/fund_session_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/virtual_account_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_balance_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_transaction_model.dart';
import 'package:moonjoin_cloud/features/wallet/domain/services/wallet_service_interface.dart';

/// Drives the wallet screen.
///
/// Polling discipline (per the long-polling efficiency mandate):
/// - Initial load fetches balance + virtual accounts + first transactions page.
/// - The polling tick only re-fetches the **balance** — the lightest payload.
/// - Transactions are refreshed via pull-to-refresh or `loadMore()` on scroll;
///   the polling timer does NOT page through transactions.
class WalletController extends PollingController {
  final WalletServiceInterface walletService;
  WalletController({required this.walletService});

  // --- state ---

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WalletBalanceModel _balance = WalletBalanceModel.empty();
  WalletBalanceModel get balance => _balance;

  final List<WalletTransactionModel> _transactions = [];
  List<WalletTransactionModel> get transactions =>
      List.unmodifiable(_transactions);

  PageMeta _txMeta = const PageMeta(offset: 0, limit: 20, total: 0);
  PageMeta get transactionsMeta => _txMeta;

  List<VirtualAccountModel> _virtualAccounts = const [];
  List<VirtualAccountModel> get virtualAccounts => _virtualAccounts;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  bool _fundInFlight = false;
  bool get fundInFlight => _fundInFlight;

  String? _filterType;
  String? get filterType => _filterType;

  // --- polling ---

  @override
  Duration get pollInterval => const Duration(seconds: 30);

  @override
  Future<void> initialLoad() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();

    // Run the three initial loads in parallel; treat balance as the gating call
    // for the error state since the others are optional context.
    final results = await Future.wait([
      walletService.getBalance(),
      walletService.getTransactions(offset: 0, limit: _txMeta.limit == 0 ? 20 : _txMeta.limit, type: _filterType),
      walletService.getVirtualAccounts(),
    ]);

    final balResult = results[0];
    final txResult = results[1];
    final vaResult = results[2];

    if (balResult.isSuccess && balResult.data is WalletBalancePayload) {
      _balance = (balResult.data as WalletBalancePayload).balance;
    } else if (!balResult.isSuccess) {
      _errorMessage = balResult.message;
      _status = LoadingStatus.error;
      update();
      return;
    }

    if (txResult.isSuccess && txResult.data is WalletTransactionsPayload) {
      final payload = txResult.data as WalletTransactionsPayload;
      _transactions
        ..clear()
        ..addAll(payload.items);
      _txMeta = payload.meta;
    }

    if (vaResult.isSuccess && vaResult.data is VirtualAccountsPayload) {
      _virtualAccounts = (vaResult.data as VirtualAccountsPayload).items;
    }

    _status = LoadingStatus.content;
    update();
  }

  /// Tick: balance only (lightest payload).
  @override
  Future<void> poll() async {
    final balResult = await walletService.getBalance();
    if (balResult.isSuccess && balResult.data is WalletBalancePayload) {
      _balance = (balResult.data as WalletBalancePayload).balance;
      if (_status != LoadingStatus.content) {
        _status = LoadingStatus.content;
      }
      update();
    }
    // Failure during poll silently keeps the previous balance.
  }

  /// Pull-to-refresh: balance + first transactions page + virtual accounts.
  Future<void> refreshAll() async {
    await initialLoad();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_txMeta.hasMore) return;
    _loadingMore = true;
    update();

    final result = await walletService.getTransactions(
      offset: _txMeta.nextOffset,
      limit: _txMeta.limit == 0 ? 20 : _txMeta.limit,
      type: _filterType,
    );
    if (result.isSuccess && result.data is WalletTransactionsPayload) {
      final payload = result.data as WalletTransactionsPayload;
      _transactions.addAll(payload.items);
      _txMeta = payload.meta;
    } else if (!result.isSuccess) {
      showCustomSnackBar(result.message);
    }

    _loadingMore = false;
    update();
  }

  void setFilterType(String? value) {
    if (_filterType == value) return;
    _filterType = value;
    _transactions.clear();
    _txMeta = const PageMeta(offset: 0, limit: 20, total: 0);
    update();
    // ignore: discarded_futures
    _reloadTransactionsHead();
  }

  Future<void> _reloadTransactionsHead() async {
    final result = await walletService.getTransactions(
      offset: 0,
      limit: 20,
      type: _filterType,
    );
    if (result.isSuccess && result.data is WalletTransactionsPayload) {
      final payload = result.data as WalletTransactionsPayload;
      _transactions
        ..clear()
        ..addAll(payload.items);
      _txMeta = payload.meta;
      update();
    }
  }

  /// Calls `POST /wallet/fund/initiate` and returns a fund session
  /// (provider URL + reference) on success, or null on failure (with a snack).
  Future<FundSessionModel?> initiateFund({
    required String provider,
    required double amount,
  }) async {
    if (_fundInFlight) return null;
    _fundInFlight = true;
    update();

    final result = await walletService.initiateFund(
      provider: provider,
      amount: amount,
    );

    _fundInFlight = false;
    update();

    if (result.isSuccess && result.data is FundInitiationPayload) {
      return (result.data as FundInitiationPayload).session;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  /// Verifies a completed payment via `GET /wallet/fund/verify` and triggers a
  /// balance refresh. Called after the WebView pops back.
  Future<bool> verifyAndRefresh({
    required String provider,
    required String reference,
  }) async {
    final result = await walletService.verifyFund(
      provider: provider,
      reference: reference,
    );
    if (result.isSuccess && result.data is FundVerificationPayload) {
      final payload = result.data as FundVerificationPayload;
      if (payload.balance != null) {
        _balance = payload.balance!;
        update();
      } else {
        // Fall back to a balance fetch.
        await poll();
      }
      await _reloadTransactionsHead();
      showCustomSnackBar(
        'Wallet funded successfully',
        isError: false,
      );
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }
}
