import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ipo_model.dart';
import '../models/ipo_summary.dart';
import 'database_service.dart';
import 'ipo_api_service.dart';

/// Provider principal per gestionar l'estat de les IPOs
/// Gestiona el fetch, cache i actualització de dades
class IPOProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  final IPOApiService _apiService = IPOApiService();

  List<IPOModel> _allIPOs = [];
  List<IPOModel> _pastIPOs = [];
  List<IPOModel> _upcomingIPOs = [];
  IPOSummary? _summary;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastSyncDate;

  // Getters
  List<IPOModel> get allIPOs => _allIPOs;
  List<IPOModel> get pastIPOs => _pastIPOs;
  List<IPOModel> get upcomingIPOs => _upcomingIPOs;
  IPOSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastSyncDate => _lastSyncDate;

  /// Carrega les dades inicials (des de BD)
  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Carregar des de BD local
      _allIPOs = await _dbService.getAllIPOs();
      _pastIPOs = await _dbService.getPastIPOs();
      _upcomingIPOs = await _dbService.getUpcomingIPOs();
      _lastSyncDate = await _dbService.getLastUpdateDate();

      // Calcular resum
      _calculateSummary();

      // Si no hi ha dades, carregar demo
      if (_allIPOs.isEmpty) {
        await _loadDemoData();
      }
    } catch (e) {
      _error = 'Error carregant dades: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega dades de demostració (quan no hi ha connexió)
  Future<void> _loadDemoData() async {
    final demos = await _apiService.getDemoIPOs();
    await _dbService.upsertIPOs(demos);
    await _dbService.setLastUpdateDate(DateTime.now());
    _allIPOs = demos;
    _pastIPOs = demos.where((ipo) => !ipo.isUpcoming).toList();
    _upcomingIPOs = demos.where((ipo) => ipo.isUpcoming).toList();
    _calculateSummary();
    _lastSyncDate = DateTime.now();
    await _dbService.setLastUpdateDate(_lastSyncDate!);
  }

  /// Refresca les dades des de l'API
  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Enriquir IPOs passades amb dades de preus actuals
      final enrichedPast = await _apiService.enrichMultipleIPOs(_pastIPOs);
      await _dbService.upsertIPOs(enrichedPast);

      // Recarregar tot
      _allIPOs = await _dbService.getAllIPOs();
      _pastIPOs = await _dbService.getPastIPOs();
      _upcomingIPOs = await _dbService.getUpcomingIPOs();
      _lastSyncDate = DateTime.now();
    await _dbService.setLastUpdateDate(_lastSyncDate!);

      _calculateSummary();
    } catch (e) {
      _error = 'Error actualitzant dades: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Força un refresc complet des de l'API (inclou noves IPOs)
  Future<void> forceFullRefresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Netejar i recarregar
      // Nota: En producció, aquí es faria scraping de HKEX
      await _loadDemoData();
      _lastSyncDate = DateTime.now();
    await _dbService.setLastUpdateDate(_lastSyncDate!);
    } catch (e) {
      _error = 'Error en refresc complet: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Calcula el resum estadístic
  void _calculateSummary() {
    final past = _pastIPOs;
    if (past.isEmpty) {
      _summary = IPOSummary(
        totalIPOs: 0,
        upcomingIPOs: _upcomingIPOs.length,
        positiveFirstDay: 0,
        negativeFirstDay: 0,
        averageFirstDayReturn: 0,
        averageFirstWeekReturn: 0,
        totalFundsRaised: 0,
        bestPerformer: 0,
        worstPerformer: 0,
        ipoBySector: {},
      );
      return;
    }

    int positive = 0;
    int negative = 0;
    double totalFirstDayReturn = 0;
    double totalFirstWeekReturn = 0;
    int countReturns = 0;
    int countWeekReturns = 0;
    double totalFunds = 0;
    double bestPerf = double.negativeInfinity;
    double worstPerf = double.infinity;
    String? bestTicker;
    String? worstTicker;
    final bySector = <String, int>{};

    for (final ipo in past) {
      totalFunds += ipo.fundsRaised;

      // Per sector
      final sector = ipo.sector ?? 'Other';
      bySector[sector] = (bySector[sector] ?? 0) + 1;

      // Primer dia
      final day1 = ipo.firstDayReturn;
      if (day1 != null) {
        totalFirstDayReturn += day1;
        countReturns++;
        if (day1 >= 0) {
          positive++;
        } else {
          negative++;
        }
      }

      // Primera setmana
      final week1 = ipo.firstWeekReturn;
      if (week1 != null) {
        totalFirstWeekReturn += week1;
        countWeekReturns++;
      }

      // Millor/pitjor performer (basat en retorn total)
      final total = ipo.totalReturn;
      if (total != null) {
        if (total > bestPerf) {
          bestPerf = total;
          bestTicker = ipo.ticker;
        }
        if (total < worstPerf) {
          worstPerf = total;
          worstTicker = ipo.ticker;
        }
      }
    }

    _summary = IPOSummary(
      totalIPOs: past.length,
      upcomingIPOs: _upcomingIPOs.length,
      positiveFirstDay: positive,
      negativeFirstDay: negative,
      averageFirstDayReturn:
          countReturns > 0 ? totalFirstDayReturn / countReturns : 0,
      averageFirstWeekReturn:
          countWeekReturns > 0 ? totalFirstWeekReturn / countWeekReturns : 0,
      totalFundsRaised: totalFunds,
      bestPerformer: bestPerf != double.negativeInfinity ? bestPerf : 0,
      bestPerformerTicker: bestTicker,
      worstPerformer: worstPerf != double.infinity ? worstPerf : 0,
      worstPerformerTicker: worstTicker,
      ipoBySector: bySector,
    );
  }

  /// Ordena les IPOs per un criteri
  void sortIPOs(String criterion) {
    switch (criterion) {
      case 'date_desc':
        _pastIPOs.sort((a, b) => b.listingDate.compareTo(a.listingDate));
        break;
      case 'date_asc':
        _pastIPOs.sort((a, b) => a.listingDate.compareTo(b.listingDate));
        break;
      case 'return_desc':
        _pastIPOs.sort((a, b) =>
            (b.firstDayReturn ?? 0).compareTo(a.firstDayReturn ?? 0));
        break;
      case 'return_asc':
        _pastIPOs.sort((a, b) =>
            (a.firstDayReturn ?? 0).compareTo(b.firstDayReturn ?? 0));
        break;
      case 'funds_desc':
        _pastIPOs.sort(
            (a, b) => b.fundsRaised.compareTo(a.fundsRaised));
        break;
      case 'name_asc':
        _pastIPOs.sort((a, b) => a.companyName.compareTo(b.companyName));
        break;
    }
    notifyListeners();
  }

  /// Filtra IPOs per sector
  void filterBySector(String? sector) {
    // TODO: Implementar filtre per sector
    notifyListeners();
  }

  /// Cerca IPOs
  Future<List<IPOModel>> search(String query) async {
    if (query.isEmpty) return _allIPOs;
    return _dbService.searchIPOs(query);
  }
}


