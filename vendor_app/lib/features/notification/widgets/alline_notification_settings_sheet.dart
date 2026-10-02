import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineNotificationSettingsSheet extends StatefulWidget {
  const AllineNotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AllineNotificationSettingsSheet(),
    );
  }

  @override
  State<AllineNotificationSettingsSheet> createState() =>
      _AllineNotificationSettingsSheetState();
}

class _AllineNotificationSettingsSheetState
    extends State<AllineNotificationSettingsSheet> {
  bool _ordersEnabled = true;
  bool _stockEnabled = true;
  bool _financeEnabled = true;
  bool _systemEnabled = true;
  bool _soundEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ordersEnabled = prefs.getBool('notif_orders_enabled') ?? true;
      _stockEnabled = prefs.getBool('notif_stock_enabled') ?? true;
      _financeEnabled = prefs.getBool('notif_finance_enabled') ?? true;
      _systemEnabled = prefs.getBool('notif_system_enabled') ?? true;
      _soundEnabled = prefs.getBool('notif_sound_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value, Function(bool) update) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      update(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AllineColors.darkCard : AllineColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AllineColors.darkBorder : AllineColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AllineColors.darkBorder
                      : AllineColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AllineColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: AllineColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'إعدادات الإشعارات',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AllineColors.darkText : AllineColors.navyText,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'تحكم في أنواع التنبيهات التي ترغب باستلامها فوراً',
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
              ),
            ),
            const SizedBox(height: 18),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildSettingTile(
                title: 'تنبيهات الطلبات الجديدة',
                subtitle: 'إشعار فوري عند قيام أي عميل بطلب جديد من متجرك',
                icon: Icons.shopping_bag_outlined,
                color: AllineColors.primary,
                value: _ordersEnabled,
                isDark: isDark,
                onChanged: (val) => _updateSetting(
                  'notif_orders_enabled',
                  val,
                  (v) => _ordersEnabled = v,
                ),
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                title: 'تنبيهات المخزون والمنتجات',
                subtitle: 'تنبيهات عند اقتراب نفاد كمية أي منتج أو وصول طلبات توفير',
                icon: Icons.inventory_2_outlined,
                color: AllineColors.orange,
                value: _stockEnabled,
                isDark: isDark,
                onChanged: (val) => _updateSetting(
                  'notif_stock_enabled',
                  val,
                  (v) => _stockEnabled = v,
                ),
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                title: 'التحديثات والمدفوعات المالية',
                subtitle: 'إشعارات سحب الأرباح وإيداع المستحقات والتحويلات',
                icon: Icons.account_balance_wallet_outlined,
                color: AllineColors.success,
                value: _financeEnabled,
                isDark: isDark,
                onChanged: (val) => _updateSetting(
                  'notif_finance_enabled',
                  val,
                  (v) => _financeEnabled = v,
                ),
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                title: 'إعلانات وتحديثات النظام',
                subtitle: 'تحديثات المنصة الهامة والقرارات الإدارية الخاصة بالبائعين',
                icon: Icons.notifications_active_outlined,
                color: AllineColors.coolGray,
                value: _systemEnabled,
                isDark: isDark,
                onChanged: (val) => _updateSetting(
                  'notif_system_enabled',
                  val,
                  (v) => _systemEnabled = v,
                ),
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                title: 'نغمة التنبيه والاهتزاز',
                subtitle: 'تشغيل صوت مميز مع الإشعار لضمان سرعة الاستجابة',
                icon: Icons.volume_up_outlined,
                color: const Color(0xFF6366F1),
                value: _soundEnabled,
                isDark: isDark,
                onChanged: (val) => _updateSetting(
                  'notif_sound_enabled',
                  val,
                  (v) => _soundEnabled = v,
                ),
              ),
            ],
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllineColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'حفظ وإغلاق',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 16,
      thickness: 1,
      color: isDark ? AllineColors.darkBorder : AllineColors.border.withValues(alpha: 0.6),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AllineColors.darkText : AllineColors.navyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AllineColors.darkTextSub : AllineColors.coolGray,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: AllineColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
