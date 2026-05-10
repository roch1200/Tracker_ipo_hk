import 'package:flutter/material.dart';

/// Constants de l'aplicació
class AppConstants {
  // Configuració
  static const String appName = 'HKEX IPO Tracker';
  static const String appVersion = '1.0.0';
  static const int minIPOsForStats = 3;
  static const Duration refreshInterval = Duration(hours: 6);
  static const int maxDemoIPOs = 50;

  // Colors
  static const Color primaryColor = Color(0xFF1A237E); // Blau fosc HKEX
  static const Color secondaryColor = Color(0xFFC62828); // Vermell HKEX
  static const Color positiveColor = Color(0xFF2E7D32); // Verd
  static const Color negativeColor = Color(0xFFC62828); // Vermell
  static const Color neutralColor = Color(0xFF757575); // Gris
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color accentColor = Color(0xFF1565C0);

  // Mides
  static const double cardBorderRadius = 12.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  // Temes
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardBorderRadius),
          ),
        ),
      );

  // Missatges
  static const String errorNetwork = 'Error de connexió de xarxa';
  static const String errorDataLoad = 'Error carregant dades';
  static const String noDataMessage = 'No hi ha dades disponibles';
  static const String refreshSuccess = 'Dades actualitzades correctament';

  // Enllaços
  static const String hkexUrl = 'https://www.hkex.com.hk';
  static const String hkexIpoUrl =
      'https://www.hkex.com.hk/Join-Our-Market/IPO/Listing-with-HKEX?sc_lang=en';
  static const String yahooFinanceUrl = 'https://finance.yahoo.com';
}
