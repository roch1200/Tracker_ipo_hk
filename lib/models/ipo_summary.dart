/// Resum estadístic de totes les IPOs
class IPOSummary {
  final int totalIPOs;
  final int upcomingIPOs;
  final int positiveFirstDay;
  final int negativeFirstDay;
  final double averageFirstDayReturn;
  final double averageFirstWeekReturn;
  final double totalFundsRaised;
  final double bestPerformer;
  final String? bestPerformerTicker;
  final double worstPerformer;
  final String? worstPerformerTicker;
  final Map<String, int> ipoBySector;
  final DateTime lastUpdated;

  IPOSummary({
    required this.totalIPOs,
    required this.upcomingIPOs,
    required this.positiveFirstDay,
    required this.negativeFirstDay,
    required this.averageFirstDayReturn,
    required this.averageFirstWeekReturn,
    required this.totalFundsRaised,
    required this.bestPerformer,
    this.bestPerformerTicker,
    required this.worstPerformer,
    this.worstPerformerTicker,
    required this.ipoBySector,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
}
