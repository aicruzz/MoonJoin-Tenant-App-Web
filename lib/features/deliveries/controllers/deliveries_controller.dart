import 'package:moonjoin_cloud/common/controllers/polling_controller.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/models/delivery_model.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/services/delivery_service_interface.dart';

/// Drives the cross-product deliveries list with **conditional long polling**:
/// - Polls every 8 s only when at least one visible row is in a non-terminal
///   status (`pending / accepted / picked_up` etc.).
/// - Re-fetches the **first page** of the current filter set on each tick —
///   that's the smallest payload that still captures status drift.
/// - Stops polling automatically once all visible rows are terminal.
class DeliveriesController extends PollingController {
  final DeliveryServiceInterface deliveryService;
  DeliveriesController({required this.deliveryService});

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<DeliveryModel> _items = [];
  List<DeliveryModel> get items => List.unmodifiable(_items);

  PageMeta _meta = const PageMeta(offset: 0, limit: 20, total: 0);
  PageMeta get meta => _meta;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  int? _apiProductFilter;
  int? get apiProductFilter => _apiProductFilter;

  @override
  Duration get pollInterval => const Duration(seconds: 8);

  @override
  bool shouldStopPolling() {
    if (_items.isEmpty) return false; // keep polling — items may arrive
    return _items.every((e) => e.isTerminal);
  }

  @override
  Future<void> initialLoad() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
    final result = await deliveryService.list(
      offset: 0,
      limit: 20,
      status: _statusFilter,
      apiProductId: _apiProductFilter,
    );
    if (result.isSuccess && result.data is DeliveryListPayload) {
      final p = result.data as DeliveryListPayload;
      _items
        ..clear()
        ..addAll(p.items);
      _meta = p.meta;
      _status =
          _items.isEmpty ? LoadingStatus.empty : LoadingStatus.content;
    } else {
      _errorMessage = result.message;
      _status = LoadingStatus.error;
    }
    update();
  }

  @override
  Future<void> poll() async {
    final result = await deliveryService.list(
      offset: 0,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      status: _statusFilter,
      apiProductId: _apiProductFilter,
    );
    if (result.isSuccess && result.data is DeliveryListPayload) {
      final payload = result.data as DeliveryListPayload;
      // Merge: replace items where id matches, prepend new, keep beyond-head.
      final fresh = payload.items;
      final freshById = {for (final d in fresh) d.id: d};
      final merged = <DeliveryModel>[];
      // 1) Items from the fresh head, in order.
      merged.addAll(fresh);
      // 2) Items beyond the fresh window that we already had loaded (paginated
      //    deeper) — keep them only if they weren't replaced by the head.
      for (final old in _items) {
        if (!freshById.containsKey(old.id) &&
            merged.length < (_meta.limit == 0 ? 20 : _meta.limit) +
                (_items.length - fresh.length)) {
          merged.add(old);
        }
      }
      _items
        ..clear()
        ..addAll(merged);
      // Keep total from the fresh payload; offset/limit unchanged.
      _meta = PageMeta(
        offset: _meta.offset,
        limit: _meta.limit == 0 ? 20 : _meta.limit,
        total: payload.meta.total,
      );
      if (_status != LoadingStatus.content && _items.isNotEmpty) {
        _status = LoadingStatus.content;
      }
      update();
    }
    // Failures silently keep the previous payload — initial-load errors still
    // surface via LoadingState.
  }

  @override
  Future<void> refresh() => initialLoad();

  Future<void> loadMore() async {
    if (_loadingMore || !_meta.hasMore) return;
    _loadingMore = true;
    update();
    final result = await deliveryService.list(
      offset: _meta.nextOffset,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      status: _statusFilter,
      apiProductId: _apiProductFilter,
    );
    if (result.isSuccess && result.data is DeliveryListPayload) {
      final p = result.data as DeliveryListPayload;
      _items.addAll(p.items);
      _meta = p.meta;
    } else if (!result.isSuccess) {
      showCustomSnackBar(result.message);
    }
    _loadingMore = false;
    update();
  }

  void setStatusFilter(String? value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    update();
    // ignore: discarded_futures
    initialLoad();
  }

  void setApiProductFilter(int? value) {
    if (_apiProductFilter == value) return;
    _apiProductFilter = value;
    update();
    // ignore: discarded_futures
    initialLoad();
  }
}
