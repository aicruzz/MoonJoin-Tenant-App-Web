import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      final merchant = controller.merchant;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Profile',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _row(context, 'Company',
                merchant?.companyName ?? '—'),
            _row(context, 'Email', merchant?.email ?? '—'),
            _row(context, 'Phone', merchant?.phone ?? '—'),
            _row(context, 'Status',
                (merchant?.status ?? 'unknown').toUpperCase()),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            SizedBox(
              width: 240,
              child: CustomButton(
                buttonText: 'Sign out',
                onPressed: () async {
                  await controller.logout();
                  Get.offAllNamed(RouteHelper.getSignInRoute());
                },
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: robotoMedium.copyWith(
                  color: Theme.of(context).hintColor)),
        ),
        Expanded(child: Text(value, style: robotoMedium)),
      ]),
    );
  }
}
