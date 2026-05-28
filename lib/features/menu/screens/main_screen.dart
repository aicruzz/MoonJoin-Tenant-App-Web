import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/controllers/theme_controller.dart';
import 'package:moonjoin_cloud/features/analytics/screens/analytics_screen.dart';
import 'package:moonjoin_cloud/features/api_products/screens/api_products_screen.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/branches/screens/branches_screen.dart';
import 'package:moonjoin_cloud/features/dashboard/screens/dashboard_screen.dart';
import 'package:moonjoin_cloud/features/deliveries/screens/deliveries_screen.dart';
import 'package:moonjoin_cloud/features/notifications/controllers/notifications_controller.dart';
import 'package:moonjoin_cloud/features/profile/screens/profile_screen.dart';
import 'package:moonjoin_cloud/features/wallet/screens/wallet_screen.dart';
import 'package:moonjoin_cloud/features/webhooks/screens/webhooks_screen.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/images.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class _NavItem {
  final String key;
  final String label;
  final IconData icon;
  final Widget page;
  const _NavItem(this.key, this.label, this.icon, this.page);
}

const List<_NavItem> _items = [
  _NavItem('dashboard', 'Dashboard', Icons.dashboard_outlined, DashboardScreen()),
  _NavItem('wallet', 'Wallet', Icons.account_balance_wallet_outlined, WalletScreen()),
  _NavItem('api-products', 'API Products', Icons.api_outlined, ApiProductsScreen()),
  _NavItem('webhooks', 'Webhooks', Icons.webhook_outlined, WebhooksScreen()),
  _NavItem('deliveries', 'Deliveries', Icons.local_shipping_outlined, DeliveriesScreen()),
  _NavItem('analytics', 'Analytics', Icons.insights_outlined, AnalyticsScreen()),
  _NavItem('branches', 'Branches', Icons.store_outlined, BranchesScreen()),
  _NavItem('profile', 'Profile', Icons.person_outline, ProfileScreen()),
];

class MainScreen extends StatefulWidget {
  final String? page;
  const MainScreen({super.key, this.page});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = _items.indexWhere((e) => e.key == widget.page);
    if (_index < 0) _index = 0;
  }

  void _select(int i) => setState(() => _index = i);

  Future<void> _logout() async {
    await Get.find<AuthController>().logout();
    Get.offAllNamed(RouteHelper.getSignInRoute());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTab = ResponsiveHelper.isTab(context);
    if (isDesktop || isTab) {
      return Scaffold(
        body: Row(children: [
          _SideRail(
            selected: _index,
            collapsed: isTab,
            onSelect: _select,
            onLogout: _logout,
          ),
          Expanded(
            child: Column(children: [
              _TopBar(title: _items[_index].label),
              Expanded(child: _items[_index].page),
            ]),
          ),
        ]),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_index].label),
        actions: [
          const _NotificationBell(),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _items[_index].page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index.clamp(0, 4),
        onDestinationSelected: _select,
        destinations: _items
            .take(5)
            .map((e) => NavigationDestination(
                  icon: Icon(e.icon),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  final int selected;
  final bool collapsed;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  const _SideRail({
    required this.selected,
    required this.collapsed,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final width = collapsed
        ? Dimensions.sideRailWidthCollapsed
        : Dimensions.sideRailWidthExpanded;
    return Container(
      width: width,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge),
          child: Row(children: [
            Image.asset(Images.logo, height: 32),
            if (!collapsed) ...[
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text('MoonJoin Cloud',
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).primaryColor)),
              ),
            ],
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i];
              final active = i == selected;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 2),
                child: Material(
                  color: active
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeDefault),
                      child: Row(children: [
                        Icon(item.icon,
                            color: active
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).hintColor),
                        if (!collapsed) ...[
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: Text(item.label,
                                overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(
                                    color: active
                                        ? Theme.of(context).primaryColor
                                        : null)),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
          tooltip: 'Sign out',
        ),
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context).dividerTheme.color ??
                  Theme.of(context).hintColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(children: [
        Text(title,
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge)),
        const Spacer(),
        GetBuilder<ThemeController>(builder: (theme) {
          return IconButton(
            tooltip: theme.darkTheme ? 'Light mode' : 'Dark mode',
            icon: Icon(
                theme.darkTheme ? Icons.light_mode : Icons.dark_mode_outlined),
            onPressed: theme.toggleTheme,
          );
        }),
        const _NotificationBell(),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
          child: Icon(Icons.person, color: Theme.of(context).primaryColor),
        ),
      ]),
    );
  }
}

/// Bell icon with an unread badge driven by `NotificationsController.unread`.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(builder: (controller) {
      final unread = controller.unread;
      return IconButton(
        tooltip: unread > 0 ? '$unread unread' : 'Notifications',
        onPressed: () => Get.toNamed(RouteHelper.notifications),
        icon: Stack(clipBehavior: Clip.none, children: [
          const Icon(Icons.notifications_none),
          if (unread > 0)
            Positioned(
              right: -4,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC2A36),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Theme.of(context).cardColor, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ]),
      );
    });
  }
}
