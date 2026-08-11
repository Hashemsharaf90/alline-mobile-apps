import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
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

  bool _isValidProductUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (!['http', 'https'].contains(uri.scheme.toLowerCase())) return false;
    if (uri.host.isEmpty) return false;

    final lower = url.toLowerCase();
    if (lower.contains('javascript:') ||
        lower.contains('mailto:') ||
        lower.contains('tel:') ||
        lower.contains('/cart') ||
        lower.contains('/checkout')) {
      return false;
    }

    return true;
  }

  String _text(BuildContext context, String en, String ar) {
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    return isLtr ? en : ar;
  }

  Future<void> _copyCurrentUrl(BuildContext context) async {
    final url = await _activeUrl();
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;

    showCustomSnackBarWidget(
      _text(context, 'Product link copied', 'تم نسخ رابط المنتج'),
      context,
      snackBarType: SnackBarType.success,
    );
  }

  Future<void> _shareCurrentUrl() async {
    final url = await _activeUrl();
    await SharePlus.instance.share(ShareParams(text: url));
  }

  Future<void> _openExternal() async {
    final url = await _activeUrl();
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _showAssistedOrderSheet(BuildContext context) async {
    final bool isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final url = await _activeUrl();
    if (!context.mounted) return;

    if (!_isValidProductUrl(url)) {
      showCustomSnackBarWidget(
        isLtr
            ? 'Open a product page first, then send the request'
            : 'افتح صفحة المنتج أولا ثم أرسل طلب الشراء',
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    int quantity = 1;
    bool isSubmittingRequest = false;
    final notesController = TextEditingController();

    final sheetResult = await showModalBottomSheet<_GlobalRequestSheetResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                0,
                Dimensions.paddingSizeDefault,
                MediaQuery.of(sheetContext).viewInsets.bottom +
                    Dimensions.paddingSizeDefault,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  isLtr ? 'Request this product' : 'طلب شراء هذا المنتج',
                  textAlign: TextAlign.center,
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  isLtr
                      ? 'Send the product link to Allinye. The team will price it, calculate shipping, then add it for approval before checkout.'
                      : 'أرسل رابط المنتج إلى Allinye ليتم تسعيره وحساب الشحن، ثم إضافته للموافقة قبل إتمام الطلب.',
                  textAlign: TextAlign.center,
                  style:
                      textRegular.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    url,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Row(children: [
                  Text(
                    isLtr ? 'Quantity' : 'الكمية',
                    style:
                        textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: quantity > 1
                        ? () => setSheetState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      quantity.toString(),
                      style:
                          textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => setSheetState(() => quantity++),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                TextField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: isLtr
                        ? 'Color, size, notes...'
                        : 'اللون، المقاس، أي ملاحظات...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSubmittingRequest
                        ? null
                        : () async {
                            setSheetState(() => isSubmittingRequest = true);
                            try {
                              final result = await _submitGlobalShoppingRequest(
                                context: context,
                                sheetContext: sheetContext,
                                url: url,
                                quantity: quantity,
                                notes: notesController.text,
                                isLtr: isLtr,
                              );
                              if (result ==
                                      _GlobalRequestSheetResult.loginRequired &&
                                  sheetContext.mounted) {
                                Navigator.of(sheetContext).pop(result);
                              }
                            } finally {
                              if (sheetContext.mounted) {
                                setSheetState(
                                  () => isSubmittingRequest = false,
                                );
                              }
                            }
                          },
                    icon: isSubmittingRequest
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_shopping_cart_rounded, size: 19),
                    label: Text(
                      isLtr ? 'Send purchase request' : 'إرسال طلب الشراء',
                    ),
                  ),
                ),
              ]),
            );
          },
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 350));
    notesController.dispose();

    if (sheetResult == _GlobalRequestSheetResult.loginRequired) {
      await Future<void>.delayed(Duration.zero);
      if (!mounted || !context.mounted) {
        return;
      }

      showCustomSnackBarWidget(
        isLtr
            ? 'Please sign in first to send the request'
            : 'يرجى تسجيل الدخول أولا لإرسال الطلب',
        context,
        snackBarType: SnackBarType.warning,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          RouterHelper.getLoginRoute(action: RouteAction.push);
        }
      });
    }
  }

  Future<_GlobalRequestSheetResult?> _submitGlobalShoppingRequest({
    required BuildContext context,
    required BuildContext sheetContext,
    required String url,
    required int quantity,
    required String notes,
    required bool isLtr,
  }) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    if (!authController.isLoggedIn()) {
      return _GlobalRequestSheetResult.loginRequired;
    }

    try {
      final response = await di.sl<DioClient>().post(
        AppConstants.globalShoppingRequestUri,
        data: {
          'store_name': widget.storeName,
          'product_url': url,
          'quantity': quantity,
          'customer_notes': notes.trim().isEmpty ? null : notes.trim(),
        },
      );

      if (sheetContext.mounted) Navigator.pop(sheetContext);
      if (!context.mounted) return _GlobalRequestSheetResult.sent;

      final responseData = response.data is Map ? response.data as Map : null;
      final message = responseData?['message']?.toString();
      final cartAdded = responseData?['cart_added'] == true ||
          responseData?['cart_added'] == 1 ||
          responseData?['next_action']?.toString() == 'cart';

      showCustomSnackBarWidget(
        message ??
            (isLtr
                ? 'Request sent for pricing and approval'
                : 'تم إرسال الطلب للتسعير والموافقة'),
        context,
        snackBarType: SnackBarType.success,
      );

      if (cartAdded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            RouterHelper.getCartScreenRoute(action: RouteAction.push);
          }
        });
      }

      return _GlobalRequestSheetResult.sent;
    } catch (_) {
      if (!context.mounted) return _GlobalRequestSheetResult.failed;
      showCustomSnackBarWidget(
        isLtr
            ? 'Could not send the request. Please try again.'
            : 'تعذر إرسال الطلب، حاول مرة أخرى.',
        context,
        snackBarType: SnackBarType.error,
      );
      return _GlobalRequestSheetResult.failed;
    }
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
          title: Text(
            widget.storeName,
            style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: isLtr ? 'Refresh' : 'تحديث',
              onPressed: () => _controller.reload(),
              icon: const Icon(Icons.refresh_rounded),
            ),
            PopupMenuButton<_GlobalStoreAction>(
              onSelected: (action) {
                switch (action) {
                  case _GlobalStoreAction.copy:
                    _copyCurrentUrl(context);
                    break;
                  case _GlobalStoreAction.share:
                    _shareCurrentUrl();
                    break;
                  case _GlobalStoreAction.external:
                    _openExternal();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _GlobalStoreAction.copy,
                  child: Text(isLtr ? 'Copy link' : 'نسخ الرابط'),
                ),
                PopupMenuItem(
                  value: _GlobalStoreAction.share,
                  child: Text(isLtr ? 'Share link' : 'مشاركة الرابط'),
                ),
                PopupMenuItem(
                  value: _GlobalStoreAction.external,
                  child: Text(isLtr ? 'Open in browser' : 'فتح في المتصفح'),
                ),
              ],
            ),
          ],
        ),
        body: Column(children: [
          if (!_isLoaded)
            LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
              minHeight: 2,
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: ThemeShadow.getShadow(context),
              ),
              child: Row(children: [
                IconButton.filledTonal(
                  tooltip: isLtr ? 'Back' : 'رجوع',
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                IconButton.filledTonal(
                  tooltip: isLtr ? 'Forward' : 'تقدم',
                  onPressed: () async {
                    if (await _controller.canGoForward()) {
                      await _controller.goForward();
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAssistedOrderSheet(context),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 19),
                    label: Text(
                      isLtr ? 'Request via Allinye' : 'اطلبه عبر Allinye',
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

enum _GlobalStoreAction {
  copy,
  share,
  external,
}

enum _GlobalRequestSheetResult {
  loginRequired,
  sent,
  failed,
}
