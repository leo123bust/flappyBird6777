import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Skin {
  const Skin(this.id, this.name, this.price);
  final String id;
  final String name;
  final int price;
}

/// Same order and prices as the "Skins" reference screen.
const List<Skin> kSkins = [
  Skin('yellow', 'Sunny', 0),
  Skin('red', 'Ruby', 100),
  Skin('blue', 'Sky', 100),
  Skin('green', 'Leafy', 200),
  Skin('purple', 'Plum', 200),
  Skin('black', 'Shadow', 300),
];

class RunResult {
  const RunResult({required this.newBest, required this.coinsEarned});
  final bool newBest;
  final int coinsEarned;
}

/// Persistent player data (best score, coins, skins, settings).
class GameData extends ChangeNotifier {
  GameData._(this._prefs);

  static late GameData instance;

  static Future<void> init() async {
    instance = GameData._(await SharedPreferences.getInstance());
  }

  final SharedPreferences _prefs;

  int get best => _prefs.getInt('best') ?? 0;
  int get lastScore => _prefs.getInt('last') ?? 0;
  int get coins => _prefs.getInt('coins') ?? 0;
  int get gamesPlayed => _prefs.getInt('games') ?? 0;
  int get totalPipes => _prefs.getInt('pipes') ?? 0;
  String get selectedSkin => _prefs.getString('skin') ?? 'yellow';
  Set<String> get unlocked =>
      (_prefs.getStringList('unlocked') ?? const ['yellow']).toSet();
  bool get vibration => _prefs.getBool('vibration') ?? true;
  bool get tutorialSeen => _prefs.getBool('tutorial') ?? false;

  /// Stores the result of a finished run. One coin is earned per pipe passed.
  Future<RunResult> recordRun(int score) async {
    final newBest = score > best;
    final newCoins = coins + score;
    final newGames = gamesPlayed + 1;
    final newPipes = totalPipes + score;
    if (newBest) await _prefs.setInt('best', score);
    await _prefs.setInt('last', score);
    await _prefs.setInt('coins', newCoins);
    await _prefs.setInt('games', newGames);
    await _prefs.setInt('pipes', newPipes);
    notifyListeners();
    return RunResult(newBest: newBest, coinsEarned: score);
  }

  Future<bool> selectSkin(Skin skin) async {
    if (!unlocked.contains(skin.id)) return false;
    await _prefs.setString('skin', skin.id);
    notifyListeners();
    return true;
  }

  /// Buys (if needed) and selects a skin. Returns false if coins are lacking.
  Future<bool> buySkin(Skin skin) async {
    final owned = unlocked;
    if (owned.contains(skin.id)) return selectSkin(skin);
    if (coins < skin.price) return false;
    await _prefs.setInt('coins', coins - skin.price);
    await _prefs.setStringList('unlocked', [...owned, skin.id]);
    await _prefs.setString('skin', skin.id);
    notifyListeners();
    return true;
  }

  Future<void> setVibration(bool value) async {
    await _prefs.setBool('vibration', value);
    notifyListeners();
  }

  Future<void> markTutorialSeen() async {
    await _prefs.setBool('tutorial', true);
  }
}
