import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/custom_loader.dart';
import 'package:moonjoin_cloud/common/widgets/no_data_screen.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// View states every list/detail screen can be in.
enum LoadingStatus { idle, loading, content, empty, error }

/// Three-state shell used by every screen wired against a REST endpoint.
///
/// Usage:
/// ```dart
/// GetBuilder<MyController>(builder: (c) {
///   return LoadingState(
///     status: c.status,
///     errorMessage: c.errorMessage,
///     onRetry: c.load,
///     emptyText: 'No deliveries yet',
///     content: (ctx) => _MyList(items: c.items),
///   );
/// });
/// ```
class LoadingState extends StatelessWidget {
  final LoadingStatus status;
  final WidgetBuilder content;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String emptyText;
  final IconData emptyIcon;

  const LoadingState({
    super.key,
    required this.status,
    required this.content,
    this.errorMessage,
    this.onRetry,
    this.emptyText = 'Nothing here yet',
    this.emptyIcon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LoadingStatus.idle:
        return const SizedBox.shrink();
      case LoadingStatus.loading:
        return const CustomLoader();
      case LoadingStatus.empty:
        return NoDataScreen(text: emptyText, icon: emptyIcon);
      case LoadingStatus.error:
        return _ErrorView(message: errorMessage, onRetry: onRetry);
      case LoadingStatus.content:
        return content(context);
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  const _ErrorView({this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 56, color: Theme.of(context).disabledColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              message ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
