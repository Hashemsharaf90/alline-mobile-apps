import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/my_global_orders_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_product_preview_card.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class GlobalShoppingScreen extends StatefulWidget {
  const GlobalShoppingScreen({super.key});

  @override
  State<GlobalShoppingScreen> createState() => _GlobalShoppingScreenState();
}

class _GlobalShoppingScreenState extends State<GlobalShoppingScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<GlobalShoppingController>(context, listen: false)
            .fetchSupportedStores();
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;

    return Scaffold(
      backgroundColor:
          isDark ? Theme.of(context).cardColor : const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isLtr ? 'Global Shopping' : 'التسوق العالمي',
          style: textBold.copyWith(
              color: Colors.white, fontSize: Dimensions.fontSizeLarge),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: isLtr ? 'My Requests' : 'طلباتي السابقة',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<GlobalShoppingController>(
        builder: (context, globalCtrl, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        const Color(0xFF1E3C72),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.public,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isLtr
                                  ? 'Shop global stores with Alline'
                                  : 'تسوق من المتاجر العالمية عبر Alline',
                              style: textBold.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeLarge),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLtr
                            ? 'Choose a supported store, paste a product link, and send it to Alline for manual pricing.'
                            : 'اختر متجراً مدعوماً والصق رابط المنتج لإرساله إلى Alline للمراجعة والتسعير.',
                        style: textRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(
                  isLtr
                      ? 'Choose a store'
                      : 'اختر متجراً',
                  style:
                      textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: 8),
                if (globalCtrl.isStoresLoading &&
                    globalCtrl.supportedStores.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (globalCtrl.hasStoresError)
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      title: Text(isLtr
                          ? 'Could not load stores'
                          : 'تعذر تحميل المتاجر'),
                      trailing: IconButton(
                        tooltip: isLtr ? 'Retry' : 'إعادة المحاولة',
                        onPressed: globalCtrl.fetchSupportedStores,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 128,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: globalCtrl.supportedStores.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final store = globalCtrl.supportedStores[index];
                        return Material(
                          color: isDark
                              ? Theme.of(context).highlightColor
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE1E8F2)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: store.requestSupported
                                ? () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GlobalStoreWebViewScreen(
                                          storeName: store.name,
                                          initialUrl: store.url,
                                        ),
                                      ),
                                    )
                                : null,
                            child: SizedBox(
                              width: 142,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.public_rounded,
                                      color: store.isComingSoon
                                          ? const Color(0xFF6D85AF)
                                          : Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      isLtr ? store.name : store.nameAr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: const Color(0xFF071B49),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      isLtr
                                          ? (store.requestSupported
                                              ? 'Manual pricing'
                                              : 'Coming soon')
                                          : store.statusLabelAr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textRegular.copyWith(
                                        fontSize: 10,
                                        color: store.requestSupported
                                            ? Theme.of(context).primaryColor
                                            : const Color(0xFF6D85AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Smart URL Input Box
                Text(
                  isLtr ? 'Product link' : 'رابط المنتج',
                  style:
                      textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _urlController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              'https://www.amazon.com/dp/... or https://shein.com/...',
                          hintStyle: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.content_paste),
                            tooltip: isLtr
                                ? 'Paste from Clipboard'
                                : 'لصق من الحافظة',
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData('text/plain');
                              if (data != null && data.text != null) {
                                _urlController.text = data.text!;
                              }
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall)),
                            ),
                            onPressed: globalCtrl.isPreviewLoading
                                ? null
                                : () {
                                    globalCtrl.previewProduct(
                                        _urlController.text, context);
                                  },
                            child: globalCtrl.isPreviewLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.bolt,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        isLtr
                                            ? 'Preview product details'
                                            : 'معاينة بيانات المنتج',
                                        style: textBold.copyWith(
                                            color: Colors.white,
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Live Preview Card
                if (globalCtrl.productPreview != null) ...[
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  GlobalProductPreviewCard(
                    preview: globalCtrl.productPreview!,
                    onSubmit: () {
                      _urlController.clear();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const MyGlobalOrdersScreen()),
                      );
                    },
                  ),
                ],

                if (globalCtrl.previewErrorMessage != null &&
                    _urlController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: globalCtrl.isSubmitLoading
                          ? null
                          : () async {
                              await globalCtrl.submitRequest(
                                productUrl: _urlController.text.trim(),
                                onSuccess: () {
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MyGlobalOrdersScreen(),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                      icon: globalCtrl.isSubmitLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.support_agent_outlined),
                      label: Text(isLtr
                          ? 'Send link for manual review'
                          : 'إرسال الرابط للمراجعة اليدوية'),
                    ),
                  ),
                ],

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // How it works steps
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Theme.of(context).highlightColor
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLtr
                            ? 'How global orders work'
                            : 'كيف تتم الطلبات العالمية؟',
                        style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault),
                      ),
                      const SizedBox(height: 10),
                      _stepRow(
                          '1',
                          isLtr
                              ? 'Copy link from Amazon, SHEIN, etc.'
                              : 'انسخ رابط السلعة من المتجر العالمي'),
                      _stepRow(
                          '2',
                          isLtr
                              ? 'If available, Alline will show the product name and source price.'
                              : 'إذا كانت بيانات المنتج متاحة، ستظهر معاينة للاسم والسعر الأصلي.'),
                      _stepRow(
                          '3',
                          isLtr
                              ? 'Send a pricing request. The final price and fees are confirmed before adding the product to your Alline cart.'
                              : 'أرسل طلب التسعير. نؤكد السعر والرسوم قبل إضافة المنتج إلى سلة Alline.'),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stepRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(num,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall))),
        ],
      ),
    );
  }
}
