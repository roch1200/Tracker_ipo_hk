import 'package:intl/intl.dart';

/// Utilitats de format per a valors financers i dates
class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    symbol: 'HK\$',
    decimalDigits: 2,
    locale: 'en_HK',
  );

  static final _compactCurrency = NumberFormat.compact(
    locale: 'en_HK',
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formata un valor en HKD
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Formata un valor gran en format compacte (ex: HK\$1.2B)
  static String formatCompactCurrency(double value) {
    if (value >= 1000000000) {
      return 'HK\$${_compactCurrency.format(value)}';
    } else if (value >= 1000000) {
      return 'HK\$${_compactCurrency.format(value)}';
    }
    return formatCurrency(value);
  }

  /// Formata un percentatge de rendibilitat
  static String formatReturn(double? value) {
    if (value == null) return 'N/A';
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  /// Formata una data
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formata data i hora
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Retorna el color basat en el valor de rendibilitat
  static String returnColor(double? value) {
    if (value == null) return 'grey';
    if (value > 20) return 'deepGreen';
    if (value > 5) return 'green';
    if (value >= 0) return 'lightGreen';
    if (value >= -5) return 'lightRed';
    if (value >= -20) return 'red';
    return 'deepRed';
  }

  /// Retorna un emoji/icona basat en el rendiment
  static String returnEmoji(double? value) {
    if (value == null) return '❓';
    if (value > 50) return '🚀';
    if (value > 20) return '📈';
    if (value > 5) return '👍';
    if (value >= 0) return '➡️';
    if (value >= -10) return '👎';
    if (value >= -30) return '📉';
    return '💀';
  }

  /// Retorna el nom humà del període de rendibilitat
  static String periodName(String period) {
    switch (period) {
      case 'firstDay':
        return '1r Dia';
      case 'secondDay':
        return '2n Dia';
      case 'firstWeek':
        return '1a Setmana';
      case 'secondWeek':
        return '2a Setmana';
      case 'total':
        return 'Total';
      default:
        return period;
    }
  }

  /// Formata un número gran amb separadors
  static String formatLargeNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(2);
  }
}

