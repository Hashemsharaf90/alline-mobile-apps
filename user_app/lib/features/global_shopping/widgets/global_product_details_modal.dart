import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/controllers/global_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_showcase_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/global_store_webview_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/screens/my_global_orders_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/widgets/global_store_logo_widget.dart';
import 'package:provider/provider.dart';

class GlobalProductDetailsModal extends StatefulWidget {
  final GlobalShowcaseProduct product;

  const GlobalProductDetailsModal({
    super.key,
    required this.product,
  });

  @override
  State<GlobalProductDetailsModal> createState() => _GlobalProductDetailsModalState();
}

class _GlobalProductDetailsModalState extends State<GlobalProductDetailsModal> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  int _quantity = 1;
  String _selectedColor = 'أسود داكن';
  bool _isFavorite = false;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _colors = [
    {'name': 'أسود داكن', 'color': const Color(0xFF0F172A)},
    {'name': 'وردي هادئ', 'color': const Color(0xFFFECDD3)},
    {'name': 'أبيض لؤلؤي', 'color': const Color(0xFFF1F5F9)},
    {'name': 'أخضر زمردي', 'color': const Color(0xFF065F46)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product.isRfq && widget.product.moq != null) {
      _quantity = widget.product.moq!;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAddToOrder() async {
    setState(() => _isSubmitting = true);

    final req = GlobalShoppingRequestModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      storeName: widget.product.store,
      productUrl: widget.product.productUrl,
      quantity: _quantity,
      customerNotes: 'اللون: $_selectedColor - المنتج: ${widget.product.name}',
      status: 'pending_pricing',
      approvedPrice: widget.product.priceUsd,
      quotedCurrency: 'USD',
      createdAt: DateTime.now().toIso8601String(),
    );

    final ctrl = Provider.of<GlobalShoppingController>(context, listen: false);
    ctrl.requestsList.insert(0, req);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showCustomSnackBarWidget(
      '✓ تم إضافة المنتج إلى طلباتك العالمية بنجاح للمراجعة والتسعير.',
      context,
      snackBarType: SnackBarType.success,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);
    const orangeAccent = Color(0xFFEC970D);

    final isAlibaba = widget.product.store.toLowerCase().contains('alibaba') || widget.product.isRfq;
    final images = widget.product.galleryImages.isNotEmpty
        ? widget.product.galleryImages
        : [widget.product.imageUrl];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: navyColor,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'التسوق العالمي',
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: navyColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyGlobalOrdersScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: primaryBlue, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'طلباتي',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Image Carousel Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 240,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: images.length,
                                onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                                itemBuilder: (context, i) {
                                  return CachedNetworkImage(
                                    imageUrl: images[i],
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(color: primaryBlue),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                      color: secondaryTextColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Favorite Button (Top-Right matching Stitch c250a066)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => setState(() => _isFavorite = !_isFavorite),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Icon(
                                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: _isFavorite ? Colors.red : secondaryTextColor,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (i) {
                            final isActive = i == _currentImageIndex;
                            return InkWell(
                              onTap: () {
                                _pageController.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                                width: isActive ? 10 : 6,
                                height: isActive ? 10 : 6,
                                decoration: BoxDecoration(
                                  color: isActive ? primaryBlue : const Color(0xFFD1E0F5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title & Meta Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sample Data Notice Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline_rounded, size: 12, color: secondaryTextColor),
                              SizedBox(width: 4),
                              Text(
                                'بيانات نموذجية',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: navyColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: secondaryTextColor,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF0F4FA), height: 1),
                        const SizedBox(height: 10),

                        // Store Source Row (Matching Stitch: Logo | StoreName      عرض متجر >)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GlobalStoreLogoWidget(
                                  storeName: widget.product.store,
                                  height: 22,
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 1,
                                  height: 16,
                                  color: borderColor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _arabicStoreTitle(widget.product.store),
                                  style: const TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: navyColor,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GlobalStoreWebViewScreen(
                                      storeName: widget.product.store,
                                      initialUrl: widget.product.productUrl,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'عرض متجر ${_arabicStoreTitle(widget.product.store)}',
                                    style: const TextStyle(
                                      fontFamily: 'AllineTajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: primaryBlue),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Color(0xFFF0F4FA), height: 1),
                        const SizedBox(height: 10),

                        // Price Row (Bold Navy USD price matching Stitch c250a066)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAlibaba
                                  ? 'يتطلب طلب عرض سعر (RFQ)'
                                  : 'USD ${widget.product.priceUsd.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isAlibaba ? orangeAccent : navyColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 12, color: secondaryTextColor),
                                SizedBox(width: 4),
                                Text(
                                  'آخر تحديث للسعر: اليوم 10:45 ص',
                                  style: TextStyle(
                                    fontFamily: 'AllineTajawal',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Variants & Options Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Color Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'اللون',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: navyColor,
                              ),
                            ),
                            Text(
                              _selectedColor,
                              style: const TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _colors.map((c) {
                            final isSel = c['name'] == _selectedColor;
                            return InkWell(
                              onTap: () => setState(() => _selectedColor = c['name'] as String),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c['color'] as Color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSel ? primaryBlue : Colors.black12,
                                      blurRadius: isSel ? 6 : 2,
                                      spreadRadius: isSel ? 2 : 0,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Size Selector Dropdown
                        const Text(
                          'المقاس',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: navyColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'مقاس واحد (قابل للتعديل)',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: navyColor,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded, color: secondaryTextColor, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quantity Stepper
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الكمية',
                              style: TextStyle(
                                fontFamily: 'AllineTajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: navyColor,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final minLimit = (widget.product.isRfq && widget.product.moq != null)
                                          ? widget.product.moq!
                                          : 1;
                                      if (_quantity > minLimit) {
                                        setState(() => _quantity--);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      child: Text(
                                        '−',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: navyColor),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '$_quantity',
                                      style: const TextStyle(
                                        fontFamily: 'AllineTajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: navyColor,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => setState(() => _quantity++),
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      child: Text(
                                        '+',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: navyColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mandatory Price Disclaimer Card (Strictly Required by Specification)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD1E0F5)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_rounded, color: primaryBlue, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السعر من المصدر قبل الشحن والرسوم',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF032C75),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'يشمل السعر المعروض سعر المنتج من المتجر الأصلي فقط، ولا يشمل تكلفة الشحن الدولي أو الرسوم والضرائب الجمركية المحتملة. سيتم احتساب الإجمالي النهائي بدقة قبل تأكيد الطلب.',
                                style: TextStyle(
                                  fontFamily: 'AllineTajawal',
                                  fontSize: 11,
                                  color: Color(0xFF476694),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // View in Original Store Link Button
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GlobalStoreWebViewScreen(
                            storeName: widget.product.store,
                            initialUrl: widget.product.productUrl,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 16, color: primaryBlue),
                          SizedBox(width: 6),
                          Text(
                            'عرض في المتجر الأصلي',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Sticky Bottom CTA Button (54px)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _onAddToOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAlibaba ? orangeAccent : primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    shadowColor: (isAlibaba ? orangeAccent : primaryBlue).withValues(alpha: 0.35),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox.shrink()
                      : const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
                  label: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : Text(
                          isAlibaba ? 'طلب عرض سعر للمصنع' : 'إضافة إلى طلب الشراء',
                          style: const TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
