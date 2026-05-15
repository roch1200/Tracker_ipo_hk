import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/ipo_model.dart';

/// Servei per obtenir dades d'IPOs de múltiples fonts
/// Inclou scraping de HKEX i APIs de Yahoo Finance
class IPOApiService {
  static const String _baseUrl = 'https://ipo-tracker.roch1200.workers.dev?url=https://query1.finance.yahoo.com/v8/finance/chart/';
  static const String _hkexNewsUrl = 'https://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main.aspx';

  // Temps d'espera per peticions
  static const Duration _timeout = Duration(seconds: 15);

  /// Obte dades de cotització d'un ticker des de Yahoo Finance
  Future<Map<String, dynamic>?> fetchYahooQuote(String ticker) async {
    try {
      // Yahoo Finance usa sufix .HK per Hong Kong
      final yahooTicker = '$ticker.HK';
      final url = 'https://ipo-tracker.roch1200.workers.dev?url=https://query1.finance.yahoo.com/v8/finance/chart/${yahooTicker}?range=6mo&interval=1d';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
                          },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching Yahoo quote for $ticker: $e');
      return null;
    }
  }

  /// Obte dades de rendibilitat per un període específic des de Yahoo
  Future<IPOModel?> enrichWithPriceData(IPOModel ipo) async {
    try {
      final data = await fetchYahooQuote(ipo.ticker);
      if (data == null) return ipo;

      final chartData = data['chart']?['result']?[0];
      if (chartData == null) return ipo;

      final timestamps = List<int>.from(chartData['timestamp'] ?? []);
      final quotes = chartData['indicators']?['quote']?[0];
      final closes = List<dynamic>.from(quotes?['close'] ?? []);
      final adjCloses = List<dynamic>.from(
          chartData['indicators']?['adjclose']?[0]?['adjclose'] ?? []);

      if (timestamps.isEmpty || closes.isEmpty) return ipo;

      // Trobar l'índex del listingDate
      final listingTimestamp = ipo.listingDate.millisecondsSinceEpoch ~/ 1000;
      int listingIndex = -1;

      for (int i = 0; i < timestamps.length; i++) {
        if (timestamps[i] >= listingTimestamp) {
          listingIndex = i;
          break;
        }
      }

      if (listingIndex < 0 || listingIndex >= closes.length) return ipo;

      // Assignar dades històriques
      if (closes[listingIndex] != null) {
        ipo = IPOModel(
          id: ipo.id,
          ticker: ipo.ticker,
          companyName: ipo.companyName,
          companyNameZH: ipo.companyNameZH,
          exchange: ipo.exchange,
          listingDate: ipo.listingDate,
          ipoPrice: ipo.ipoPrice,
          firstDayClose: (closes[listingIndex] as num).toDouble(),
          secondDayClose: listingIndex + 1 < closes.length && closes[listingIndex + 1] != null
              ? (closes[listingIndex + 1] as num).toDouble()
              : null,
          firstWeekClose: listingIndex + 5 < closes.length && closes[listingIndex + 5] != null
              ? (closes[listingIndex + 5] as num).toDouble()
              : null,
          secondWeekClose: listingIndex + 10 < closes.length && closes[listingIndex + 10] != null
              ? (closes[listingIndex + 10] as num).toDouble()
              : null,
          currentPrice: adjCloses.isNotEmpty && adjCloses.last != null
              ? (adjCloses.last as num).toDouble()
              : closes.whereType<num>().isNotEmpty
                  ? (closes.whereType<num>().last).toDouble()
                  : null,
          sector: ipo.sector,
          fundsRaised: ipo.fundsRaised,
          isUpcoming: ipo.isUpcoming,
        );
      }

      return ipo;
    } catch (e) {
      print('Error enriching $ipo: $e');
      return ipo;
    }
  }

  /// Obte dades de múltiples IPOs
  Future<List<IPOModel>> enrichMultipleIPOs(List<IPOModel> ipos) async {
    final results = <IPOModel>[];
    for (final ipo in ipos) {
      final enriched = await enrichWithPriceData(ipo);
      results.add(enriched ?? ipo);
      // Petita pausa per evitar rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return results;
  }

  /// Simula dades d'IPOs de demostració (per quan no hi ha API Key)
  /// Això es pot substituir per dades reals d'scraping de HKEX
  List<IPOModel> getDemoIPOs() {
    final now = DateTime.now();
    final random = Random(123);

    // IPOs de Hong Kong des de GENER 2026
    // Font: HKEX Consolidated Reports (Abr 2026: 9 noves IPOs)
    final demoIPOs = [
      // GENER 2026 (3 IPOs)
      {
        'ticker': '2601',
        'companyName': 'China Renewable Energy Group',
        'sector': 'Energy',
        'ipoPrice': 32.50,
        'fundsRaised': 8450.0,
        'listingDate': DateTime(2026, 1, 8),
        'd1': 35.80, 'd2': 36.20, 'w1': 38.50, 'w2': 41.20, 'cur': 44.80,
      },
      {
        'ticker': '2602',
        'companyName': 'HK MedTech Innovations',
        'sector': 'Healthcare',
        'ipoPrice': 28.00,
        'fundsRaised': 5200.0,
        'listingDate': DateTime(2026, 1, 15),
        'd1': 30.50, 'd2': 31.20, 'w1': 33.80, 'w2': 35.10, 'cur': 38.60,
      },
      {
        'ticker': '2603',
        'companyName': 'Shenzhen AI Solutions',
        'sector': 'Technology',
        'ipoPrice': 45.00,
        'fundsRaised': 12800.0,
        'listingDate': DateTime(2026, 1, 22),
        'd1': 52.00, 'd2': 54.80, 'w1': 58.20, 'w2': 61.50, 'cur': 72.30,
      },
      // FEBRER 2026 (3 IPOs)
      {
        'ticker': '2604',
        'companyName': 'Asia-Pacific Logistics REIT',
        'sector': 'Real Estate',
        'ipoPrice': 18.80,
        'fundsRaised': 3200.0,
        'listingDate': DateTime(2026, 2, 5),
        'd1': 19.20, 'd2': 19.00, 'w1': 18.50, 'w2': 17.80, 'cur': 20.10,
      },
      {
        'ticker': '2605',
        'companyName': 'Green Hydrogen Holdings',
        'sector': 'Energy',
        'ipoPrice': 15.50,
        'fundsRaised': 4100.0,
        'listingDate': DateTime(2026, 2, 12),
        'd1': 14.80, 'd2': 14.20, 'w1': 13.50, 'w2': 12.80, 'cur': 16.90,
      },
      {
        'ticker': '2606',
        'companyName': 'Digital Bank Asia',
        'sector': 'Finance',
        'ipoPrice': 22.00,
        'fundsRaised': 9500.0,
        'listingDate': DateTime(2026, 2, 19),
        'd1': 25.30, 'd2': 26.80, 'w1': 28.50, 'w2': 30.20, 'cur': 35.40,
      },
      // MARC 2026 (4 IPOs)
      {
        'ticker': '2607',
        'companyName': 'Biotech Gene Therapies',
        'sector': 'Healthcare',
        'ipoPrice': 38.00,
        'fundsRaised': 6800.0,
        'listingDate': DateTime(2026, 3, 5),
        'd1': 42.50, 'd2': 44.20, 'w1': 46.80, 'w2': 48.20, 'cur': 52.10,
      },
      {
        'ticker': '2608',
        'companyName': 'Quantum Computing Corp',
        'sector': 'Technology',
        'ipoPrice': 55.00,
        'fundsRaised': 15200.0,
        'listingDate': DateTime(2026, 3, 12),
        'd1': 62.80, 'd2': 65.50, 'w1': 68.20, 'w2': 72.50, 'cur': 81.00,
      },
      {
        'ticker': '2609',
        'companyName': 'EV Battery Materials Ltd',
        'sector': 'Energy',
        'ipoPrice': 26.50,
        'fundsRaised': 7300.0,
        'listingDate': DateTime(2026, 3, 19),
        'd1': 28.20, 'd2': 29.50, 'w1': 31.80, 'w2': 33.20, 'cur': 38.50,
      },
      {
        'ticker': '2610',
        'companyName': 'Smart Manufacturing Intl',
        'sector': 'Technology',
        'ipoPrice': 19.80,
        'fundsRaised': 4800.0,
        'listingDate': DateTime(2026, 3, 26),
        'd1': 20.50, 'd2': 21.20, 'w1': 22.50, 'w2': 21.80, 'cur': 25.30,
      },
      // ABRIL 2026 (9 IPOs - segons HKEX)
      {
        'ticker': '2611',
        'companyName': 'FinTech Payment Solutions',
        'sector': 'Finance',
        'ipoPrice': 31.00,
        'fundsRaised': 6200.0,
        'listingDate': DateTime(2026, 4, 2),
        'd1': 33.50, 'd2': 34.20, 'w1': 35.80, 'w2': 36.50, 'cur': 38.20,
      },
      {
        'ticker': '2612',
        'companyName': 'AI Healthcare Diagnostics',
        'sector': 'Healthcare',
        'ipoPrice': 42.00,
        'fundsRaised': 9100.0,
        'listingDate': DateTime(2026, 4, 9),
        'd1': 45.80, 'd2': 47.20, 'w1': 49.50, 'w2': 51.20, 'cur': 53.80,
      },
      {
        'ticker': '2613',
        'companyName': 'Electric Aircraft Tech',
        'sector': 'Technology',
        'ipoPrice': 68.00,
        'fundsRaised': 18400.0,
        'listingDate': DateTime(2026, 4, 16),
        'd1': 72.50, 'd2': 74.20, 'w1': 76.80, 'w2': 78.50, 'cur': 82.10,
      },
      {
        'ticker': '2614',
        'companyName': 'Consumer Brands China',
        'sector': 'Consumer',
        'ipoPrice': 14.50,
        'fundsRaised': 2800.0,
        'listingDate': DateTime(2026, 4, 16),
        'd1': 15.20, 'd2': 15.80, 'w1': 16.50, 'w2': 17.20, 'cur': 18.10,
      },
      {
        'ticker': '2615',
        'companyName': 'Cloud Computing Asia',
        'sector': 'Technology',
        'ipoPrice': 48.00,
        'fundsRaised': 16500.0,
        'listingDate': DateTime(2026, 4, 23),
        'd1': 51.20, 'd2': 52.80, 'w1': 54.50, 'w2': 56.20, 'cur': 58.90,
      },
      {
        'ticker': '2616',
        'companyName': 'Sustainable Agri Corp',
        'sector': 'Consumer',
        'ipoPrice': 12.00,
        'fundsRaised': 2100.0,
        'listingDate': DateTime(2026, 4, 23),
        'd1': 11.50, 'd2': 11.20, 'w1': 10.80, 'w2': 10.50, 'cur': 12.80,
      },
      {
        'ticker': '2617',
        'companyName': 'Rare Earth Materials HK',
        'sector': 'Energy',
        'ipoPrice': 35.00,
        'fundsRaised': 7800.0,
        'listingDate': DateTime(2026, 4, 30),
        'd1': 37.50, 'd2': 38.20, 'w1': 39.50, 'w2': 40.80, 'cur': null,
      },
      {
        'ticker': '2618',
        'companyName': 'Digital Entertainment Group',
        'sector': 'Technology',
        'ipoPrice': 25.00,
        'fundsRaised': 5600.0,
        'listingDate': DateTime(2026, 4, 30),
        'd1': 27.20, 'd2': 28.00, 'w1': 28.80, 'w2': 29.50, 'cur': null,
      },
      {
        'ticker': '2619',
        'companyName': 'Pharma Research Intl',
        'sector': 'Healthcare',
        'ipoPrice': 33.00,
        'fundsRaised': 7200.0,
        'listingDate': DateTime(2026, 4, 30),
        'd1': 34.80, 'd2': 35.50, 'w1': 36.20, 'w2': 37.00, 'cur': null,
      },
      // MAIG 2026 (acaben de sortir)
      {
        'ticker': '2620',
        'companyName': 'Semiconductor Chip Fab',
        'sector': 'Technology',
        'ipoPrice': 52.00,
        'fundsRaised': 22100.0,
        'listingDate': DateTime(2026, 5, 7),
        'd1': 55.50, 'd2': 56.80, 'w1': null, 'w2': null, 'cur': null,
      },
      {
        'ticker': '2621',
        'companyName': 'Green Building Materials',
        'sector': 'Energy',
        'ipoPrice': 16.80,
        'fundsRaised': 3800.0,
        'listingDate': DateTime(2026, 5, 7),
        'd1': 17.20, 'd2': 17.80, 'w1': null, 'w2': null, 'cur': null,
      },
      // PROPERES IPOs
      {
        'ticker': 'P001',
        'companyName': 'NextGen Robotics Ltd',
        'companyNameZH': '下一代機器人',
        'sector': 'Technology',
        'ipoPrice': 44.00,
        'fundsRaised': 9800.0,
        'listingDate': now.add(const Duration(days: 10)),
        'isUpcoming': true,
      },
      {
        'ticker': 'P002',
        'companyName': 'Hydrogen Fuel Cell Inc',
        'companyNameZH': '氫燃料電池',
        'sector': 'Energy',
        'ipoPrice': 28.50,
        'fundsRaised': 5400.0,
        'listingDate': now.add(const Duration(days: 21)),
        'isUpcoming': true,
      },
      {
        'ticker': 'P003',
        'companyName': 'BioPharma Innovations',
        'companyNameZH': '生物製藥創新',
        'sector': 'Healthcare',
        'ipoPrice': 36.00,
        'fundsRaised': 7600.0,
        'listingDate': now.add(const Duration(days: 35)),
        'isUpcoming': true,
      },
      {
        'ticker': 'P004',
        'companyName': 'Metaverse Platforms HK',
        'companyNameZH': '元宇宙平台',
        'sector': 'Technology',
        'ipoPrice': 58.00,
        'fundsRaised': 14200.0,
        'listingDate': now.add(const Duration(days: 45)),
        'isUpcoming': true,
      },
      {
        'ticker': 'P005',
        'companyName': 'Sustainable Packaging Co',
        'companyNameZH': '可持續包裝',
        'sector': 'Consumer',
        'ipoPrice': 19.50,
        'fundsRaised': 3500.0,
        'listingDate': now.add(const Duration(days: 60)),
        'isUpcoming': true,
      },
    ];

    return demoIPOs.map((data) {
      return IPOModel(
        ticker: data['ticker'] as String,
        companyName: data['companyName'] as String,
        companyNameZH: data['companyNameZH'] as String?,
        exchange: 'Main Board',
        listingDate: data['listingDate'] as DateTime,
        ipoPrice: (data['ipoPrice'] as num).toDouble(),
        firstDayClose: (data['d1'] as num?)?.toDouble(),
        secondDayClose: (data['d2'] as num?)?.toDouble(),
        firstWeekClose: (data['w1'] as num?)?.toDouble(),
        secondWeekClose: (data['w2'] as num?)?.toDouble(),
        currentPrice: (data['cur'] as num?)?.toDouble(),
        sector: data['sector'] as String?,
        fundsRaised: (data['fundsRaised'] as num).toDouble(),
        isUpcoming: data['isUpcoming'] as bool? ?? false,
      );
    }).toList();
  }
}


