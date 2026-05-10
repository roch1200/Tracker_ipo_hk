import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ipo_model.dart';

/// Servei per fer scraping de la pàgina d'IPOs de HKEX
/// i altres fonts de dades específiques de Hong Kong
class HKEXScraperService {
  static const String _hkexIpoUrl =
      'https://www.hkex.com.hk/Join-Our-Market/IPO/Listing-with-HKEX?sc_lang=en';
  static const String _hkexMonthlyUrl =
      'https://www.hkex.com.hk/Market-Data/Statistics/Consolidated-Reports?sc_lang=en';
  static const String _hkexNewsUrl =
      'https://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main.aspx';

  /// Intenta obtenir la llista d'IPOs recents des de HKEX
  /// Nota: Com que HKEX no té una API pública, fem scraping
  Future<List<Map<String, dynamic>>> fetchRecentListings() async {
    try {
      final response = await http.get(
        Uri.parse(_hkexIpoUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'text/html,application/xhtml+xml',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return [];

      // Parsejar el HTML per trobar les taules de dades d'IPOs
      final html = response.body;
      return _parseIPOListings(html);
    } catch (e) {
      print('Error scraping HKEX listings: $e');
      return [];
    }
  }

  /// Parseja l'HTML per extreure informació d'IPOs
  List<Map<String, dynamic>> _parseIPOListings(String html) {
    final listings = <Map<String, dynamic>>[];

    try {
      // Buscar patrons de dades d'IPOs al HTML
      // Nota: Això és un parser bàsic - es pot millorar amb html parser
      final regExp = RegExp(
        r'<td[^>]*>(.*?)</td>',
        dotAll: true,
        caseSensitive: false,
      );
      final matches = regExp.allMatches(html);

      // Processar les dades trobades
      for (final match in matches) {
        final content = match.group(1)?.trim() ?? '';
        if (content.contains('IPO') || content.contains('Listing')) {
          // TODO: Implementar parsing més detallat
          // Per ara retornem buit - la font principal serà Yahoo Finance
        }
      }
    } catch (e) {
      print('Error parsing HKEX HTML: $e');
    }

    return listings;
  }

  /// Obte dades mensuals d'IPOs des del report consolidat
  Future<Map<String, dynamic>> fetchMonthlyStats() async {
    try {
      final response = await http.get(
        Uri.parse(_hkexMonthlyUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return {'error': 'Failed to fetch HKEX stats'};
      }

      final html = response.body;
      return _parseMonthlyStats(html);
    } catch (e) {
      print('Error fetching HKEX monthly stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Parseja l'HTML del report mensual
  Map<String, dynamic> _parseMonthlyStats(String html) {
    final stats = <String, dynamic>{};

    try {
      // Buscar "No. of newly listed companies"
      final iposRegExp = RegExp(
        r'No\. of newly listed companies.*?(\d+)',
        dotAll: true,
        caseSensitive: false,
      );
      final iposMatch = iposRegExp.firstMatch(html);
      if (iposMatch != null) {
        stats['newListings'] = int.tryParse(iposMatch.group(1) ?? '0') ?? 0;
      }

      // Buscar "Total market capitalisation"
      final capRegExp = RegExp(
        r'Total market capitalisation.*?([\d,]+\.?\d*)',
        dotAll: true,
        caseSensitive: false,
      );
      final capMatch = capRegExp.firstMatch(html);
      if (capMatch != null) {
        stats['marketCap'] = capMatch.group(1)?.replaceAll(',', '') ?? '0';
      }

      // Buscar número total d'empreses llistades
      final companiesRegExp = RegExp(
        r'No\. of listed companies.*?(\d[\d,]*\d)',
        dotAll: true,
        caseSensitive: false,
      );
      final companiesMatch = companiesRegExp.firstMatch(html);
      if (companiesMatch != null) {
        stats['totalCompanies'] =
            int.tryParse(companiesMatch.group(1)?.replaceAll(',', '') ?? '0') ??
                0;
      }
    } catch (e) {
      print('Error parsing HKEX stats: $e');
    }

    return stats;
  }

  /// Obte la llista de "New Listing Applications" (properes IPOs)
  Future<List<Map<String, dynamic>>> fetchUpcomingApplications() async {
    // Aquesta funcionalitat requeriria accés a l'API interna de HKEX
    // o scraping avançat del portal d'aplicacions
    // De moment retornem buit i usem Yahoo Finance com a font principal
    return [];
  }

  /// Converteix els resultats d'scraping a models IPO
  List<IPOModel> convertToIPOModels(List<Map<String, dynamic>> rawData) {
    // TODO: Implementar conversió quan el scraping estigui complet
    return [];
  }
}
