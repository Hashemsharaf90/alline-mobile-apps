import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_single_child_list_widget.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_delivery_boy/features/wallet/domain/models/transaction_type_model.dart';
import 'package:sixvalley_delivery_boy/helper/color_helper.dart';
import 'package:sixvalley_delivery_boy/theme/controllers/theme_controller.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/utill/styles.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/sliver_deligate_widget.dart';
import 'package:sixvalley_delivery_boy/features/wallet/widgets/deposited_list_view_widget.dart';
import 'package:sixvalley_delivery_boy/features/wallet/widgets/transaction_list_view_widget.dart';
import 'package:sixvalley_delivery_boy/features/wallet/widgets/transaction_search_filter_widget.dart';
import 'package:sixvalley_delivery_boy/features/wallet/widgets/transaction_type_card_widget.dart';
import 'package:sixvalley_delivery_boy/features/wallet/widgets/wallet_withdraw_send_card_widget.dart';
import 'package:sixvalley_delivery_boy/features/withdraw/widgets/withdraw_list_view_widget.dart';

class WalletScreen extends StatefulWidget {
  final bool fromNotification;
  final int? selectedIndex;
  final bool fromProfile;

  const WalletScreen({super.key, required this.fromNotification, this.selectedIndex, this.fromProfile = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final walletController = Get.find<WalletController>();
    final profileController = Get.find<ProfileController>();

    walletController.selectDate(isUpdate: false);
    walletController.getOrderWiseDeliveryCharge('', '', 1, '', isUpdate: false);

    if (widget.fromNotification) {
      profileController.getProfile();
      walletController.selectedItemForFilter(widget.selectedIndex ?? 0, fromTop: true, fromNotification: true);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false,
      onPopInvokedWithResult: (canPop, _) async {
        if (canPop) return;

        if (widget.fromNotification) {
          Get.off(() => const DashboardScreen(pageIndex: 0));
        }

        if (widget.fromProfile) {
          Get.off(() => const DashboardScreen(pageIndex: 4));
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBarWidget(title: 'my_wallet'.tr,
          isBack: true,
          onTap: () {
            if (widget.fromNotification) {
              Get.off(() => const DashboardScreen(pageIndex: 0));
            } else {
              Get.back();
            }
          },
        ),
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegateWidget(
                  containerHeight: 200,
                  child: const WalletSendWithdrawCardWidget(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.rememberMeSizeDefault),
                  child: GetBuilder<WalletController>(
                    builder: (walletController) {
                      return GetBuilder<ProfileController>(
                        builder: (profileController) {

                          final profile = profileController.profileModel;

                          final List<TransactionTypeModel> transactionTypes = [
                            TransactionTypeModel(Images.delivery, 'delivery_charge_earned', profile?.totalEarn ?? 0, 0),
                            TransactionTypeModel(Images.withdrawn, 'withdrawn', profile?.totalWithdraw ?? 0, 1),
                            TransactionTypeModel(Images.pendingWithdraw, 'pending_withdrawn', profile?.pendingWithdraw ?? 0, 2),
                            TransactionTypeModel(Images.deposit, 'already_deposited', profile?.totalDeposit ?? 0, 3),
                          ];

                          String title = transactionTypes[walletController.selectedItem].title;

                          return Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              CustomSingleChildListWidget(
                                scrollDirection: Axis.horizontal,
                                itemCount: transactionTypes.length,
                                itemBuilder: (int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      walletController.selectedItemForFilter(index, fromTop: true);
                                    },
                                    child: Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                      child: TransactionCardWidget(
                                        transactionTypeModel: transactionTypes[index],
                                        selectedIndex: walletController.selectedItem,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const DeliverySearchFilterWidget(fromOrderHistory: false),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
                                child: Text(title.tr,
                                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge,
                                    color: (Get.find<ThemeController>().darkTheme ? ColorHelper.blendColors(Colors.white, Theme.of(context).primaryColor, 0.9) : ColorHelper.darken(Theme.of(context).primaryColor, 0.1))),
                                ),
                              ),

                              walletController.selectedItem == 0
                                  ? const TransactionListViewWidget()
                                  : walletController.selectedItem == 3
                                  ? const DepositedListViewWidget()
                                  : const WithdrawListViewWidget(),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}