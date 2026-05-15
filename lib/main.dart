import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ipo_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HKEXIPOTrackerApp());
}

class HKEXIPOTrackerApp extends StatefulWidget {
  const HKEXIPOTrackerApp({super.key});

  @override
  State<HKEXIPOTrackerApp> createState() => _HKEXIPOTrackerAppState();
}

class _HKEXIPOTrackerAppState extends State<HKEXIPOTrackerApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IPOProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppConstants.lightTheme,
        darkTheme: AppConstants.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: HomeScreen(
          onToggleTheme: _toggleTheme,
          isDarkMode: _isDarkMode,
        ),
      ),
    );
  }
}
