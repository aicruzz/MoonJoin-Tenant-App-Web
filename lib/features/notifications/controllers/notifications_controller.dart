import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/notifications/domain/models/notification_model.dart';
import 'package:moonjoin_cloud/features/notifications/domain/services/notification_service_interface.dart';

/// Lists merchant notifications and tracks the unread count for the TopBar
/// badge. Manual refresh + pull-to-refresh + scroll-to-load-more — no polling.
/// Push messages (when Firebase is wired) call `refresh()` to surface fresh
/// rows immediately.
class NotificationsController extends GetxController implements GetxService {
  final NotificationServiceInterface notificationService;
  NotificationsController({required this.notificationService});

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<NotificationModel> _items = [];
  List<NotificationModel> get items => List.unmodifiable(_items);

  PageMeta _meta = const PageMeta(offset: 0, limit: 20, total: 0);
  PageMeta get meta => _meta;

  int _unread = 0;
  int get unread => _unread;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  bool _unreadOnly = false;
  bool get unreadOnly => _unreadOnly;

  Future<void> initialLoad() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
    final result = await notificationService.list(
      offset: 0,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      unreadOnly: _unreadOnly,
    );
    if (result.isSuccess && result.data is NotificationListPayload) {
      final p = result.data as NotificationListPayload;
      _items
        ..clear()
        ..addAll(p.items);
      _meta = p.meta;
      _unread = p.unread;
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
    final result = await notificationService.list(
      offset: _meta.nextOffset,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      unreadOnly: _unreadOnly,
    );
    if (result.isSuccess && result.data is NotificationListPayload) {
      final p = result.data as NotificationListPayload;
      _items.addAll(p.items);
      _meta = p.meta;
      _unread = p.unread;
    } else if (!result.isSuccess) {
      showCustomSnackBar(result.message);
    }
    _loadingMore = false;
    update();
  }

  void setUnreadOnly(bool value) {
    if (_unreadOnly == value) return;
    _unreadOnly = value;
    update();
    // ignore: discarded_futures
    initialLoad();
  }

  Future<void> markRead(NotificationModel notification) async {
    if (notification.isRead) return;
    final result = await notificationService.markRead(notification.id);
    if (result.isSuccess) {
      final idx = _items.indexWhere((e) => e.id == notification.id);
      if (idx >= 0) {
        final updated = NotificationModel(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          actionUrl: notification.actionUrl,
          payload: notification.payload,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: notification.createdAt,
        );
        _items[idx] = updated;
      }
      _unread = (_unread - 1).clamp(0, 1 << 30);
      update();
    } else {
      showCustomSnackBar(result.message);
    }
  }

  Future<void> markAllRead() async {
    if (_unread == 0) return;
    final result = await notificationService.markAllRead();
    if (result.isSuccess) {
      _items
        ..clear()
        ..addAll(_items.map((e) => NotificationModel(
              id: e.id,
              type: e.type,
              title: e.title,
              body: e.body,
              actionUrl: e.actionUrl,
              payload: e.payload,
              isRead: true,
              readAt: e.readAt ?? DateTime.now(),
              createdAt: e.createdAt,
            )));
      _unread = 0;
      update();
      showCustomSnackBar('All notifications marked as read', isError: false);
    } else {
      showCustomSnackBar(result.message);
    }
  }

  /// Called by PushService when a foreground message arrives — pulls in the
  /// new row without forcing a full reload from scratch.
  void onPushReceived() {
    // ignore: discarded_futures
    initialLoad();
  }
}
