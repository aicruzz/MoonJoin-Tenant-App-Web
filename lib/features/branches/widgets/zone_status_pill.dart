import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/zone_check_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Pill that summarises the latest zone check.
/// - Loading: neutral pill with a spinner.
/// - Ok: green "We deliver here · <zone>".
/// - Outside coverage: red "Outside coverage".
/// - Error: amber "Couldn't check coverage".
class ZoneStatusPill extends StatelessWidget {
  final ZoneCheckModel? result;
  final bool checking;
  final String? errorMessage;

  const ZoneStatusPill({
    super.key,
    required this.result,
    required this.checking,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (checking)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: tone.fg),
            )
          else
            Icon(tone.icon, size: 16, color: tone.fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _label(),
              style: robotoMedium.copyWith(
                  color: tone.fg, fontSize: Dimensions.fontSizeSmall),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _label() {
    if (checking) return 'Checking coverage…';
    if (errorMessage != null) return errorMessage!;
    if (result == null) return 'Move the pin to check coverage';
    if (result!.ok) {
      final name = result!.zoneName ?? 'Zone ${result!.zoneId}';
      return 'We deliver here · $name';
    }
    return 'Outside coverage';
  }

  _Tone _toneFor() {
    if (checking) {
      return const _Tone(
        bg: Color(0xFFEDF0F5),
        fg: Color(0xFF3F4855),
        border: Color(0xFFD9DEE7),
        icon: Icons.public,
      );
    }
    if (errorMessage != null) {
      return const _Tone(
        bg: Color(0xFFFFF6E0),
        fg: Color(0xFFA66B00),
        border: Color(0xFFE8D38A),
        icon: Icons.warning_amber_outlined,
      );
    }
    if (result == null) {
      return const _Tone(
        bg: Color(0xFFEDF0F5),
        fg: Color(0xFF3F4855),
        border: Color(0xFFD9DEE7),
        icon: Icons.place_outlined,
      );
    }
    if (result!.ok) {
      return const _Tone(
        bg: Color(0xFFE6F8EE),
        fg: Color(0xFF137C36),
        border: Color(0xFFB6E7C7),
        icon: Icons.check_circle_outline,
      );
    }
    return const _Tone(
      bg: Color(0xFFFCEAEC),
      fg: Color(0xFFB31E2A),
      border: Color(0xFFE9B7BD),
      icon: Icons.block,
    );
  }
}

class _Tone {
  final Color bg;
  final Color fg;
  final Color border;
  final IconData icon;
  const _Tone(
      {required this.bg,
      required this.fg,
      required this.border,
      required this.icon});
}
