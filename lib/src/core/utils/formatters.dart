import 'package:intl/intl.dart';

final _ruLocale = Intl.defaultLocale ?? 'ru_RU';

String formatCurrency(double amount, String currencyCode) {
  try {
    final formatter = NumberFormat.simpleCurrency(
      name: currencyCode.toUpperCase(),
      locale: _ruLocale,
    );
    return formatter.format(amount);
  } catch (_) {
    final formatter = NumberFormat.currency(locale: _ruLocale, symbol: currencyCode);
    formatter.maximumFractionDigits = 2;
    return formatter.format(amount);
  }
}

String formatPercent(double value) {
  final formatter = NumberFormat.decimalPercentPattern(
    locale: _ruLocale,
    decimalDigits: 2,
  );
  return formatter.format(value / 100);
}

String formatSignedPercent(double value) {
  final formatted = NumberFormat('+#0.00;-#0.00', _ruLocale).format(value);
  return '$formatted%';
}

String formatVolume(double value) {
  final formatter = NumberFormat.decimalPattern(_ruLocale);
  formatter.maximumFractionDigits = 0;
  return formatter.format(value);
}
