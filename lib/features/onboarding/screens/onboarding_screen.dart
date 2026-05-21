import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/controllers/splash_controller.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/images.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class _OnboardSlide {
  final String image;
  final String title;
  final String subtitle;
  _OnboardSlide(this.image, this.title, this.subtitle);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static final _slides = <_OnboardSlide>[
    _OnboardSlide(
      Images.onboardOne,
      'Dispatch via API',
      'Generate keys for Food, Grocery, Pharmacy, Fashion, Parcel — or Fuel, Gas, Drink, Electronics, Market.',
    ),
    _OnboardSlide(
      Images.onboardTwo,
      'One wallet, four gateways',
      'Fund instantly with Paystack, Flutterwave, Monnify, or your 9PSB virtual account.',
    ),
    _OnboardSlide(
      Images.onboardThree,
      'Premium analytics',
      'Track deliveries, success rates, webhook health, and spending in real time.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) {
                final s = _slides[i];
                return Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(s.image, height: 240, fit: BoxFit.contain),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      Text(s.title,
                          textAlign: TextAlign.center,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeOverLarge)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(s.subtitle,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeLarge)),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _index == i ? 24 : 8,
                decoration: BoxDecoration(
                  color: _index == i
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Row(children: [
              Expanded(
                child: CustomButton(
                  buttonText:
                      _index == _slides.length - 1 ? 'Get started' : 'Next',
                  onPressed: () async {
                    if (_index == _slides.length - 1) {
                      await Get.find<SplashController>().markIntroSeen();
                      Get.offAllNamed(RouteHelper.getSignInRoute());
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
