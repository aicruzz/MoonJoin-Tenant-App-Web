import 'package:moonjoin_cloud/common/controllers/polling_controller.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/services/dashboard_service_interface.dart';

/// Drives the dashboard summary tiles via the Phase A
/// `GET /api/v1/merchant/analytics/summary` endpoint.
///
/// Uses `update()` + `GetBuilder` (no Rx), matching the User App pattern.
/// Polls every 60 s for fresh tiles; pauses on app background.
class DashboardController extends PollingController {
  final DashboardServiceInterface dashboardService;
  DashboardController({required this.dashboardService});

  /// Range passed to the analytics summary endpoint. Defaults to `today` to
  /// keep the polled payload small. Mutable so the screen can offer a range
  /// switcher later without rebuilding the controller.
  String _range = 'today';
  String get range => _range;

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DashboardSummaryModel _summary = DashboardSummaryModel.empty();
  DashboardSummaryModel get summary => _summary;

  /// True while a poll is in-flight (separate from the initial-load status so
  /// the UI doesn't flash back to a spinner on every tick).
  bool _polling = false;
  bool get isPolling => _polling;

  @override
  Duration get pollInterval => const Duration(seconds: 60);

  void setRange(String value) {
    if (_range == value) return;
    _range = value;
    // Force a fresh load with the new range.
    _status = LoadingStatus.loading;
    update();
    // ignore: discarded_futures
    initialLoad();
  }

  @override
  Future<void> initialLoad() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();

    final result = await dashboardService.getSummary(_range);
    if (result.isSuccess && result.data is DashboardSummaryPayload) {
      _summary = (result.data as DashboardSummaryPayload).summary;
      _status = _summary.ordersTotal == 0 &&
              _summary.walletBalance == 0 &&
              _summary.webhookDeliveriesTotal == 0
          ? LoadingStatus.content // Content state still — empty handled in-screen.
          : LoadingStatus.content;
    } else {
      _errorMessage = result.message;
      _status = LoadingStatus.error;
    }
    update();
  }

  @override
  Future<void> poll() async {
    if (_polling) return;
    _polling = true;
    update();

    final result = await dashboardService.getSummary(_range);
    if (result.isSuccess && result.data is DashboardSummaryPayload) {
      _summary = (result.data as DashboardSummaryPayload).summary;
      if (_status != LoadingStatus.content) {
        _status = LoadingStatus.content;
      }
      _errorMessage = null;
    }
    // On poll failure: keep the previous content visible and silently swallow
    // the error. Initial-load errors still surface via LoadingState.

    _polling = false;
    update();
  }

  /// Manual pull-to-refresh entry point used by the screen.
  @override
  Future<void> refresh() => refreshNow();
}
