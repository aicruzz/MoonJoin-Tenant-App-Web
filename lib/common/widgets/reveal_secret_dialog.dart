import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Shows the freshly-minted `composed_credential` (`prefix:secret`) once.
/// After 30 s the secret blurs to remind the merchant that the server will
/// never disclose it again. `onAcknowledge` is fired when the merchant
/// confirms — the caller should hit `ApiKeysController.acknowledgeReveal`.
class RevealSecretDialog extends StatefulWidget {
  final String composedCredential;
  final String keyPrefix;
  final String lastFour;
  final Future<void> Function() onAcknowledge;

  const RevealSecretDialog({
    super.key,
    required this.composedCredential,
    required this.keyPrefix,
    required this.lastFour,
    required this.onAcknowledge,
  });

  /// Convenience entry point used by the screens.
  static Future<void> show({
    required String composedCredential,
    required String keyPrefix,
    required String lastFour,
    required Future<void> Function() onAcknowledge,
  }) {
    return Get.dialog<void>(
      RevealSecretDialog(
        composedCredential: composedCredential,
        keyPrefix: keyPrefix,
        lastFour: lastFour,
        onAcknowledge: onAcknowledge,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<RevealSecretDialog> createState() => _RevealSecretDialogState();
}

class _RevealSecretDialogState extends State<RevealSecretDialog> {
  static const _blurAfter = Duration(seconds: 30);
  Timer? _countdown;
  int _remaining = _blurAfter.inSeconds;
  bool _blurred = false;
  bool _acknowledging = false;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining -= 1;
        if (_remaining <= 0) {
          _blurred = true;
          _countdown?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(
        ClipboardData(text: widget.composedCredential));
    showCustomSnackBar('Copied to clipboard', isError: false);
  }

  Future<void> _confirm() async {
    if (_acknowledging) return;
    setState(() => _acknowledging = true);
    try {
      await widget.onAcknowledge();
    } catch (_) {
      // The controller surfaces failures via snackbar.
    }
    if (!mounted) return;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.vpn_key_outlined,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text('Your new API key',
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge)),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'This is the only time the full secret will be shown. Copy it now and store it somewhere safe. We never save the plaintext on the server.',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              _SecretBox(
                value: widget.composedCredential,
                blurred: _blurred,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(children: [
                Expanded(
                  child: Text(
                    _blurred
                        ? 'Secret hidden — copy already?'
                        : 'Auto-blurs in $_remaining s',
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
                TextButton.icon(
                  onPressed: _blurred ? null : _copy,
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('Copy'),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .primaryColor
                      .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use this header: Authorization: ApiProduct ${widget.keyPrefix}:<secret>',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomButton(
                buttonText: "I've saved my key",
                isLoading: _acknowledging,
                onPressed: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecretBox extends StatelessWidget {
  final String value;
  final bool blurred;
  const _SecretBox({required this.value, required this.blurred});

  @override
  Widget build(BuildContext context) {
    final display = blurred
        ? '•' * (value.length.clamp(8, 56))
        : value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.25)),
      ),
      child: SelectableText(
        display,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontFeatures: [FontFeature.tabularFigures()],
          fontSize: 13,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
