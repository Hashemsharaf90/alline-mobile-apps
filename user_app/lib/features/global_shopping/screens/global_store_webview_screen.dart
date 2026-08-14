import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_product_preview_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/my_global_orders_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GlobalStoreWebViewScreen extends StatefulWidget {
  final String storeName;
  final String initialUrl;

  const GlobalStoreWebViewScreen({
    super.key,
    required this.storeName,
    required this.initialUrl,
  });

  @override
  State<GlobalStoreWebViewScreen> createState() => _GlobalStoreWebViewScreenState();
}

class _GlobalStoreWebViewScreenState extends State<GlobalStoreWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  String _currentUrl = '';

  bool get _isLoaded => _progress >= 100;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _currentUrl = url;
              _progress = 0;
            });
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() {
              _currentUrl = url;
              _progress = 100;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            final scheme = uri.scheme.toLowerCase();
            if (scheme == 'http' || scheme == 'https') {
              return NavigationDecision.navigate;
            }

            launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<String> _activeUrl() async {
    final url = await _controller.currentUrl();
    return url?.isNotEmpty == true ? url! : _currentUrl;
  }



  Future<void> _openInstantBuySheet(BuildContext context) async {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final url = await _activeUrl();
    if (!context.mounted) return;

    final globalCtrl = Provider.of<GlobalShoppingController>(context, listen: false);

    // Trigger instant preview extraction
    globalCtrl.previewProduct(url, context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Consumer<GlobalShoppingController>(
          builder: (ctx, ctrl, _) {
            if (ctrl.isPreviewLoading) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      isLtr ? 'Extracting product & calculating landed price...' : 'جاري قراءة المنتج وحساب تكلفة الشحن لليمن...',
                      textAlign: TextAlign.center,
                      style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                  ],
                ),
              );
            }

            final preview = ctrl.productPreview;
            if (preview == null) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 36),
                    const SizedBox(height: 10),
                    Text(
                      isLtr ? 'Please open a specific product page' : 'يرجى فتح صفحة منتج محددة داخل المتجر ثم الضغط على الزر',
                      textAlign: TextAlign.center,
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(isLtr ? 'Continue Browsing' : 'متابعة التصفح', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return _InstantBuyContent(
              preview: preview,
              url: url,
              storeName: widget.storeName,
              onSuccess: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen()),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    _controller.setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.storeName,
            style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: isLtr ? 'Refresh' : 'تحديث',
              onPressed: () => _controller.reload(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (action) async {
                final url = await _activeUrl();
                if (action == 'copy') {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) {
                    showCustomSnackBarWidget(
                      isLtr ? 'Link copied' : 'تم نسخ رابط السلعة',
                      context,
                      snackBarType: SnackBarType.success,
                    );
                  }
                } else if (action == 'share') {
                  await SharePlus.instance.share(ShareParams(text: url));
                } else if (action == 'browser') {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'copy', child: Text(isLtr ? 'Copy link' : 'نسخ الرابط')),
                PopupMenuItem(value: 'share', child: Text(isLtr ? 'Share link' : 'مشاركة الرابط')),
                PopupMenuItem(value: 'browser', child: Text(isLtr ? 'Open in browser' : 'فتح في المتصفح الخارجي')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (!_isLoaded)
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress / 100,
                minHeight: 2.5,
                color: Theme.of(context).primaryColor,
              ),
            Expanded(child: WebViewWidget(controller: _controller)),

            // Smart Floating 1-Click Purchase Bar
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: isLtr ? 'Back' : 'رجوع',
                      onPressed: () async {
                        if (await _controller.canGoBack()) {
                          await _controller.goBack();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      tooltip: isLtr ? 'Forward' : 'تقدم',
                      onPressed: () async {
                        if (await _controller.canGoForward()) {
                          await _controller.goForward();
                        }
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    ),
                    const SizedBox(width: 8),

                    // Primary Instant Purchase Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _openInstantBuySheet(context),
                          icon: const Icon(Icons.bolt, color: Colors.white, size: 22),
                          label: Text(
                            isLtr ? 'Buy via Alline ⚡' : 'اطلب عبر Alline ⚡',
                            style: textBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstantBuyContent extends StatefulWidget {
  final GlobalProductPreviewModel preview;
  final String url;
  final String storeName;
  final VoidCallback onSuccess;

  const _InstantBuyContent({
    required this.preview,
    required this.url,
    required this.storeName,
    required this.onSuccess,
  });

  @override
  State<_InstantBuyContent> createState() => _InstantBuyContentState();
}

class _InstantBuyContentState extends State<_InstantBuyContent> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    final globalCtrl = Provider.of<GlobalShoppingController>(context);

    final isAir = globalCtrl.selectedShippingType == 'air';
    final shippingCost = isAir ? (widget.preview.airShippingCost ?? 0.0) : (widget.preview.seaShippingCost ?? 0.0);
    final totalUsd = ((widget.preview.originalPrice ?? 0.0) + shippingCost + (widget.preview.customsFee ?? 0.0) + (widget.preview.serviceFee ?? 0.0)) * _quantity;
    final totalYer = totalUsd * 535.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        0,
        Dimensions.paddingSizeDefault,
        MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeDefault,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: isDark ? Theme.of(context).highlightColor : const Color(0xFFF9FAFB),
                    child: CustomImageWidget(
                      image: widget.preview.thumbnail ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.preview.title ?? widget.storeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textBold.copyWith(fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalYer.toStringAsFixed(0)} YER (≈ \$${totalUsd.toStringAsFixed(2)})',
                        style: textBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),

            // Shipping Selector
            Text(
              isLtr ? 'Shipping Method to Yemen:' : 'طريقة الشحن لليمن:',
              style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _shipChip(
                    title: isLtr ? 'Air Express ✈️ (7-12d)' : 'شحن جوي سريع ✈️ (7-12 يوم)',
                    isSelected: isAir,
                    onTap: () => globalCtrl.setShippingType('air'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _shipChip(
                    title: isLtr ? 'Sea Cargo 🚢 (25-35d)' : 'شحن بحري اقتصادي 🚢 (25-35 يوم)',
                    isSelected: !isAir,
                    onTap: () => globalCtrl.setShippingType('sea'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quantity Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isLtr ? 'Quantity:' : 'الكمية المطلوبة:', style: textMedium.copyWith(fontSize: 13)),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 14),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text('$_quantity', style: textBold.copyWith(fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 14),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Notes / Specs
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: isLtr ? 'Notes: (Color, Size, Specs)' : 'الملاحظات: (اللون، المقاس، المواصفات المطلوبة)',
                hintStyle: textRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor),
                filled: true,
                fillColor: isDark ? Theme.of(context).highlightColor : const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: globalCtrl.isSubmitLoading
                    ? null
                    : () async {
                        final auth = Provider.of<AuthController>(context, listen: false);
                        if (!auth.isLoggedIn()) {
                          Navigator.pop(context);
                          RouterHelper.getLoginRoute(action: RouteAction.push);
                          return;
                        }

                        final success = await globalCtrl.submitRequest(
                          productUrl: widget.url,
                          storeName: widget.storeName,
                          quantity: _quantity,
                          customerNotes: _notesController.text.trim(),
                          onSuccess: () {
                            showCustomSnackBarWidget(
                              isLtr ? 'Order placed successfully!' : 'تم إرسال طلب الشراء بنجاح! سيتم اعتماده وتوصيله لك.',
                              context,
                              snackBarType: SnackBarType.success,
                            );
                          },
                        );

                        if (success) {
                          widget.onSuccess();
                        }
                      },
                child: globalCtrl.isSubmitLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isLtr ? 'Confirm & Order Now 🛒' : 'تأكيد وإتمام الطلب 🛒',
                            style: textBold.copyWith(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shipChip({required String title, required bool isSelected, required VoidCallback onTap}) {
    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : (isDark ? Theme.of(context).highlightColor : const Color(0xFFF9FAFB)),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: textBold.copyWith(
            fontSize: 10,
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
