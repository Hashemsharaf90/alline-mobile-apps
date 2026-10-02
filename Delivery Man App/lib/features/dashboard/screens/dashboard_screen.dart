import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/controllers/dashboard_controller.dart';
import 'package:sixvalley_delivery_boy/features/order/controllers/order_controller.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/animated_custom_dialog_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/confirmation_dialog_widget.dart';


class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final int? chatIndex;
  const DashboardScreen({super.key, required this.pageIndex, this.chatIndex});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  final PageStorageBucket bucket = PageStorageBucket();
  final Map<int, Widget> _pages = {};

  OrderController orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    Get.find<DashboardController>().selectHomePage(first: false);
    if((orderController.allOrderHistory == null || orderController.allOrderHistory!.isEmpty) &&
      (orderController.pauseOrderHistory == null || orderController.pauseOrderHistory!.isEmpty) &&
      (orderController.deliveredOrderHistory == null || orderController.deliveredOrderHistory!.isEmpty)) {
      Get.find<OrderController>().getAllOrderHistory('', '', '', '', '',0);
    }

    if(widget.pageIndex == 1) Get.find<DashboardController>().selectOrderHistoryScreen();

    if(widget.pageIndex == 2) {
      Get.find<DashboardController>().selectConversationScreen(isUpdate: false, chatIndex: widget.chatIndex);
    }

    if(widget.pageIndex == 3) {
      Get.find<DashboardController>().selectWalletScreen(isUpdate: false);
    }

    if(widget.pageIndex == 4) {
      Get.find<DashboardController>().selectProfileScreen(isUpdate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if( Get.find<DashboardController>().currentTab != 0) {
          Get.find<DashboardController>().selectHomePage();
        } else {
          _onWillPop(context);
        }
        return;
      },

      child: GetBuilder<DashboardController>(builder: (menuController) {
        _pages.putIfAbsent(menuController.currentTab, () => menuController.currentScreen!);
        return Scaffold(
          body: PageStorage(bucket: bucket, child: IndexedStack(index: menuController.currentTab,
            children: List.generate(5, (index) => _pages[index] ?? const SizedBox.shrink()))),
          bottomNavigationBar: NavigationBar(
            selectedIndex: menuController.currentTab,
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: 'alline_nav_home'.tr),
              NavigationDestination(icon: const Icon(Icons.local_shipping_outlined), selectedIcon: const Icon(Icons.local_shipping_rounded), label: 'alline_nav_orders'.tr),
              NavigationDestination(icon: const Icon(Icons.chat_bubble_outline_rounded), selectedIcon: const Icon(Icons.chat_bubble_rounded), label: 'alline_nav_chats'.tr),
              NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined), selectedIcon: const Icon(Icons.account_balance_wallet_rounded), label: 'alline_nav_wallet'.tr),
              NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: 'alline_nav_account'.tr),
            ],
            onDestinationSelected: (index) {
              switch(index) {
                case 0: menuController.selectHomePage();
                case 1: menuController.selectOrderHistoryScreen();
                case 2: menuController.selectConversationScreen();
                case 3: menuController.selectWalletScreen();
                case 4: menuController.selectProfileScreen();
              }
            },
          ),

        );
      }),
    );
  }


}
Future<bool> _onWillPop(BuildContext context) async {
  showAnimatedDialogWidget(context,  ConfirmationDialogWidget(icon: Images.logOut,
    title: 'exit_app'.tr,
    description: 'do_you_want_to_exit_the_app'.tr, onYesPressed: (){
    SystemNavigator.pop();
  },),isFlip: true);
  return true;
}


