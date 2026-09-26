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

  final List<Map<String, String>> _stores = [
    {
      'name': 'أمازون',
      'en': 'Amazon',
      'mark': 'a',
      'url': 'https://www.amazon.com/'
    },
    {
      'name': 'علي إكسبريس',
      'en': 'AliExpress',
      'mark': '⌁',
      'url': 'https://www.aliexpress.com/'
    },
    {
      'name': 'علي بابا',
      'en': 'Alibaba',
      'mark': 'a',
      'url': 'https://www.alibaba.com/'
    },
    {
      'name': 'شي إن',
      'en': 'SHEIN',
      'mark': 'S',
      'url': 'https://www.shein.com/'
    },
    {
      'name': 'ترينديول',
      'en': 'Trendyol',
      'mark': 'T',
      'url': 'https://www.trendyol.com/'
    },
    {
      'name': 'آي هيرب',
      'en': 'iHerb',
      'mark': 'i',
      'url': 'https://www.iherb.com/'
    },
  ];

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
          isLtr ? 'Global Shopping Service' : 'الشراء من المواقع العالمية',
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
                                  ? 'Shop from Any Store Worldwide!'
                                  : 'اطلب من أي متجر في العالم ونوصله لبيتك!',
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
                            ? 'Paste the link of any product from Amazon, SHEIN, AliExpress, Alibaba, etc. and get instant pricing with air/sea shipping to Yemen.'
                            : 'انسخ رابط أي منتج تريده من أمازون، شي إن، علي إكسبريس، أو علي بابا، واحصل على تسعير فوري وتوصيل سريع حتى بابك في اليمن.',
                        style: textRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Supported Stores Chips
                Text(
                  isLtr
                      ? 'Supported Global Stores:'
                      : 'المتاجر العالمية المدعومة:',
                  style:
                      textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 86,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _stores.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final store = _stores[index];
                      return Material(
                        color: isDark
                            ? Theme.of(context).highlightColor
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFFE1E8F2)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GlobalStoreWebViewScreen(
                                storeName: store['en']!,
                                initialUrl: store['url']!,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            width: 94,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F8FE),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(store['mark']!,
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF071B49))),
                                ),
                                const SizedBox(height: 5),
                                Text(isLtr ? store['en']! : store['name']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textBold.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeExtraSmall)),
                                Text(isLtr ? 'Browse' : 'تسوق عالمي',
                                    style: textRegular.copyWith(
                                        fontSize: 9,
                                        color: const Color(0xFF6D85AF))),
                              ],
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
                  isLtr
                      ? 'Paste Product Link:'
                      : 'ألصق رابط المنتج المراد شراؤه:',
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
                                            ? 'Inspect & Price Instantly ⚡'
                                            : 'فحص وتسعير المنتج فوراً ⚡',
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
                            ? 'How to order from global sites?'
                            : 'كيف تطلب من المواقع العالمية؟',
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
                              ? 'Paste here and get instant price estimate'
                              : 'الصق الرابط هنا لمعاينة السعر والشحن لليمن'),
                      _stepRow(
                          '3',
                          isLtr
                              ? 'Confirm order & receive at your door!'
                              : 'أكد الطلب واستلم شحنتك عند باب بيتك!'),
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
