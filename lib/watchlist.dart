import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistStorage {
  static const String key = "watchlist";

  // load watchlist from local storage
  static Future<List<Map<String, dynamic>>> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    final List<dynamic> decodedList = jsonDecode(jsonString);

    return decodedList
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  //  save watchlist to be used by local storage 
  static Future<void> saveWatchlist(
      List<Map<String, dynamic>> watchlist) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(watchlist);
    await prefs.setString(key, jsonString);
  }

  // add an item to the watchlist 
  static Future<List<Map<String, dynamic>>> addToWatchlist(
      Map<String, dynamic> item) async {
    final watchlist = await loadWatchlist();

    final id = item["id"];
    bool exists = watchlist.any((m) => m["id"] == id);

    if (!exists) {
      watchlist.add(item);
      await saveWatchlist(watchlist);
    }

    return watchlist;
  }
}