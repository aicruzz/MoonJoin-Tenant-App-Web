import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/disputes/domain/models/dispute_model.dart';
import 'package:moonjoin_cloud/features/disputes/domain/services/dispute_service_interface.dart';

class DisputesController extends GetxController implements GetxService {
  final DisputeServiceInterface disputeService;
  DisputesController({required this.disputeService});

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<DisputeModel> _items = [];
  List<DisputeModel> get items => List.unmodifiable(_items);

  PageMeta _meta = const PageMeta(offset: 0, limit: 20, total: 0);
  PageMeta get meta => _meta;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  bool _submitting = false;
  bool get submitting => _submitting;

  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  Future<void> initialLoad() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
    final result = await disputeService.list(
      offset: 0,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      status: _statusFilter,
    );
    if (result.isSuccess && result.data is DisputeListPayload) {
      final p = result.data as DisputeListPayload;
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
  Future<void> refresh() => initialLoad();

  Future<void> loadMore() async {
    if (_loadingMore || !_meta.hasMore) return;
    _loadingMore = true;
    update();
    final result = await disputeService.list(
      offset: _meta.nextOffset,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      status: _statusFilter,
    );
    if (result.isSuccess && result.data is DisputeListPayload) {
      final p = result.data as DisputeListPayload;
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

  Future<DisputeModel?> create({
    required int orderId,
    required String reason,
    String? description,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    update();
    final result = await disputeService.create(
      orderId: orderId,
      reason: reason,
      description: description,
    );
    _submitting = false;
    update();
    if (result.isSuccess && result.data is DisputePayload) {
      final dispute = (result.data as DisputePayload).dispute;
      _items.insert(0, dispute);
      _meta = PageMeta(
          offset: _meta.offset, limit: _meta.limit, total: _meta.total + 1);
      _status = LoadingStatus.content;
      update();
      showCustomSnackBar('Dispute opened', isError: false);
      return dispute;
    }
    showCustomSnackBar(result.message);
    return null;
  }
}
