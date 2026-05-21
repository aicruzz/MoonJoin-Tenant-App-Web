import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Color(0xFFE84D4F)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('404 — Page not found',
                style:
                    robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            SizedBox(
              width: 220,
              child: CustomButton(
                buttonText: 'Go home',
                onPressed: () =>
                    Get.offAllNamed(RouteHelper.getInitialRoute()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
