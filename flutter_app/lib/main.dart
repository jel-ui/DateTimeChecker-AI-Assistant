import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme/app_theme.dart';
import 'services/history_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  final prefs = await SharedPreferences.getInstance();
  final historyService = HistoryService(prefs);

  runApp(DateTimeCheckerApp(historyService: historyService));
}

class DateTimeCheckerApp extends StatefulWidget {
  final HistoryService historyService;

  const DateTimeCheckerApp({super.key, required this.historyService});

  @override
  State<DateTimeCheckerApp> createState() => _DateTimeCheckerAppState();
}

class _DateTimeCheckerAppState extends State<DateTimeCheckerApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.historyService.isDarkMode();
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
    widget.historyService.setDarkMode(_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Time Checker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        historyService: widget.historyService,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
