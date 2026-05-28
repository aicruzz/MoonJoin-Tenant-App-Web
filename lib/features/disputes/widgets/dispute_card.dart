import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/features/disputes/domain/models/dispute_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DisputeCard extends StatelessWidget {
  final DisputeModel dispute;
  final VoidCallback onTap;
  const DisputeCard({super.key, required this.dispute, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFCEAEC),
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: const Icon(Icons.report_problem_outlined,
                  color: Color(0xFFB31E2A)),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(_reasonLabel(dispute.reason),
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault),
                          overflow: TextOverflow.ellipsis),
                    ),
                    _StatusPill(status: dispute.status),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    'Order #${dispute.orderId} · opened ${_relative(dispute.createdAt)}',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ]),
        ),
      ),
    );
  }

  String _reasonLabel(String r) {
    switch (r) {
      case 'not_delivered':
        return 'Not delivered';
      case 'wrong_item':
        return 'Wrong item';
      case 'damaged':
        return 'Damaged';
      case 'late':
        return 'Late delivery';
      default:
        return r[0].toUpperCase() + r.substring(1);
    }
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

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tone.$1,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Text(_label(status),
          style: robotoMedium.copyWith(
              color: tone.$2,
              fontSize: Dimensions.fontSizeExtraSmall,
              letterSpacing: 0.3)),
    );
  }

  String _label(String s) {
    switch (s) {
      case 'open':
        return 'OPEN';
      case 'investigating':
        return 'INVESTIGATING';
      case 'resolved_refund':
        return 'REFUNDED';
      case 'resolved_no_refund':
        return 'NO REFUND';
      case 'closed':
        return 'CLOSED';
      default:
        return s.toUpperCase();
    }
  }

  (Color, Color) _toneFor(String s) {
    switch (s) {
      case 'open':
        return (const Color(0xFFFFF6E0), const Color(0xFFA66B00));
      case 'investigating':
        return (const Color(0xFFEAF1FB), const Color(0xFF2266CC));
      case 'resolved_refund':
        return (const Color(0xFFE6F8EE), const Color(0xFF137C36));
      case 'resolved_no_refund':
      case 'closed':
        return (const Color(0xFFEDF0F5), const Color(0xFF3F4855));
      default:
        return (const Color(0xFFEDF0F5), const Color(0xFF3F4855));
    }
  }
}
