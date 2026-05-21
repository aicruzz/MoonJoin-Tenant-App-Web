import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/feature_placeholder.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: const FeaturePlaceholder(
        icon: Icons.notifications_none,
        title: 'Notifications',
        description:
            'In-app feed plus FCM (new dedicated Firebase project) for delivery + webhook + wallet alerts.',
        backendStatus: 'Phase 5 — FCM topic registration pending',
      ),
    );
  }
}
