import 'package:shared_preferences/shared_preferences.dart';

/// Persists which score-badge thresholds have ever been unlocked.
class BadgeService {
  static const _key = 'thea_jump_unlocked_badges';

  Future<Set<int>> loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? const [];
    return saved.map(int.parse).toSet();
  }

  Future<void> saveUnlocked(Set<int> thresholds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      thresholds.map((t) => t.toString()).toList(),
    );
  }
}
