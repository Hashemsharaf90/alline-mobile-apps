abstract final class FinancialInput {
  static double? amount(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final normalized = value.trim().split('').map((c) {
      final a = arabic.indexOf(c), p = persian.indexOf(c);
      return a >= 0
          ? '$a'
          : p >= 0
              ? '$p'
              : c == '٫'
                  ? '.'
                  : c;
    }).join();
    final amount = double.tryParse(normalized);
    return amount != null && amount.isFinite ? amount : null;
  }

  static bool canWithdraw(String value, double? balance) {
    final parsed = amount(value);
    return parsed != null &&
        parsed > 0 &&
        balance != null &&
        balance.isFinite &&
        parsed <= balance;
  }

  static String maskAccount(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.length <= 4
        ? '••••'
        : '•••• ${value.substring(value.length - 4)}';
  }
}
