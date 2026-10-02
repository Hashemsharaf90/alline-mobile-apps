import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_delivery_boy/features/chat/widgets/conversation_item_card_widget.dart';
import 'package:sixvalley_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_empty_state.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';

class ConversationScreen extends StatefulWidget {
  final bool fromNotification;
  final int? chatIndex;
  const ConversationScreen(
      {super.key, required this.fromNotification, this.chatIndex});
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _scroll = ScrollController(), _search = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    Get.find<ChatController>()
        .setUserTypeIndex(widget.chatIndex ?? 0, isUpdate: false);
    _scroll.addListener(_paginate);
  }

  void _paginate() {
    final controller = Get.find<ChatController>();
    final model = controller.conversationModel;
    if (_scroll.position.extentAfter < 200 &&
        !controller.isLoading &&
        !controller.isSearching &&
        (model?.chat?.length ?? 0) < (model?.totalSize ?? 0)) {
      controller
          .getConversationList((int.tryParse(model?.offset ?? '1') ?? 1) + 1);
    }
  }

  void _changed(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        Get.find<ChatController>().searchConversationList(value.trim());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !widget.fromNotification,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.fromNotification) {
          Get.offAll(() => const DashboardScreen(pageIndex: 0));
        }
      },
      child: Scaffold(
          appBar: CustomAppBarWidget(
              title: 'alline_nav_chats'.tr, isBack: widget.fromNotification),
          body: GetBuilder<ChatController>(builder: (controller) {
            final items = controller.conversationModel?.chat ?? [];
            return Column(children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Wrap(spacing: 8, children: [
                      for (final entry in <int, String>{
                        0: 'seller',
                        1: 'customer',
                        3: 'admin'
                      }.entries)
                        ChoiceChip(
                            label: Text(entry.value.tr),
                            selected: controller.userTypeIndex == entry.key,
                            onSelected: (_) {
                              _debounce?.cancel();
                              _search.clear();
                              controller.setUserTypeIndex(entry.key);
                            })
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _search,
                        onChanged: _changed,
                        decoration: InputDecoration(
                            hintText: 'search_by_name'.tr,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                                tooltip: 'clear'.tr,
                                onPressed: () {
                                  _search.clear();
                                  controller.searchConversationList('');
                                },
                                icon: const Icon(Icons.close))))
                  ])),
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: () => _search.text.trim().isEmpty
                          ? controller.getConversationList(1)
                          : controller
                              .searchConversationList(_search.text.trim()),
                      child: ListView(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (controller.isLoading && items.isEmpty)
                              const AllineSkeleton(),
                            if (controller.conversationLoadFailed)
                              AllineErrorState(
                                  onRetry: () => _search.text.trim().isEmpty
                                      ? controller.getConversationList(1)
                                      : controller.searchConversationList(
                                          _search.text.trim())),
                            if (!controller.isLoading &&
                                !controller.conversationLoadFailed &&
                                items.isEmpty)
                              AllineEmptyState(
                                  title: 'alline_no_chats'.tr,
                                  subtitle: '',
                                  icon: Icons.chat_bubble_outline_rounded),
                            for (final chat in items)
                              ConversationItemCardWidget(chat: chat),
                          ]))),
            ]);
          })));
}
