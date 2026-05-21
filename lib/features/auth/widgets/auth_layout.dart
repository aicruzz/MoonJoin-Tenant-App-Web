import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/images.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Two-pane auth layout: brand panel on the left (desktop only),
/// form on the right. Collapses to single column on mobile/tablet.
class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      body: SafeArea(
        child: Row(children: [
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding:
                    const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(Images.logo, height: 56),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Logistics infrastructure\nfor modern businesses.',
                          style: robotoBold.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Text(
                          'Generate API keys, monitor dispatches, fund your wallet, and analyze performance — all from one premium dashboard.',
                          style: robotoRegular.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                      ],
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? Dimensions.paddingSizeExtraOverLarge
                    : Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeExtraLarge,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDesktop)
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeLarge),
                        child: Image.asset(Images.logo, height: 40),
                      ),
                    Text(title,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(subtitle,
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
