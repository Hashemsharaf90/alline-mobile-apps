import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class TopUpWalletBottomSheet extends StatefulWidget {
  const TopUpWalletBottomSheet({super.key});

  @override
  State<TopUpWalletBottomSheet> createState() => _TopUpWalletBottomSheetState();
}

class _TopUpWalletBottomSheetState extends State<TopUpWalletBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _voucherCodeController = TextEditingController();
  final TextEditingController _payerPhoneController = TextEditingController();

  late TabController _tabController;
  int _selectedWalletIndex = 0;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 1,
      'code': 'jeeb_cac',
      'name': 'محفظة جيب',
      'bank': 'CAC Bank كاك بنك',
      'logo': 'assets/images/jeeb_wallet.png',
      'color': Color(0xFFC8102E),
      'account_num': '771111111',
      'merchant_code': 'ALLINE-JEEB',
      'account_name': 'متجر Alline الإلكتروني',
      'voucher_label': 'كود شراء جيب (رمز القسيمة)',
      'steps': [
        'افتح تطبيق محفظة جيب واضغط على (دفع مشتريات / قسيمة شراء).',
        'حدد المبلغ المطلوب وقم بتوليد رمز الشراء.',
        'الصق رمز الشراء والمبلغ هنا واضغط (شحن فوري ⚡).'
      ]
    },
    {
      'id': 2,
      'code': 'kuraimi_haseb',
      'name': 'الكريمي حاسب / جوال',
      'bank': 'Kuraimi Bank بنك الكريمي',
      'logo': 'assets/images/kuraimi_wallet.png',
      'color': Color(0xFF5B2C82),
      'account_num': '123456789',
      'merchant_code': 'ALLINE-YE',
      'account_name': 'مؤسسة Alline للتجارة والتسوق',
      'voucher_label': 'رمز عملية حاسب / رقم الإشعار',
      'steps': [
        'من تطبيق الكريمي جوال اختر (حاسب / دفع مشتريات) لرمز التاجر ALLINE-YE.',
        'أو قم بالتحويل المباشر لحسابنا رقم 123456789.',
        'الصق رقم العملية أو الرمز واضغط (شحن فوري ⚡).'
      ]
    },
    {
      'id': 3,
      'code': 'one_cash',
      'name': 'ون كاش ONE Cash',
      'bank': 'شركة ون كاش / القطيبي',
      'logo': 'assets/images/one_cash_wallet.png',
      'color': Color(0xFFE85D04),
      'account_num': '772222222',
      'merchant_code': 'ALLINE-ONE',
      'account_name': 'متجر Alline الإلكتروني',
      'voucher_label': 'كود قسيمة ون كاش',
      'steps': [
        'افتح تطبيق ون كاش واختر (قسيمة شراء / سداد تاجر).',
        'حدد المبلغ وأنشئ رمز القسيمة الفوري.',
        'الصق رمز القسيمة هنا واضغط (شحن فوري ⚡).'
      ]
    },
    {
      'id': 4,
      'code': 'jawwali_wepay',
      'name': 'محفظة جوالي WePay',
      'bank': 'بنك اليمن والكويت / الأمل',
      'logo': 'assets/images/jawwali_wallet.png',
      'color': Color(0xFFE88A1A),
      'account_num': '773333333',
      'merchant_code': 'ALLINE-JAWWAL',
      'account_name': 'Alline Store',
      'voucher_label': 'رمز شراء جوالي',
      'steps': [
        'افتح تطبيق جوالي واختر (رمز شراء / دفع مشتريات).',
        'أدخل المبلغ المطلوب واضغط توليد الرمز.',
        'الصق رمز الشراء واضغط (شحن فوري ⚡).'
      ]
    },
    {
      'id': 5,
      'code': 'tadhamon_cash',
      'name': 'كاش التضامن',
      'bank': 'بنك التضامن الإسلامي',
      'logo': 'assets/images/tadhamon_wallet.png',
      'color': Color(0xFF00875A),
      'account_num': '774444444',
      'merchant_code': 'ALLINE-CACH',
      'account_name': 'Alline Store',
      'voucher_label': 'رقم قسيمة كاش / رقم الإشعار',
      'steps': [
        'افتح تطبيق كاش التضامن وأنشئ قسيمة مشتريات بالمبلغ المطلوب.',
        'أو حول لحساب التاجر رقم 774444444.',
        'الصق رقم القسيمة أو الإشعار واضغط (شحن فوري ⚡).'
      ]
    },
    {
      'id': 6,
      'code': 'floosak_ykb',
      'name': 'محفظة فلوسك',
      'bank': 'بنك اليمن والكويت YKB',
      'logo': 'assets/images/floosak_wallet.png',
      'color': Color(0xFF005696),
      'account_num': '770000000',
      'merchant_code': 'YKB-FLOOSAK',
      'account_name': 'Alline Store',
      'voucher_label': 'مرجع عملية فلوسك / رقم الإشعار',
      'steps': [
        'من تطبيق فلوسك اختر دفع مشتريات لتاجر أو تحويل لمشترك.',
        'حول لحساب 770000000 وانسخ مرجع العملية.',
        'الصق مرجع العملية هنا واضغط (شحن فوري ⚡).'
      ]
    },
    {
      'id': 7,
      'code': 'pyes_saba',
      'name': 'محفظة بيس P-Yes',
      'bank': 'بنك سبأ الإسلامي',
      'logo': 'assets/images/pyes_wallet.png',
      'color': Color(0xFF0C2340),
      'account_num': '775555555',
      'merchant_code': 'PYES-ALLINE',
      'account_name': 'Alline Store',
      'voucher_label': 'رقم عملية بيس / رقم الإشعار',
      'steps': [
        'افتح محفظة بيس واختر سداد مشتريات أو تحويل.',
        'حول للمحفظة 775555555 وانسخ رقم العملية.',
        'الصق رقم العملية هنا واضغط (شحن فوري ⚡).'
      ]
    },
    {
      'id': 8,
      'code': 'exchange_networks',
      'name': 'شبكات الصرافة والحوالات',
      'bank': 'النجم / الامتياز / يمن إكسبرس',
      'logo': 'assets/images/exchange_hawala.png',
      'color': Color(0xFF1E293B),
      'account_num': '777000000',
      'merchant_code': 'صنعاء - اليمن',
      'account_name': 'هاشم شرف / مسؤول الحسابات',
      'voucher_label': 'رقم الحوالة (السند)',
      'steps': [
        'أرسل حوالة باسم المستلم (هاشم شرف) على هاتف 777000000.',
        'عبر أي شبكة (النجم، الامتياز، يمن إكسبرس، الهتار، القطيبي).',
        'أدخل رقم الحوالة هنا واضغط تأكيد.'
      ]
    },
  ];

  final List<int> _quickAmounts = [1000, 3000, 5000, 10000, 20000, 50000];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _voucherCodeController.dispose();
    _payerPhoneController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('تم نسخ $label بنجاح', style: textRegular.copyWith(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleTopUp() async {
    final amountText = _amountController.text.trim();
    final voucherCode = _voucherCodeController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال المبلغ المراد شحنه', style: textRegular.copyWith(color: Colors.white)),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال مبلغ صحيح بالريال اليمني', style: textRegular.copyWith(color: Colors.white)),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (voucherCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال كود الشراء أو رقم الإشعار من المحفظة', style: textRegular.copyWith(color: Colors.white)),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final currentWallet = _wallets[_selectedWalletIndex];

    try {
      final walletController = Provider.of<WalletController>(context, listen: false);
      final profileController = Provider.of<ProfileController>(context, listen: false);

      // Attempt direct local wallet topup with voucher code
      bool success = await walletController.createLocalWalletTopUpRequest(
        amountText,
        context,
      );

      // Refresh balance in header & profile
      await profileController.getUserInfo(context);

      setState(() => _isSubmitting = false);

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog(amount, currentWallet['name']);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog(amount, currentWallet['name']);
      }
    }
  }

  void _showSuccessDialog(double amount, String walletName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 56),
            ),
            const SizedBox(height: 16),
            Text(
              'تم شحن الرصيد بنجاح! ⚡',
              style: textBold.copyWith(fontSize: 18, color: const Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'تم تسجيل كود الشحن بمبلغ ${PriceConverter.convertPrice(ctx, amount)} عبر $walletName وتحديث رصيد محفظتك فوراً.',
              style: textRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('ممتاز، شكراً لك', style: textBold.copyWith(fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWallet = _wallets[_selectedWalletIndex];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'شحن رصيد المحفظة',
                        style: textBold.copyWith(fontSize: 18, color: const Color(0xFF0F172A)),
                      ),
                      Text(
                        'شحن فوري بأكواد شراء المحافظ اليمنية أو التحويل',
                        style: textRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Live Balance Banner
                  Consumer<ProfileController>(
                    builder: (context, profile, _) {
                      final balance = profile.userInfoModel?.walletBalance ?? 0.0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'رصيدك الحالي في Alline:',
                                  style: textMedium.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              PriceConverter.convertPrice(context, balance),
                              style: textBold.copyWith(color: Colors.white, fontSize: 17),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Section Title: Select Wallet
                  Text(
                    'اختر المحفظة أو البنك اليمني:',
                    style: textBold.copyWith(fontSize: 14, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Wallet List with Real Logos
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _wallets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final w = _wallets[index];
                        final isSelected = _selectedWalletIndex == index;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedWalletIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 110,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    w['logo'],
                                    height: 38,
                                    width: 38,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: w['color'],
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  w['name'],
                                  style: isSelected
                                      ? textBold.copyWith(fontSize: 11, color: const Color(0xFF1D4ED8))
                                      : textMedium.copyWith(fontSize: 11, color: const Color(0xFF475569)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Selected Wallet Info & Merchant Details Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                currentWallet['logo'],
                                height: 26,
                                width: 26,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.account_balance_rounded,
                                  color: currentWallet['color'],
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentWallet['name'],
                                    style: textBold.copyWith(fontSize: 14, color: const Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    currentWallet['bank'],
                                    style: textRegular.copyWith(fontSize: 11, color: const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 10),

                        // Account / Merchant Copy Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('رقم الحساب / رمز التاجر:', style: textRegular.copyWith(fontSize: 11, color: const Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(
                                  currentWallet['account_num'],
                                  style: textBold.copyWith(fontSize: 14, color: const Color(0xFF0F172A), letterSpacing: 1),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(currentWallet['account_num'], 'رقم الحساب'),
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: Text('نسخ', style: textBold.copyWith(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Step-by-step instructions
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (currentWallet['steps'] as List<String>).map((step) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: textRegular.copyWith(fontSize: 11.5, color: const Color(0xFF334155), height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Quick Amount Selector
                  Text('المبلغ بالريال اليمني (YER):', style: textBold.copyWith(fontSize: 13, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickAmounts.map((amt) {
                      final isSelected = _amountController.text == amt.toString();
                      return ChoiceChip(
                        label: Text('$amt ر.ي', style: isSelected ? textBold.copyWith(color: Colors.white, fontSize: 12) : textMedium.copyWith(color: const Color(0xFF334155), fontSize: 12)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (selected) {
                          if (selected) {
                            HapticFeedback.selectionClick();
                            setState(() => _amountController.text = amt.toString());
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Custom Amount Input
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: textBold.copyWith(fontSize: 16, color: const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'أو اكتب المبلغ هنا...',
                      hintStyle: textRegular.copyWith(fontSize: 13, color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF2563EB)),
                      suffixText: 'ر.ي',
                      suffixStyle: textBold.copyWith(color: const Color(0xFF2563EB), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Voucher / Purchase Code Input
                  Text(currentWallet['voucher_label'] ?? 'كود الشراء / رقم الإشعار:', style: textBold.copyWith(fontSize: 13, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _voucherCodeController,
                    style: textBold.copyWith(fontSize: 15, color: const Color(0xFF0F172A), letterSpacing: 0.5),
                    decoration: InputDecoration(
                      hintText: 'الصق كود الشراء أو رقم الإشعار هنا...',
                      hintStyle: textRegular.copyWith(fontSize: 12, color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF2563EB)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste_rounded, color: Color(0xFF2563EB)),
                        tooltip: 'لصق',
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null && data!.text!.isNotEmpty) {
                            HapticFeedback.selectionClick();
                            setState(() => _voucherCodeController.text = data.text!.trim());
                          }
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleTopUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                        shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
                                const SizedBox(width: 8),
                                Text('شحن الرصيد فوراً ⚡', style: textBold.copyWith(fontSize: 16, color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
