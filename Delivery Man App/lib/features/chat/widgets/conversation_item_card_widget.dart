import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/features/chat/domain/models/chat_model.dart';
import 'package:sixvalley_delivery_boy/features/chat/screens/chat_screen.dart';
import 'package:sixvalley_delivery_boy/helper/shop_helper.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_image_widget.dart';

class ConversationItemCardWidget extends StatelessWidget {
  final Chat? chat;
  const ConversationItemCardWidget({super.key, this.chat});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final shop = chat?.sellerInfo?.shops?.isNotEmpty == true
        ? chat!.sellerInfo!.shops!.first
        : null;
    final inHouse = Get.find<SplashController>().configModel?.inHouseShop;
    final seller = controller.userTypeIndex == 0,
        customer = controller.userTypeIndex == 1;
    final image = seller
        ? shop?.imageFullUrl?.path
        : customer
            ? chat?.customer?.imageFullUrl?.path
            : inHouse?.imageFullUrl?.path;
    final name = seller
        ? shop?.name ?? 'store'.tr
        : customer
            ? '${chat?.customer?.fName ?? ''} ${chat?.customer?.lName ?? ''}'
            : inHouse?.name ?? 'admin'.tr;
    final userId = seller
        ? chat?.sellerId
        : customer
            ? chat?.userId
            : inHouse?.sellerId;
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipOval(
                child: CustomImageWidget(
                    image: image ?? '', width: 48, height: 48)),
            title: Text(name,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  chat?.message ??
                      ((chat?.attachment?.isNotEmpty ?? false)
                          ? 'sent_attachment'.tr
                          : ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              if (chat?.createdAt != null)
                Text(chat!.createdAt!,
                    style: Theme.of(context).textTheme.bodySmall),
              if (chat?.seenByDeliveryMan == false)
                Text('alline_unread'.tr,
                    style: Theme.of(context).textTheme.labelSmall),
            ]),
            onTap: userId == null
                ? null
                : () => Get.to(() => ChatScreen(
                    userId: userId,
                    name: name,
                    image: image ?? '',
                    isShopTemporaryClosed:
                        seller && (shop?.temporaryClose ?? false),
                    isShopOnVacation: seller && shop != null
                        ? ShopHelper.isVacationActive(context,
                            startDate:
                                DateTime.tryParse(shop.vacationStartDate ?? ''),
                            endDate:
                                DateTime.tryParse(shop.vacationEndDate ?? ''),
                            vacationDurationType: shop.vacationDurationType,
                            vacationStatus: shop.vacationStatus,
                            isInHouseSeller: chat?.sentByAdmin ?? false)
                        : false))));
  }
}
