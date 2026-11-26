class AppFormatters {
  AppFormatters._();

  static const List<String> _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// تنسيق المبالغ بالريال اليمني مع فواصل الآلاف
  static String formatCurrency(num amount) {
    final intValue = amount.round();
    final str = intValue.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i;
      buffer.write(str[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${buffer.toString()} ر.ي';
  }

  /// تنسيق التاريخ بصيغة عربية واضحة
  static String formatDate(DateTime date) {
    final monthName = _arabicMonths[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }

  /// تنسيق التاريخ والوقت
  static String formatDateTime(DateTime date) {
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'م' : 'ص';
    return '${formatDate(date)} • $hour12:$minute $period';
  }
}