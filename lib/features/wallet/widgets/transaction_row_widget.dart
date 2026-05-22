import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_transaction_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class TransactionRowWidget extends StatelessWidget {
  final WalletTransactionModel transaction;
  final String currencyCode;

  const TransactionRowWidget({
    super.key,
    required this.transaction,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final ccy = NumberFormat.simpleCurrency(
      name: currencyCode.isEmpty ? 'NGN' : currencyCode,
      decimalDigits: 2,
    );
    final isCredit = t.isCredit;
    final color = isCredit ? const Color(0xFF1ED7AA) : const Color(0xFFE84D4F);
    final icon = _iconFor(t.type, isCredit);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_titleFor(t),
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(_subtitleFor(t),
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '−'} ${ccy.format(t.amount)}',
              style: robotoBold.copyWith(
                  color: color, fontSize: Dimensions.fontSizeDefault),
            ),
            const SizedBox(height: 2),
            Text(_formatDate(t.createdAt),
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeExtraSmall)),
          ],
        ),
      ]),
    );
  }

  IconData _iconFor(String type, bool credit) {
    switch (type) {
      case 'funding':
        return Icons.add_circle_outline;
      case 'hold':
        return Icons.lock_outline;
      case 'charge':
        return Icons.remove_circle_outline;
      case 'release':
        return Icons.delivery_dining_outlined;
      case 'refund':
        return Icons.undo;
      case 'reversal':
        return Icons.swap_horiz;
      default:
        return credit ? Icons.arrow_downward : Icons.arrow_upward;
    }
  }

  String _titleFor(WalletTransactionModel t) {
    switch (t.type) {
      case 'funding':
        final gw = t.gateway ?? '';
        return gw.isEmpty ? 'Wallet funded' : 'Funded via ${_gateway(gw)}';
      case 'hold':
        return 'Held for order #${t.orderId ?? '—'}';
      case 'charge':
        return 'Charged for order #${t.orderId ?? '—'}';
      case 'release':
        return 'Released to rider';
      case 'refund':
        return 'Refunded for order #${t.orderId ?? '—'}';
      case 'reversal':
        return 'Reversed transaction';
      default:
        return t.type;
    }
  }

  String _subtitleFor(WalletTransactionModel t) {
    if (t.reference != null && t.reference!.isNotEmpty) return t.reference!;
    if (t.gatewayReference != null && t.gatewayReference!.isNotEmpty) {
      return t.gatewayReference!;
    }
    return t.direction.toUpperCase();
  }

  String _gateway(String key) {
    switch (key) {
      case 'paystack':
        return 'Paystack';
      case 'flutterwave':
        return 'Flutterwave';
      case 'monnify':
        return 'Monnify';
      case '9psb':
        return '9PSB';
      default:
        return key;
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal();
    final now = DateTime.now();
    if (now.difference(local).inDays == 0) {
      return DateFormat('HH:mm').format(local);
    }
    return DateFormat('d MMM, HH:mm').format(local);
  }
}
