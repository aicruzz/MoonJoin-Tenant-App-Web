import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/features/wallet/controllers/wallet_controller.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/fund_session_model.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen WebView that completes the redirect-style fund flow.
///
/// Lifecycle:
/// 1. Open `authorizationUrl` from [FundSessionModel].
/// 2. Listen for navigation to the Phase A `callback_url` (or any URL with
///    `wallet/fund/verify`). Stop the WebView there so the provider's HTML
///    response doesn't actually render.
/// 3. Call `WalletController.verifyAndRefresh()` which hits
///    `GET /api/v1/merchant/wallet/fund/verify` and refreshes balance.
/// 4. Pop back to the wallet screen. Failure → snackbar from the controller.
class FundWalletWebViewScreen extends StatefulWidget {
  final FundSessionModel session;
  const FundWalletWebViewScreen({super.key, required this.session});

  @override
  State<FundWalletWebViewScreen> createState() =>
      _FundWalletWebViewScreenState();
}

class _FundWalletWebViewScreenState extends State<FundWalletWebViewScreen> {
  bool _completing = false;
  double _progress = 0;

  bool _isCallback(Uri url) {
    if (url.toString().startsWith(widget.session.callbackUrl)) return true;
    return url.path.contains('/wallet/fund/verify');
  }

  Future<void> _completeIfCallback(Uri? url) async {
    if (url == null || _completing) return;
    if (!_isCallback(url)) return;

    _completing = true;
    if (!mounted) return;
    setState(() {});

    final reference = url.queryParameters['reference'] ??
        url.queryParameters['trxref'] ??
        url.queryParameters['tx_ref'] ??
        widget.session.reference;

    final controller = Get.find<WalletController>();
    final ok = await controller.verifyAndRefresh(
      provider: widget.session.provider,
      reference: reference,
    );
    if (!mounted) return;
    Get.back<bool>(result: ok);
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveHelper.isWeb();
    return Scaffold(
      appBar: AppBar(
        title: Text('Fund via ${_providerLabel(widget.session.provider)}',
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: false),
        ),
        bottom: _progress > 0 && _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress, minHeight: 2),
              )
            : null,
      ),
      body: SafeArea(
        // Flutter web cannot host an InAppWebView; bounce the user to the
        // provider URL via url_launcher and let them return. The wallet
        // screen's PollingController re-fetches on resume so the balance
        // reconciles automatically.
        child: isWeb
            ? _WebFallback(session: widget.session)
            : InAppWebView(
                initialUrlRequest: URLRequest(
                    url: WebUri(widget.session.authorizationUrl)),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  javaScriptEnabled: true,
                  transparentBackground: true,
                ),
                shouldOverrideUrlLoading: (controller, action) async {
                  await _completeIfCallback(action.request.url);
                  return _completing
                      ? NavigationActionPolicy.CANCEL
                      : NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  await _completeIfCallback(url);
                },
                onProgressChanged: (controller, p) {
                  setState(() => _progress = p / 100);
                },
              ),
      ),
    );
  }
}

class _WebFallback extends StatelessWidget {
  final FundSessionModel session;
  const _WebFallback({required this.session});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_in_new,
                size: 56, color: Theme.of(context).primaryColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'Complete payment in the new tab',
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'After paying, return here. Your balance refreshes automatically within 30 seconds.',
              style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: Text('Open ${_providerLabel(session.provider)}'),
              onPressed: () async {
                final uri = Uri.parse(session.authorizationUrl);
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank');
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            TextButton(
              onPressed: () async {
                // Best-effort verify on close — the user may have already paid.
                final controller = Get.find<WalletController>();
                final ok = await controller.verifyAndRefresh(
                  provider: session.provider,
                  reference: session.reference,
                );
                Get.back<bool>(result: ok);
              },
              child: const Text('I have paid — verify'),
            ),
          ],
        ),
      ),
    );
  }
}

String _providerLabel(String provider) {
  switch (provider) {
    case 'paystack':
      return 'Paystack';
    case 'flutterwave':
      return 'Flutterwave';
    case 'monnify':
      return 'Monnify';
    case '9psb':
      return '9PSB';
    default:
      return provider;
  }
}
