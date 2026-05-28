import 'package:moonjoin_cloud/common/controllers/polling_controller.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/models/delivery_model.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/services/delivery_service_interface.dart';

/// Drives the delivery detail screen. Polls every 5 s while the order is in
/// a non-terminal status; stops automatically when the order reaches
/// `delivered / canceled / refunded / failed`.
class DeliveryDetailController extends PollingController {
  final DeliveryServiceInterface deliveryService;
  DeliveryDetailController({required this.deliveryService});

  int? _orderId;
  int? get orderId => _orderId;

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DeliveryModel? _delivery;
  DeliveryModel? get delivery => _delivery;

  bool _reassigning = false;
  bool get reassigning => _reassigning;

  @override
  Duration get pollInterval => const Duration(seconds: 5);

  @override
  bool shouldStopPolling() {
    final d = _delivery;
    if (d == null) return false;
    return d.isTerminal;
  }

  /// Called by the screen on first build with the route's id parameter.
  void bindOrder(int id) {
    if (_orderId == id && _status != LoadingStatus.idle) return;
    _orderId = id;
    _delivery = null;
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
  }

  @override
  Future<void> initialLoad() async {
    final id = _orderId;
    if (id == null) return;
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
    final result = await deliveryService.show(id);
    if (result.isSuccess && result.data is DeliveryPayload) {
      _delivery = (result.data as DeliveryPayload).delivery;
      _status = LoadingStatus.content;
    } else {
      _errorMessage = result.message;
      _status = LoadingStatus.error;
    }
    update();
  }

  @override
  Future<void> poll() async {
    final id = _orderId;
    if (id == null) return;
    final result = await deliveryService.show(id);
    if (result.isSuccess && result.data is DeliveryPayload) {
      _delivery = (result.data as DeliveryPayload).delivery;
      if (_status != LoadingStatus.content) {
        _status = LoadingStatus.content;
      }
      update();
    }
  }

  Future<bool> requestReassignment(String reason, String? notes) async {
    final id = _orderId;
    if (id == null || _reassigning) return false;
    _reassigning = true;
    update();
    final result =
        await deliveryService.requestReassignment(id, reason, notes);
    _reassigning = false;
    update();
    if (result.isSuccess) {
      showCustomSnackBar(
          'Reassignment requested — admin will action shortly.',
          isError: false);
      // Refresh detail immediately to surface `needs_manual_dispatch` flag.
      await poll();
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }
}
