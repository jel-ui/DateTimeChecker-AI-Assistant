import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'date_time_validation_service.dart';

class HistoryService {
  static const _key = 'date-time-checker-history';
  static const _maxItems = 4;

  final SharedPreferences _prefs;

  HistoryService(this._prefs);

  List<DateTimeParts> getHistory() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => DateTimeParts.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> remember(DateTimeParts parts) async {
    final history = getHistory();
    history.removeWhere((item) => item.display == parts.display);
    history.insert(0, parts);
    final trimmed = history.take(_maxItems).toList();
    await _prefs.setString(
      _key,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_key);
  }

  // ── Theme persistence ──
  static const _themeKey = 'date-time-checker-theme';

  bool isDarkMode() => _prefs.getString(_themeKey) == 'dark';

  Future<void> setDarkMode(bool dark) async {
    await _prefs.setString(_themeKey, dark ? 'dark' : 'light');
  }
}
