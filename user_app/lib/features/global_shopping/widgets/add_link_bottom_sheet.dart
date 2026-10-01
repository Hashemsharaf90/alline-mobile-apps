import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_showcase_product_model.dart';

class AddLinkBottomSheet extends StatefulWidget {
  final ValueChanged<GlobalShowcaseProduct>? onProductResolved;

  const AddLinkBottomSheet({
    super.key,
    this.onProductResolved,
  });

  @override
  State<AddLinkBottomSheet> createState() => _AddLinkBottomSheetState();
}

class _AddLinkBottomSheetState extends State<AddLinkBottomSheet> {
  final TextEditingController _urlController = TextEditingController();
  String? _statusType; // 'success', 'warning', 'error'
  String? _statusMessage;
  bool _isProcessing = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _validateAndProcessUrl(String rawUrl) async {
    final url = rawUrl.trim().toLowerCase();

    if (url.isEmpty) {
      setState(() {
        _statusType = 'error';
        _statusMessage = 'الرجاء إدخال أو لصق رابط المنتج أولاً.';
      });
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() {
        _statusType = 'error';
        _statusMessage = 'رابط غير صالح: تأكد من نسخ رابط يبدأ بـ https://';
      });
      return;
    }

    if (url.contains('amazon.')) {
      setState(() {
        _statusType = 'success';
        _statusMessage = '✓ تم التعرف على المتجر: Amazon. جاري قراءة بيانات المنتج...';
        _isProcessing = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _resolveProduct('huawei_band');
    } else if (url.contains('aliexpress.')) {
      setState(() {
        _statusType = 'success';
        _statusMessage = '✓ تم التعرف على المتجر: AliExpress. جاري قراءة بيانات المنتج...';
        _isProcessing = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _resolveProduct('wireless_headphones');
    } else if (url.contains('shein.')) {
      setState(() {
        _statusType = 'success';
        _statusMessage = '✓ تم التعرف على المتجر: SHEIN. جاري قراءة بيانات المنتج...';
        _isProcessing = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _resolveProduct('shein_coat');
    } else if (url.contains('alibaba.')) {
      setState(() {
        _statusType = 'warning';
        _statusMessage = '✓ تم التعرف على المتجر: Alibaba (طلبات الجملة والمصانع). جاري تجهيز نموذج طلب السعر...';
        _isProcessing = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _resolveProduct('alibaba_tools');
    } else {
      setState(() {
        _statusType = 'warning';
        _statusMessage = '⚠️ متجر غير مدعوم حالياً: يدعم Alline حالياً فقط (Amazon, SHEIN, AliExpress, Alibaba). يمكنك التواصل مع الدعم لمساعدتك.';
        _isProcessing = false;
      });
    }
  }

  void _resolveProduct(String productId) {
    Navigator.of(context).pop();
    final matched = GlobalShowcaseRepository.curatedProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => GlobalShowcaseRepository.curatedProducts.first,
    );
    widget.onProductResolved?.call(matched);
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _urlController.text = data.text!;
      _validateAndProcessUrl(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_link_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'أضف رابط المنتج',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: navyColor,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            const Text(
              'سنحاول قراءة تفاصيل المنتج آلياً، ويمكنك مراجعتها وتأكيد المواصفات والكمية قبل إرسال الطلب.',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: secondaryTextColor,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),

            // Supported Stores Badges
            Row(
              children: [
                const Text(
                  'المتاجر المدعومة: ',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
                ...['Amazon', 'SHEIN', 'AliExpress', 'Alibaba'].map(
                  (s) => Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: navyColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // URL Input with Paste Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        color: navyColor,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'https://www.amazon.com/dp/...',
                        hintStyle: TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: _pasteFromClipboard,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Text(
                          'لصق',
                          style: TextStyle(
                            fontFamily: 'AllineTajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Dynamic Validation Feedback Box
            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusType == 'success'
                      ? const Color(0xFFECFDF5)
                      : (_statusType == 'warning' ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusType == 'success'
                        ? const Color(0xFFA7F3D0)
                        : (_statusType == 'warning' ? const Color(0xFFFDE68A) : const Color(0xFFFECACA)),
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _statusType == 'success'
                        ? const Color(0xFF065F46)
                        : (_statusType == 'warning' ? const Color(0xFF92400E) : const Color(0xFF991B1B)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Quick Samples Chips
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'جرّب نماذج روابط سريعة:',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildQuickChip(
                      label: 'رابط أمازون صالح',
                      bgColor: const Color(0xFFEFF6FF),
                      textColor: primaryBlue,
                      url: 'https://www.amazon.com/dp/B0BYZ28W4X',
                    ),
                    _buildQuickChip(
                      label: 'متجر غير مدعوم (eBay)',
                      bgColor: const Color(0xFFFFFBEB),
                      textColor: const Color(0xFFB45309),
                      url: 'https://www.ebay.com/itm/123456',
                    ),
                    _buildQuickChip(
                      label: 'رابط غير صالح',
                      bgColor: const Color(0xFFFEF2F2),
                      textColor: const Color(0xFFDC2626),
                      url: 'invalid-url-text',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Submit Button (Height 54px)
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _validateAndProcessUrl(_urlController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  disabledBackgroundColor: primaryBlue.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: primaryBlue.withValues(alpha: 0.4),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'جاري قراءة الرابط...',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'متابعة وقراءة الرابط',
                            style: TextStyle(
                              fontFamily: 'AllineTajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required Color bgColor,
    required Color textColor,
    required String url,
  }) {
    return InkWell(
      onTap: () {
        _urlController.text = url;
        _validateAndProcessUrl(url);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'AllineTajawal',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
