import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ipo_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HKEXIPOTrackerApp());
}

class HKEXIPOTrackerApp extends StatelessWidget {
  const HKEXIPOTrackerApp({super.key});

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
        home: const HomeScreen(),
      ),
    );
  }
}
