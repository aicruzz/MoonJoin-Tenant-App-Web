import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoInternetScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Color(0xFF9F9F9F)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('No internet connection',
                style:
                    robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('Check your network and try again',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            if (onRetry != null)
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
