import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';

final robotoRegular = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoMedium = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoBlack = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

BoxDecoration get tenantCardDecoration => BoxDecoration(
      borderRadius:
          const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
      color: Theme.of(Get.context!).cardColor,
      boxShadow: [
        BoxShadow(
          color: Theme.of(Get.context!).shadowColor,
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
