import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/features/notifications/domain/models/notification_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class NotificationRow extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  const NotificationRow({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _tone(notification.type).withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Icon(_icon(notification.type),
                      color: _tone(notification.type)),
                ),
                if (unread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).cardColor, width: 1.5),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title,
                        style: (unread ? robotoBold : robotoMedium).copyWith(
                            fontSize: Dimensions.fontSizeDefault),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2),
                    if (notification.body != null &&
                        notification.body!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(notification.body!,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 4),
                    Text(_relative(notification.createdAt),
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeExtraSmall)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(String type) {
    if (type.startsWith('delivery') || type.startsWith('order')) {
      return Icons.local_shipping_outlined;
    }
    if (type.startsWith('webhook')) {
      return Icons.webhook_outlined;
    }
    if (type.startsWith('wallet') || type.startsWith('escrow')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (type.startsWith('dispute')) {
      return Icons.report_problem_outlined;
    }
    if (type.startsWith('api_product') || type.startsWith('api_key')) {
      return Icons.api_outlined;
    }
    return Icons.notifications_none_outlined;
  }

  Color _tone(String type) {
    if (type.startsWith('webhook')) return const Color(0xFF4F8BF6);
    if (type.startsWith('wallet') || type.startsWith('escrow')) {
      return const Color(0xFF1BAE4E);
    }
    if (type.startsWith('dispute')) return const Color(0xFFCC2A36);
    if (type.startsWith('api_')) return const Color(0xFFAE52D4);
    return const Color(0xFF666E7A);
  }

  String _relative(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(d.toLocal());
  }
}
