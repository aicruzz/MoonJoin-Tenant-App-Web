import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Status pill for `pending | delivered | failed | exhausted`
/// (Phase A `ApiProductWebhookDelivery` constants).
class WebhookStatusPill extends StatelessWidget {
  final String status;
  const WebhookStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: tone.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(_label(status),
              style: robotoMedium.copyWith(
                  color: tone.text,
                  fontSize: Dimensions.fontSizeExtraSmall,
                  letterSpacing: 0.3)),
        ],
      ),
    );
  }

  String _label(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'delivered':
        return 'DELIVERED';
      case 'failed':
        return 'FAILED';
      case 'exhausted':
        return 'EXHAUSTED';
      default:
        return status.toUpperCase();
    }
  }

  _Tone _toneFor(String status) {
    switch (status) {
      case 'delivered':
        return const _Tone(
          bg: Color(0xFFE6F8EE),
          dot: Color(0xFF1BAE4E),
          text: Color(0xFF137C36),
        );
      case 'failed':
        return const _Tone(
          bg: Color(0xFFFCEAEC),
          dot: Color(0xFFCC2A36),
          text: Color(0xFFB31E2A),
        );
      case 'exhausted':
        return const _Tone(
          bg: Color(0xFFF7E7F4),
          dot: Color(0xFFAE52D4),
          text: Color(0xFF8B30B0),
        );
      case 'pending':
      default:
        return const _Tone(
          bg: Color(0xFFEDF0F5),
          dot: Color(0xFF666E7A),
          text: Color(0xFF3F4855),
        );
    }
  }
}

class _Tone {
  final Color bg;
  final Color dot;
  final Color text;
  const _Tone({required this.bg, required this.dot, required this.text});
}
