import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/branch_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/branch_service_interface.dart';

class BranchesController extends GetxController implements GetxService {
  final BranchServiceInterface branchService;
  BranchesController({required this.branchService});

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<BranchModel> _items = [];
  List<BranchModel> get items => List.unmodifiable(_items);

  PageMeta _meta = const PageMeta(offset: 0, limit: 20, total: 0);
  PageMeta get meta => _meta;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  bool _submitting = false;
  bool get submitting => _submitting;

  Future<void> initialLoad() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
    final result =
        await branchService.list(offset: 0, limit: _meta.limit == 0 ? 20 : _meta.limit);
    if (result.isSuccess && result.data is BranchListPayload) {
      final p = result.data as BranchListPayload;
      _items
        ..clear()
        ..addAll(p.items);
      _meta = p.meta;
      _status = _items.isEmpty ? LoadingStatus.empty : LoadingStatus.content;
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
    final result = await branchService.list(
      offset: _meta.nextOffset,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
    );
    if (result.isSuccess && result.data is BranchListPayload) {
      final p = result.data as BranchListPayload;
      _items.addAll(p.items);
      _meta = p.meta;
    } else if (!result.isSuccess) {
      showCustomSnackBar(result.message);
    }
    _loadingMore = false;
    update();
  }

  BranchModel? findById(int id) {
    for (final b in _items) {
      if (b.id == id) return b;
    }
    return null;
  }

  Future<BranchModel?> create({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
    String? email,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    update();
    final result = await branchService.create(
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
    );
    _submitting = false;
    update();
    if (result.isSuccess && result.data is BranchPayload) {
      final branch = (result.data as BranchPayload).branch;
      _items.insert(0, branch);
      _meta = PageMeta(
          offset: _meta.offset, limit: _meta.limit, total: _meta.total + 1);
      _status = LoadingStatus.content;
      update();
      showCustomSnackBar('Branch created', isError: false);
      return branch;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  Future<BranchModel?> updateBranch(
    int id, {
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    update();
    final result = await branchService.update(
      id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
    );
    _submitting = false;
    update();
    if (result.isSuccess && result.data is BranchPayload) {
      final branch = (result.data as BranchPayload).branch;
      final idx = _items.indexWhere((e) => e.id == branch.id);
      if (idx >= 0) _items[idx] = branch;
      update();
      showCustomSnackBar('Branch updated', isError: false);
      return branch;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  Future<bool> disable(int id) async {
    if (_submitting) return false;
    _submitting = true;
    update();
    final result = await branchService.disable(id);
    _submitting = false;
    update();
    if (result.isSuccess) {
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        // Refresh to pick up the server-side is_active flip.
        // ignore: discarded_futures
        refresh();
      }
      showCustomSnackBar('Branch disabled', isError: false);
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }
}
