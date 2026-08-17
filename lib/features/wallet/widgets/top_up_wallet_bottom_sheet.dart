import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class TopUpWalletBottomSheet extends StatefulWidget {
  const TopUpWalletBottomSheet({super.key});

  @override
  State<TopUpWalletBottomSheet> createState() => _TopUpWalletBottomSheetState();
}

class _TopUpWalletBottomSheetState extends State<TopUpWalletBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _txIdController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();

  int _selectedWalletIndex = 0;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _wallets = [
    {
      'name': 'محفظة جيب (CAC Bank)',
      'subtitle': 'بنك التسليف التعاوني والزراعي',
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFFC8102E),
      'account_num': '771111111',
      'merchant_code': 'ALLINE-JEEB',
      'account_name': 'Alline E-Commerce Ltd',
    },
    {
      'name': 'جوالي (Jawwali)',
      'subtitle': 'بنك اليمن والبحرين الشامل',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFFE88A1A),
      'account_num': '773333333',
      'merchant_code': 'ALLINE-JAWWAL',
      'account_name': 'متجر Alline',
    },
    {
      'name': 'خدمة حاسب / بنك الكريمي',
      'subtitle': 'الكريمي للتمويل الأصغر الإسلامي',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF5B2C82),
      'account_num': '123456789',
      'merchant_code': 'ALLINE-YE',
      'account_name': 'مؤسسة Alline للتجارة والتسوق',
    },
    {
      'name': 'ONE كاش (OneCash)',
      'subtitle': 'محفظة ون كاش الإلكترونية',
      'icon': Icons.credit_card_rounded,
      'color': const Color(0xFFE85D04),
      'account_num': '772222222',
      'merchant_code': 'ALLINE-ONE',
      'account_name': 'متجر Alline الإلكتروني',
    },
    {
      'name': 'كاش (Cach - Tadhamon)',
      'subtitle': 'بنك التضامن الإسلامي',
      'icon': Icons.payments_rounded,
      'color': const Color(0xFF00875A),
      'account_num': '774444444',
      'merchant_code': 'ALLINE-CACH',
      'account_name': 'Alline Store',
    },
    {
      'name': 'فلوسك (Floosak - YKB)',
      'subtitle': 'بنك اليمن والكويت',
      'icon': Icons.savings_rounded,
      'color': const Color(0xFF005696),
      'account_num': '770000000',
      'merchant_code': 'YKB-FLOOSAK',
      'account_name': 'Alline Store',
    },
    {
      'name': 'بيس (P-Yes)',
      'subtitle': 'محفظة بيس الإلكترونية',
      'icon': Icons.wallet_rounded,
      'color': const Color(0xFFF7931A),
      'account_num': '775555555',
      'merchant_code': 'PYES-ALLINE',
      'account_name': 'Alline Store',
    },
    {
      'name': 'حوالة صرافة (النجم / الامتياز / يمن إكسبرس)',
      'subtitle': 'جميع شبكات الصرافة والتحويل في اليمن',
      'icon': Icons.local_atm_rounded,
      'color': const Color(0xFF1E293B),
      'account_num': '777000000',
      'merchant_code': 'صنعاء - اليمن',
      'account_name': 'هاشم شرف / مسؤول الحسابات',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _txIdController.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label: $text بنجاح'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedWallet = _wallets[_selectedWalletIndex];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
                Text(
                  'إضافة رصيد للمحفظة 💳',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أضف المبلغ هنا :',
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: textBold.copyWith(
                                  fontSize: 24,
                                  color: Theme.of(context).primaryColor,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '0.00',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ريال يمني (YER)',
                                style: textBold.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'قم باختيار وسيلة الدفع المناسبة ثم اضغط على موافق :',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _wallets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final wallet = _wallets[index];
                      final isSelected = _selectedWalletIndex == index;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedWalletIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (wallet['color'] as Color).withValues(alpha: 0.08)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? (wallet['color'] as Color)
                                  : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? (wallet['color'] as Color)
                                        : Theme.of(context).hintColor,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: wallet['color'] as Color,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallet['name'] as String,
                                      style: textBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: isSelected
                                            ? (wallet['color'] as Color)
                                            : Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    Text(
                                      wallet['subtitle'] as String,
                                      style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (wallet['color'] as Color).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  wallet['icon'] as IconData,
                                  color: wallet['color'] as Color,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (selectedWallet['color'] as Color).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (selectedWallet['color'] as Color).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: selectedWallet['color'] as Color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'بيانات التحويل إلى الحساب المعتمد:',
                              style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: selectedWallet['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildCopyRow(
                          label: 'رقم الحساب / المحفظة:',
                          value: selectedWallet['account_num'] as String,
                          onCopy: () => _copyToClipboard(
                            selectedWallet['account_num'] as String,
                            'رقم الحساب',
                          ),
                        ),
                        const SizedBox(height: 6),

                        _buildCopyRow(
                          label: 'رمز التاجر / الخدمة:',
                          value: selectedWallet['merchant_code'] as String,
                          onCopy: () => _copyToClipboard(
                            selectedWallet['merchant_code'] as String,
                            'رمز التاجر',
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Text(
                              'اسم الحساب: ',
                              style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                selectedWallet['account_name'] as String,
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'بيانات تأكيد عملية التحويل:',
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _txIdController,
                    decoration: InputDecoration(
                      hintText: 'رقم العملية / الإشعار من تطبيق المحفظة *',
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.receipt_long_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _senderNameController,
                    decoration: InputDecoration(
                      hintText: 'اسم المحول / صاحب الحساب *',
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _senderPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'رقم الهاتف المرتبط بالتحويل *',
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.phone_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_amountController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('يرجى إدخال المبلغ المراد إيداعه')),
                                );
                                return;
                              }
                              if (_txIdController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('يرجى إدخال رقم العملية / الإشعار')),
                                );
                                return;
                              }

                              setState(() {
                                _isSubmitting = true;
                              });

                              Future.delayed(const Duration(seconds: 1), () {
                                if (!mounted) return;
                                setState(() {
                                  _isSubmitting = false;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      '✅ تم إرسال إشعار الإيداع بنجاح! سيتم مراجعته وإضافة الرصيد فوراً.',
                                    ),
                                    backgroundColor: Colors.green.shade700,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7931A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'مـوافـق / تأكيد الإيداع 🚀',
                              style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyRow({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: textMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copy_rounded,
                  size: 13,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'نسخ',
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
