import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/controllers/theme_controller.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
      ),
      body: GetBuilder<ThemeController>(builder: (theme) {
        return ListView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          children: [
            SwitchListTile(
              title: Text('Dark mode', style: robotoMedium),
              value: theme.darkTheme,
              onChanged: (_) => theme.toggleTheme(),
            ),
          ],
        );
      }),
    );
  }
}
