import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/network_info.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/home/screens/home_page_screen.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/analytics/screens/seller_analytics_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/seller_account_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    String languageCode =
        Provider.of<LocalizationController>(context, listen: false)
                    .locale
                    .countryCode ==
                'US'
            ? 'en'
            : Provider.of<LocalizationController>(context, listen: false)
                .locale
                .countryCode!
                .toLowerCase();
    Provider.of<DigitalProductController>(context, listen: false)
        .getDigitalAuthor();
    Provider.of<DigitalProductController>(context, listen: false)
        .getPublishingHouse();
    Provider.of<CategoryController>(context, listen: false)
        .getCategoryList(context, null, languageCode);
    Provider.of<CartController>(context, listen: false).getCartData();

    Provider.of<TransactionController>(context, listen: false)
        .getTransactionList(context, 'all', '', '');
    Provider.of<WalletController>(context, listen: false).getPaymentInfoList();

    if (Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.isAiFeatureActive ==
        1) {
      Provider.of<AiController>(context, listen: false).generateLimitCheck();
    }

    _screens = [
      HomePageScreen(onNavigate: setPage),
      const OrderScreen(isBacButtonExist: false),
      const ProductListMenuScreen(
          fromNotification: false, isBackButtonExist: false),
      const SellerAnalyticsScreen(isBackButtonExist: false),
      const SellerAccountScreen(),
    ];

    NetworkInfo.checkConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (_pageIndex != 0) {
          setPage(0);
        } else {
          _onWillPop(context);
        }
        if (didPop) return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).hintColor,
          selectedFontSize: Dimensions.fontSizeSmall,
          unselectedFontSize: Dimensions.fontSizeSmall,
          selectedLabelStyle: robotoBold,
          showUnselectedLabels: true,
          currentIndex: _pageIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            _barItem(Images.home,
                getTranslated('nav_home', context) ?? 'الرئيسية', 0),
            _barItem(Images.order,
                getTranslated('nav_orders', context) ?? 'الطلبات', 1),
            _barItem(Images.productIcon,
                getTranslated('nav_products', context) ?? 'المنتجات', 2),
            _barItem(Images.pieChart,
                getTranslated('nav_analytics', context) ?? 'الإحصائيات', 3),
            _barItem(Images.profile,
                getTranslated('nav_account', context) ?? 'حسابي', 4),
          ],
          onTap: (int index) {
            setPage(index);
          },
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _barItem(String icon, String? label, int index) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding:
            const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
        child: Container(
          width: 48,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: index == _pageIndex
                ? Theme.of(context).primaryColor.withValues(alpha: .11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(icon,
              width: 22,
              height: 22,
              color: index == _pageIndex
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor),
        ),
      ),
      label: label,
    );
  }

  void setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    showAnimatedDialogWidget(
        context,
        ConfirmationDialogWidget(
          icon: Images.logOut,
          title: getTranslated('exit_app', context),
          description: getTranslated('do_you_want_to_exit_the_app', context),
          onYesPressed: () {
            SystemNavigator.pop();
          },
        ),
        isFlip: true);

    return true;
  }
}
