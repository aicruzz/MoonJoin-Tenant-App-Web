import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Generic yes/no confirmation modal used by revoke / destructive actions.
///
/// Returns `true` if confirmed, `false` if cancelled, `null` if dismissed.
Future<bool?> showConfirmationDialog({
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) {
  return Get.dialog<bool>(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(
                  destructive
                      ? Icons.warning_amber_outlined
                      : Icons.help_outline,
                  color: destructive
                      ? const Color(0xFFE84D4F)
                      : Get.theme.primaryColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(title,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge)),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(message,
                  style: robotoRegular.copyWith(
                      color: Get.theme.hintColor,
                      fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(cancelLabel),
                  ),
                  const SizedBox(width: 8),
                  destructive
                      ? FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE84D4F)),
                          onPressed: () => Get.back(result: true),
                          child: Text(confirmLabel),
                        )
                      : FilledButton(
                          onPressed: () => Get.back(result: true),
                          child: Text(confirmLabel),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
