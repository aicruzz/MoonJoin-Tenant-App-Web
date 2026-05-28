import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/notifications/controllers/notifications_controller.dart';
import 'package:moonjoin_cloud/features/notifications/widgets/notification_row.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ScrollController _scroll = ScrollController()..addListener(_onScroll);
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kicked) return;
      _kicked = true;
      final c = Get.find<NotificationsController>();
      if (c.status == LoadingStatus.idle) {
        // ignore: discarded_futures
        c.initialLoad();
      }
    });
  }

  void _onScroll() {
    final c = Get.find<NotificationsController>();
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 320 &&
        !c.loadingMore &&
        c.meta.hasMore) {
      // ignore: discarded_futures
      c.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notifications',
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), onPressed: Get.back),
          actions: [
            if (controller.unread > 0)
              IconButton(
                tooltip: 'Mark all as read',
                onPressed: controller.markAllRead,
                icon: const Icon(Icons.done_all),
              ),
          ],
        ),
        body: LoadingState(
          status: controller.status,
          errorMessage: controller.errorMessage,
          onRetry: controller.initialLoad,
          emptyText: controller.unreadOnly
              ? "You're all caught up — no unread notifications."
              : "No notifications yet. We'll let you know when there's news.",
          emptyIcon: Icons.notifications_none_outlined,
          content: (_) => RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              children: [
                Wrap(spacing: 6, children: [
                  _FilterChip(
                    label: 'All',
                    selected: !controller.unreadOnly,
                    onTap: () => controller.setUnreadOnly(false),
                  ),
                  _FilterChip(
                    label: controller.unread > 0
                        ? 'Unread (${controller.unread})'
                        : 'Unread',
                    selected: controller.unreadOnly,
                    onTap: () => controller.setUnreadOnly(true),
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                for (final n in controller.items)
                  NotificationRow(
                    notification: n,
                    onTap: () => controller.markRead(n),
                  ),
                if (controller.loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                        child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                if (!controller.meta.hasMore && controller.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('End of list',
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall)),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text(label),
      labelStyle: robotoMedium.copyWith(
          color: selected ? Colors.white : null,
          fontSize: Dimensions.fontSizeSmall),
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      showCheckmark: false,
    );
  }
}
