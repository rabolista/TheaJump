import 'package:shared_preferences/shared_preferences.dart';

/// Persists the player's best score between app launches.
class HighScoreService {
  static const _key = 'thea_jump_high_score';

  Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> save(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt(_key) ?? 0;
    if (score > best) {
      await prefs.setInt(_key, score);
    }
  }
}
