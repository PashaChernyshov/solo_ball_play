import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static final ScoreService _instance = ScoreService._internal();
  factory ScoreService() => _instance;
  ScoreService._internal();

  final String _totalKey = 'total_highscore';

  Future<int> getHighscore(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(gameId) ?? 0;
  }

  Future<void> saveScore(String gameId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHighscore(gameId);
    if (score > current) {
      await prefs.setInt(gameId, score);
      _updateTotal(score - current);
    }
  }

  Future<int> get totalHighscore async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalKey) ?? 0;
  }

  Future<void> _updateTotal(int delta) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await totalHighscore;
    await prefs.setInt(_totalKey, current + delta);
  }
}
