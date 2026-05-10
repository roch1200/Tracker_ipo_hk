/// Model principal per representar una IPO del mercat de Hong Kong
class IPOModel {
  final String? id;
  final String ticker;
  final String companyName;
  final String? companyNameZH; // Nom en xinès
  final String exchange; // Main Board o GEM
  final DateTime listingDate;
  final double ipoPrice; // Preu de sortida HKD
  final double? firstDayClose;
  final double? secondDayClose;
  final double? firstWeekClose;
  final double? secondWeekClose;
  final double? currentPrice;
  final String? sector;
  final double fundsRaised; // Milions HKD
  final bool isUpcoming; // true = propera IPO, false = ja ha sortit
  final DateTime lastUpdated;

  IPOModel({
    this.id,
    required this.ticker,
    required this.companyName,
    this.companyNameZH,
    required this.exchange,
    required this.listingDate,
    required this.ipoPrice,
    this.firstDayClose,
    this.secondDayClose,
    this.firstWeekClose,
    this.secondWeekClose,
    this.currentPrice,
    this.sector,
    required this.fundsRaised,
    this.isUpcoming = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // --- Càlculs de rendibilitat ---

  /// Rendibilitat del primer dia (%)
  double? get firstDayReturn {
    if (firstDayClose == null || ipoPrice == 0) return null;
    return ((firstDayClose! - ipoPrice) / ipoPrice) * 100;
  }

  /// Rendibilitat del segon dia (%)
  double? get secondDayReturn {
    if (secondDayClose == null || ipoPrice == 0) return null;
    return ((secondDayClose! - ipoPrice) / ipoPrice) * 100;
  }

  /// Rendibilitat de la primera setmana (%)
  double? get firstWeekReturn {
    if (firstWeekClose == null || ipoPrice == 0) return null;
    return ((firstWeekClose! - ipoPrice) / ipoPrice) * 100;
  }

  /// Rendibilitat de la segona setmana (%)
  double? get secondWeekReturn {
    if (secondWeekClose == null || ipoPrice == 0) return null;
    return ((secondWeekClose! - ipoPrice) / ipoPrice) * 100;
  }

  /// Rendibilitat des de l'IPO fins ara (%)
  double? get totalReturn {
    if (currentPrice == null || ipoPrice == 0) return null;
    return ((currentPrice! - ipoPrice) / ipoPrice) * 100;
  }

  /// Retorna true si la IPO té dades completes de rendibilitat
  bool get hasCompleteReturns {
    return firstDayClose != null &&
        secondDayClose != null &&
        firstWeekClose != null &&
        secondWeekClose != null;
  }

  /// Retorna el millor retorn entre tots els períodes
  double? get bestReturn {
    final returns = [
      firstDayReturn,
      secondDayReturn,
      firstWeekReturn,
      secondWeekReturn,
      totalReturn,
    ].where((r) => r != null);
    if (returns.isEmpty) return null;
    return returns.cast<double>().reduce((a, b) => a > b ? a : b);
  }

  /// Retorna el pitjor retorn entre tots els períodes
  double? get worstReturn {
    final returns = [
      firstDayReturn,
      secondDayReturn,
      firstWeekReturn,
      secondWeekReturn,
      totalReturn,
    ].where((r) => r != null);
    if (returns.isEmpty) return null;
    return returns.cast<double>().reduce((a, b) => a < b ? a : b);
  }

  /// Nombre de dies des de la sortida
  int get daysSinceListing {
    return DateTime.now().difference(listingDate).inDays;
  }

  // --- Serialització JSON ---

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticker': ticker,
        'companyName': companyName,
        'companyNameZH': companyNameZH,
        'exchange': exchange,
        'listingDate': listingDate.toIso8601String(),
        'ipoPrice': ipoPrice,
        'firstDayClose': firstDayClose,
        'secondDayClose': secondDayClose,
        'firstWeekClose': firstWeekClose,
        'secondWeekClose': secondWeekClose,
        'currentPrice': currentPrice,
        'sector': sector,
        'fundsRaised': fundsRaised,
        'isUpcoming': isUpcoming,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory IPOModel.fromJson(Map<String, dynamic> json) => IPOModel(
        id: json['id']?.toString(),
        ticker: json['ticker'] as String,
        companyName: json['companyName'] as String,
        companyNameZH: json['companyNameZH'] as String?,
        exchange: json['exchange'] as String? ?? 'Main Board',
        listingDate: DateTime.parse(json['listingDate'] as String),
        ipoPrice: (json['ipoPrice'] as num).toDouble(),
        firstDayClose: (json['firstDayClose'] as num?)?.toDouble(),
        secondDayClose: (json['secondDayClose'] as num?)?.toDouble(),
        firstWeekClose: (json['firstWeekClose'] as num?)?.toDouble(),
        secondWeekClose: (json['secondWeekClose'] as num?)?.toDouble(),
        currentPrice: (json['currentPrice'] as num?)?.toDouble(),
        sector: json['sector'] as String?,
        fundsRaised: (json['fundsRaised'] as num).toDouble(),
        isUpcoming: json['isUpcoming'] as bool? ?? false,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'] as String)
            : DateTime.now(),
      );

  @override
  String toString() =>
      '$ticker - $companyName (${listingDate.toIso8601String().substring(0, 10)})';
}
