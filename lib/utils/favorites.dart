import 'package:shared_preferences/shared_preferences.dart';

class Favorites {
  static const _key = 'fav_coins';

  static Future<Set<String>> load() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];
    return list.toSet();
  }

  static Future<void> save(Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_key, ids.toList());
  }

  static Future<void> toggle(String id) async {
    final current = await load();
    if (current.contains(id)) current.remove(id);
    else current.add(id);
    await save(current);
  }
}