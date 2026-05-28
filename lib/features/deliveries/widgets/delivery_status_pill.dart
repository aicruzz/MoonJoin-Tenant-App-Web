import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DeliveryStatusPill extends StatelessWidget {
  final String status;
  const DeliveryStatusPill({super.key, required this.status});

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
          Text(status.toUpperCase(),
              style: robotoMedium.copyWith(
                  color: tone.text,
                  fontSize: Dimensions.fontSizeExtraSmall,
                  letterSpacing: 0.3)),
        ],
      ),
    );
  }

  ({Color bg, Color dot, Color text}) _toneFor(String status) {
    switch (status) {
      case 'pending':
        return (
          bg: const Color(0xFFFFF6E0),
          dot: const Color(0xFFE6803F),
          text: const Color(0xFFA66B00),
        );
      case 'accepted':
      case 'confirmed':
        return (
          bg: const Color(0xFFEAF1FB),
          dot: const Color(0xFF4F8BF6),
          text: const Color(0xFF2266CC),
        );
      case 'picked_up':
      case 'processing':
      case 'handover':
        return (
          bg: const Color(0xFFEDE7F8),
          dot: const Color(0xFF6E5BD2),
          text: const Color(0xFF503AB6),
        );
      case 'delivered':
        return (
          bg: const Color(0xFFE6F8EE),
          dot: const Color(0xFF1BAE4E),
          text: const Color(0xFF137C36),
        );
      case 'canceled':
      case 'cancelled':
      case 'failed':
        return (
          bg: const Color(0xFFFCEAEC),
          dot: const Color(0xFFCC2A36),
          text: const Color(0xFFB31E2A),
        );
      case 'refunded':
        return (
          bg: const Color(0xFFF0F0F0),
          dot: const Color(0xFF666E7A),
          text: const Color(0xFF3F4855),
        );
      default:
        return (
          bg: const Color(0xFFEDF0F5),
          dot: const Color(0xFF666E7A),
          text: const Color(0xFF3F4855),
        );
    }
  }
}
