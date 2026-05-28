import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/api_products/domain/models/api_product_model.dart';
import 'package:moonjoin_cloud/features/api_products/domain/services/api_product_service_interface.dart';

/// Manages the merchant's API product list + detail cache.
///
/// Uses `update()` + `GetBuilder` (no Rx). API products change infrequently,
/// so this controller does NOT poll — refreshes on pull-to-refresh, after
/// create/update/submit, or when the user re-opens the screen.
class ApiProductsController extends GetxController implements GetxService {
  final ApiProductServiceInterface apiProductService;
  ApiProductsController({required this.apiProductService});

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<ApiProductModel> _items = [];
  List<ApiProductModel> get items => List.unmodifiable(_items);

  PageMeta _meta = const PageMeta(offset: 0, limit: 20, total: 0);
  PageMeta get meta => _meta;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  String? _filterStatus;
  String? get filterStatus => _filterStatus;

  /// Local detail cache so the detail screen can render synchronously after
  /// a list tap, then refresh in the background.
  final Map<int, ApiProductModel> _cache = {};

  bool _submitting = false;
  bool get submitting => _submitting;

  ApiProductModel? cached(int id) => _cache[id];

  Future<void> initialLoad() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
    final result = await apiProductService.list(
        offset: 0, limit: _meta.limit == 0 ? 20 : _meta.limit, status: _filterStatus);
    if (result.isSuccess && result.data is ApiProductsPayload) {
      final p = result.data as ApiProductsPayload;
      _items
        ..clear()
        ..addAll(p.items);
      for (final item in p.items) {
        _cache[item.id] = item;
      }
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
    final result = await apiProductService.list(
      offset: _meta.nextOffset,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      status: _filterStatus,
    );
    if (result.isSuccess && result.data is ApiProductsPayload) {
      final p = result.data as ApiProductsPayload;
      _items.addAll(p.items);
      for (final item in p.items) {
        _cache[item.id] = item;
      }
      _meta = p.meta;
    } else if (!result.isSuccess) {
      showCustomSnackBar(result.message);
    }
    _loadingMore = false;
    update();
  }

  void setStatusFilter(String? value) {
    if (_filterStatus == value) return;
    _filterStatus = value;
    update();
    // ignore: discarded_futures
    initialLoad();
  }

  Future<ApiProductModel?> loadDetail(int id) async {
    final result = await apiProductService.show(id);
    if (result.isSuccess && result.data is ApiProductPayload) {
      final product = (result.data as ApiProductPayload).product;
      _cache[product.id] = product;
      final idx = _items.indexWhere((e) => e.id == product.id);
      if (idx >= 0) _items[idx] = product;
      update();
      return product;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  Future<ApiProductModel?> create({
    required String name,
    required String productType,
    List<String> categories = const [],
    List<String> modules = const [],
    String? webhookUrl,
    int? rateLimitPerMinute,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    update();
    final result = await apiProductService.create(
      name: name,
      productType: productType,
      supportedCategories: categories,
      modules: modules,
      webhookUrl: webhookUrl,
      rateLimitPerMinute: rateLimitPerMinute,
    );
    _submitting = false;
    update();

    if (result.isSuccess && result.data is ApiProductPayload) {
      final product = (result.data as ApiProductPayload).product;
      _items.insert(0, product);
      _cache[product.id] = product;
      _meta = PageMeta(
          offset: _meta.offset, limit: _meta.limit, total: _meta.total + 1);
      _status = LoadingStatus.content;
      update();
      showCustomSnackBar('API product created', isError: false);
      return product;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  Future<ApiProductModel?> updateProduct(
    int id, {
    String? name,
    String? productType,
    List<String>? categories,
    List<String>? modules,
    String? webhookUrl,
    int? rateLimitPerMinute,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    update();
    final result = await apiProductService.update(
      id,
      name: name,
      productType: productType,
      supportedCategories: categories,
      modules: modules,
      webhookUrl: webhookUrl,
      rateLimitPerMinute: rateLimitPerMinute,
    );
    _submitting = false;
    update();

    if (result.isSuccess && result.data is ApiProductPayload) {
      final product = (result.data as ApiProductPayload).product;
      final idx = _items.indexWhere((e) => e.id == product.id);
      if (idx >= 0) _items[idx] = product;
      _cache[product.id] = product;
      update();
      showCustomSnackBar('API product updated', isError: false);
      return product;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  Future<bool> submitForApproval(int id) async {
    if (_submitting) return false;
    _submitting = true;
    update();
    final result = await apiProductService.submit(id);
    _submitting = false;
    update();
    if (result.isSuccess && result.data is ApiProductPayload) {
      final product = (result.data as ApiProductPayload).product;
      final idx = _items.indexWhere((e) => e.id == product.id);
      if (idx >= 0) _items[idx] = product;
      _cache[product.id] = product;
      update();
      showCustomSnackBar(
          'Submitted for review — you\'ll get a notification once approved.',
          isError: false);
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }
}
