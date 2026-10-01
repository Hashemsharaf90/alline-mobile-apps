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
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_logo_widget.dart';

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
                          ? 'Extracting product images & details from ${widget.storeName}...'
                          : 'جارٍ استخراج صور وتفاصيل المنتج من ${widget.storeName}...',
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: GlobalStoreLogoWidget(
                  storeName: widget.storeName,
                  height: 18,
                  width: 36,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.storeName,
                style: textBold.copyWith(
                    color: Colors.white, fontSize: Dimensions.fontSizeLarge),
              ),
            ],
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
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _openProductRequestSheet(context),
                          icon: const Icon(Icons.add_shopping_cart_rounded,
                              color: Colors.white, size: 22),
                          label: Text(
                            isLtr ? 'Add to Alline Cart 🛒' : 'أضف إلى سلة Alline 🛒',
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
  int _selectedImageIndex = 0;
  late final PageController _pageController;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

    // Collect all valid images from backend preview
    final List<String> allImages = [];
    if (widget.preview.images != null && widget.preview.images!.isNotEmpty) {
      for (final img in widget.preview.images!) {
        if (img.trim().isNotEmpty && !allImages.contains(img.trim())) {
          allImages.add(img.trim());
        }
      }
    }
    if (allImages.isEmpty &&
        widget.preview.thumbnail != null &&
        widget.preview.thumbnail!.trim().isNotEmpty) {
      allImages.add(widget.preview.thumbnail!.trim());
    }

    final hasDiscount = widget.preview.originalPrice != null &&
        widget.preview.currentPrice != null &&
        widget.preview.originalPrice! > widget.preview.currentPrice!;

    final discountPercent = hasDiscount
        ? (((widget.preview.originalPrice! - widget.preview.currentPrice!) /
                    widget.preview.originalPrice!) *
                100)
            .round()
        : 0;

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
            // IMAGE CAROUSEL / GALLERY
            if (allImages.isNotEmpty) ...[
              Container(
                height: 210,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark
                      ? Theme.of(context).highlightColor
                      : const Color(0xFFF9FAFB),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: allImages.length,
                      onPageChanged: (idx) {
                        setState(() => _selectedImageIndex = idx);
                      },
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomImageWidget(
                            image: allImages[idx],
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                    // Floating Store Badge
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: GlobalStoreLogoWidget(
                                storeName: widget.storeName,
                                height: 12,
                                width: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.storeName,
                              style: textBold.copyWith(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Counter Pill
                    if (allImages.length > 1)
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_selectedImageIndex + 1} / ${allImages.length}',
                            style: textBold.copyWith(
                                color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Thumbnail strip if multiple images exist
              if (allImages.length > 1) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: allImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final isSelected = idx == _selectedImageIndex;
                      return InkWell(
                        onTap: () {
                          _pageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
                                ? Theme.of(context).highlightColor
                                : const Color(0xFFF9FAFB),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CustomImageWidget(
                            image: allImages[idx],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],

            // PRODUCT TITLE
            Text(
              widget.preview.title ?? widget.storeName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),

            // PRICING CARD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context).highlightColor
                    : const Color(0xFFF0F6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLtr ? 'Source Price:' : 'سعر المنتج:',
                        style: textRegular.copyWith(
                          fontSize: 11,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (widget.preview.currentPrice != null &&
                              widget.preview.originalCurrency != null)
                            Text(
                              '${widget.preview.currentPrice!.toStringAsFixed(2)} ${widget.preview.originalCurrency}',
                              textDirection: TextDirection.ltr,
                              style: textBold.copyWith(
                                color: const Color(0xFF032C75),
                                fontSize: 15,
                              ),
                            ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 8),
                            Text(
                              widget.preview.originalPrice!.toStringAsFixed(2),
                              textDirection: TextDirection.ltr,
                              style: textRegular.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Theme.of(context).hintColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9363E).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-$discountPercent%',
                                style: textBold.copyWith(
                                  color: const Color(0xFFD9363E),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (widget.preview.convertedCurrentPrice != null &&
                      widget.preview.convertedCurrency != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isLtr ? 'Estimated in YER:' : 'المعادل بالريال اليمني:',
                          style: textRegular.copyWith(
                            fontSize: 11,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '≈ ${widget.preview.convertedCurrentPrice!.toStringAsFixed(0)} ${widget.preview.convertedCurrency}',
                          textDirection: TextDirection.ltr,
                          style: textBold.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // TRANSPARENCY NOTICE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.22),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLtr ? 'Item price only' : 'سعر المنتج الأصلي فقط',
                          style: textBold.copyWith(
                            fontSize: 11.5,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLtr
                              ? 'Shipping, customs, and delivery fees are calculated and confirmed after our team reviews your item.'
                              : 'يتم احتساب الشحن الدولي والجمارك والتوصيل وإضافتها للسلة بعد مراجعة فريق Alline للطلب.',
                          style: textRegular.copyWith(
                            fontSize: 11,
                            height: 1.4,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // QUANTITY STEPPER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isLtr ? 'Quantity:' : 'الكمية المطلوبة:',
                  style: textMedium.copyWith(fontSize: 13),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                    color: isDark
                        ? Theme.of(context).highlightColor
                        : const Color(0xFFF9FAFB),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '$_quantity',
                          style: textBold.copyWith(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // NOTES / SPECS
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: isLtr
                    ? 'Notes: (Color, Size, Specs)'
                    : 'المواصفات المطلوبة: (اللون، المقاس، أو أي ملاحظات للطلب)',
                hintStyle: textRegular.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
                filled: true,
                fillColor: isDark
                    ? Theme.of(context).highlightColor
                    : const Color(0xFFF9FAFB),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ADD TO CART BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                                  ? 'Added to your Alline Cart requests! Price will be confirmed.'
                                  : 'تمت إضافة المنتج إلى طلبات سلة Alline بنجاح! سيتم مراجعة الشحن واعتماد السعر.',
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
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_shopping_cart_rounded,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            isLtr
                                ? 'Add to Alline Cart 🛒'
                                : 'أضف إلى سلة Alline 🛒',
                            style: textBold.copyWith(
                              color: Colors.white,
                              fontSize: 15,
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
