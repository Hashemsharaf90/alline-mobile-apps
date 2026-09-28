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
  State<GlobalStoreWebViewScreen> createState() =>
      _GlobalStoreWebViewScreenState();
}

class _GlobalStoreWebViewScreenState extends State<GlobalStoreWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  String _currentUrl = '';
  String? _mainFrameLoadError;

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
              _mainFrameLoadError = null;
            });
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() {
              _currentUrl = url;
              _progress = 100;
            });
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame == false) return;
            setState(() {
              _mainFrameLoadError = error.description;
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

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.tryParse(await _activeUrl());
    if (uri == null || !['http', 'https'].contains(uri.scheme)) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      final isLtr =
          Provider.of<LocalizationController>(context, listen: false).isLtr;
      showCustomSnackBarWidget(
        isLtr ? 'Could not open the store in your browser.' : 'تعذر فتح المتجر في المتصفح الخارجي.',
        context,
        snackBarType: SnackBarType.warning,
      );
    }
  }

  Future<void> _openProductRequestSheet(BuildContext context) async {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final url = await _activeUrl();
    if (!context.mounted) return;

    final globalCtrl =
        Provider.of<GlobalShoppingController>(context, listen: false);

    // Ask the backend for a best-effort product metadata preview.
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
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      isLtr
                          ? 'Checking whether product details are available...'
                          : 'جارٍ التحقق من إمكانية قراءة بيانات المنتج...',
                      textAlign: TextAlign.center,
                      style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
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
                    const Icon(Icons.info_outline,
                        color: Color(0xFF6D85AF), size: 36),
                    const SizedBox(height: 10),
                    Text(
                      ctrl.previewErrorMessage ??
                          (isLtr
                              ? 'Could not read product details from this page.'
                              : 'تعذر الحصول على بيانات المنتج من هذه الصفحة.'),
                      textAlign: TextAlign.center,
                      style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => globalCtrl.previewProduct(url, context),
                      icon: const Icon(Icons.refresh),
                      label: Text(isLtr ? 'Try again' : 'حاول مرة أخرى'),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: ctrl.isSubmitLoading
                          ? null
                          : () async {
                              await globalCtrl.submitRequest(
                                productUrl: url,
                                storeName: widget.storeName,
                                onSuccess: () {
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MyGlobalOrdersScreen(),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                      icon: ctrl.isSubmitLoading
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
                    const SizedBox(height: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(isLtr ? 'Continue Browsing' : 'متابعة التصفح',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return _GlobalProductRequestContent(
              preview: preview,
              url: url,
              storeName: widget.storeName,
              onSuccess: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyGlobalOrdersScreen()),
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
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
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
            icon: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.storeName,
            style: textBold.copyWith(
                color: Colors.white, fontSize: Dimensions.fontSizeLarge),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: isLtr ? 'Refresh' : 'تحديث',
              onPressed: () => _controller.reload(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
            IconButton(
              tooltip: isLtr ? 'Open in browser' : 'فتح في المتصفح',
              onPressed: _openInExternalBrowser,
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
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
                  await _openInExternalBrowser();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 'copy',
                    child: Text(isLtr ? 'Copy link' : 'نسخ الرابط')),
                PopupMenuItem(
                    value: 'share',
                    child: Text(isLtr ? 'Share link' : 'مشاركة الرابط')),
                PopupMenuItem(
                    value: 'browser',
                    child: Text(
                        isLtr ? 'Open in browser' : 'فتح في المتصفح الخارجي')),
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
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: WebViewWidget(controller: _controller)),
                  if (_mainFrameLoadError != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.language_rounded,
                                    size: 44,
                                    color: Theme.of(context).primaryColor),
                                const SizedBox(height: 12),
                                Text(
                                  isLtr
                                      ? 'This store could not be displayed inside Alline.'
                                      : 'تعذر عرض المتجر داخل Alline.',
                                  textAlign: TextAlign.center,
                                  style: textBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isLtr
                                      ? 'Some stores restrict in-app browsing. Open the same page in your browser, then return and paste its product link.'
                                      : 'بعض المتاجر تمنع التصفح داخل التطبيقات. افتح الصفحة في المتصفح، ثم عد إلى Alline والصق رابط المنتج.',
                                  textAlign: TextAlign.center,
                                  style: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).hintColor,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _openInExternalBrowser,
                                    icon: const Icon(Icons.open_in_browser),
                                    label: Text(isLtr
                                        ? 'Open in browser'
                                        : 'فتح في المتصفح'),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _controller.reload(),
                                  icon: const Icon(Icons.refresh),
                                  label: Text(isLtr
                                      ? 'Try again in Alline'
                                      : 'إعادة المحاولة داخل Alline'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Persistent action for requesting manual review of a product link.
            SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

                    // Product information and final quote depend on store support.
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
                          onPressed: () => _openProductRequestSheet(context),
                          icon: const Icon(Icons.bolt,
                              color: Colors.white, size: 22),
                          label: Text(
                            isLtr ? 'Select via Alline' : 'اختيار عبر Alline',
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

class _GlobalProductRequestContent extends StatefulWidget {
  final GlobalProductPreviewModel preview;
  final String url;
  final String storeName;
  final VoidCallback onSuccess;

  const _GlobalProductRequestContent({
    required this.preview,
    required this.url,
    required this.storeName,
    required this.onSuccess,
  });

  @override
  State<_GlobalProductRequestContent> createState() =>
      _GlobalProductRequestContentState();
}

class _GlobalProductRequestContentState
    extends State<_GlobalProductRequestContent> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final isDark =
        Provider.of<ThemeController>(context, listen: false).darkTheme;
    final globalCtrl = Provider.of<GlobalShoppingController>(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        0,
        Dimensions.paddingSizeDefault,
        MediaQuery.of(context).viewInsets.bottom +
            Dimensions.paddingSizeDefault,
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
                    color: isDark
                        ? Theme.of(context).highlightColor
                        : const Color(0xFFF9FAFB),
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
                      if (widget.preview.currentPrice != null &&
                          widget.preview.originalCurrency != null)
                        Text(
                          '${widget.preview.currentPrice!.toStringAsFixed(2)} ${widget.preview.originalCurrency}',
                          textDirection: TextDirection.ltr,
                          style: textBold.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeDefault),
                        ),
                      if (widget.preview.convertedCurrentPrice != null &&
                          widget.preview.convertedCurrency != null)
                        Text(
                          '≈ ${widget.preview.convertedCurrentPrice!.toStringAsFixed(0)} ${widget.preview.convertedCurrency}',
                          textDirection: TextDirection.ltr,
                          style: textRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),

            // Fees and shipping are manually quoted by Alline; don't fabricate them.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.24)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Theme.of(context).primaryColor, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLtr
                              ? 'Displayed price is for the product only. Alline will confirm shipping, customs, service fees, and delivery estimate after review.'
                              : 'السعر الظاهر للمنتج فقط. يؤكد Alline الشحن والجمارك ورسوم الخدمة ومدة التوصيل بعد المراجعة.',
                          style: textRegular.copyWith(
                              fontSize: 11,
                              height: 1.4,
                              color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quantity Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isLtr ? 'Quantity:' : 'الكمية المطلوبة:',
                    style: textMedium.copyWith(fontSize: 13)),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 14),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text('$_quantity',
                          style: textBold.copyWith(fontSize: 13)),
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
                hintText: isLtr
                    ? 'Notes: (Color, Size, Specs)'
                    : 'الملاحظات: (اللون، المقاس، المواصفات المطلوبة)',
                hintStyle: textRegular.copyWith(
                    fontSize: 11, color: Theme.of(context).hintColor),
                filled: true,
                fillColor: isDark
                    ? Theme.of(context).highlightColor
                    : const Color(0xFFF9FAFB),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: globalCtrl.isSubmitLoading
                    ? null
                    : () async {
                        final auth =
                            Provider.of<AuthController>(context, listen: false);
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
                              isLtr
                                  ? 'Your pricing request was submitted.'
                                  : 'تم إرسال طلب التسعير. ستتم إضافته للسلة بعد اعتماد السعر.',
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
                          const Icon(Icons.shopping_cart_checkout,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isLtr
                                ? 'Submit for pricing'
                                : 'إرسال للمراجعة والتسعير',
                            style: textBold.copyWith(
                                color: Colors.white, fontSize: 14),
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
