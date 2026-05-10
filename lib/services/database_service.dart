import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ipo_model.dart';

/// Servei simple de persistència local
/// Usa SharedPreferences (funciona en web i desktop)
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  static const String _keyIPOs = 'ipos_data';
  static const String _keyLastUpdate = 'last_update';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> upsertIPOs(List<IPOModel> ipos) async {
    final prefs = await _prefs;
    // Carregar IPOs existents
    final existing = await getAllIPOs();
    
    for (final ipo in ipos) {
      final index = existing.indexWhere((e) => e.ticker == ipo.ticker);
      if (index >= 0) {
        existing[index] = ipo;
      } else {
        existing.add(ipo);
      }
    }
    
    final jsonList = existing.map((e) => e.toJson()).toList();
    await prefs.setString(_keyIPOs, jsonEncode(jsonList));
  }

  Future<List<IPOModel>> getAllIPOs() async {
    final prefs = await _prefs;
    final data = prefs.getString(_keyIPOs);
    if (data == null || data.isEmpty) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => IPOModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<IPOModel>> getPastIPOs() async {
    final all = await getAllIPOs();
    return all.where((ipo) => !ipo.isUpcoming).toList();
  }

  Future<List<IPOModel>> getUpcomingIPOs() async {
    final all = await getAllIPOs();
    return all.where((ipo) => ipo.isUpcoming).toList();
  }

  Future<List<IPOModel>> searchIPOs(String query) async {
    final all = await getAllIPOs();
    final q = query.toLowerCase();
    return all.where((ipo) => 
      ipo.ticker.toLowerCase().contains(q) ||
      ipo.companyName.toLowerCase().contains(q) ||
      (ipo.companyNameZH?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  Future<DateTime?> getLastUpdateDate() async {
    final prefs = await _prefs;
    final dateStr = prefs.getString(_keyLastUpdate);
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  Future<void> setLastUpdateDate(DateTime date) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastUpdate, date.toIso8601String());
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_keyIPOs);
    await prefs.remove(_keyLastUpdate);
  }
}
