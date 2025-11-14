// coingecko_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/coin.dart';

class CoinGeckoService {
  static const _base = 'https://api.coingecko.com/api/v3';
  
  static const _cacheKeyTopCoins = 'cached_top_coins';
  
  static const _cacheTTLHours = 1;

  static Future<DateTime> _getCacheExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('${_cacheKeyTopCoins}_expiry') ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  static Future<void> _setCache(String jsonBody) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyTopCoins, jsonBody);
    final expiryTime = DateTime.now().add(const Duration(hours: _cacheTTLHours));
    await prefs.setInt('${_cacheKeyTopCoins}_expiry', expiryTime.millisecondsSinceEpoch);
  }

  static Future<List<Coin>?> _loadFreshCache() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = await _getCacheExpiry();

    if (prefs.containsKey(_cacheKeyTopCoins) && DateTime.now().isBefore(expiry)) {
      final body = prefs.getString(_cacheKeyTopCoins)!;
      print('Serving top coins from fresh cache.');
      final List data = jsonDecode(body);
      return data.map((e) => Coin.fromJson(e)).toList();
    }
    return null;
  }
  

  static Future<List<Coin>> fetchTopCoins({int perPage = 50, int page = 1}) async {
    final cachedCoins = await _loadFreshCache();
    if (cachedCoins != null) {
      return cachedCoins;
    }
    
    final url =
        '$_base/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=$page&sparkline=false&price_change_percentage=24h';

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) {
        print('CoinGecko error: ${res.statusCode} -> ${res.body}');
        return (await _loadStaleCache()) ?? [];
      }

      final body = res.body;

      if (body.trim().startsWith('<')) {
        print('Received HTML instead of JSON from CoinGecko');
        return (await _loadStaleCache()) ?? [];
      }

      await _setCache(body);
      
      final List data = jsonDecode(body);
      return data.map((e) => Coin.fromJson(e)).toList();
    } catch (e) {
      print('Crash prevented (Network Error): $e');
      return (await _loadStaleCache()) ?? [];
    }
  }
  
  static Future<List<Coin>?> _loadStaleCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_cacheKeyTopCoins)) {
      final body = prefs.getString(_cacheKeyTopCoins)!;
      print('Serving top coins from stale cache (offline fallback).');
      final List data = jsonDecode(body);
      return data.map((e) => Coin.fromJson(e)).toList();
    }
    return null;
  }

static Future<List<List<double>>> fetchMarketChart(String id, {int days = 7}) async {
    final url = '$_base/coins/$id/market_chart?vs_currency=usd&days=$days';

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) {
        print('Chart fetch failed: ${res.statusCode}');
        return [];
      }

      final body = res.body;

      if (body.trim().startsWith('<')) {
        print('Chart API returned HTML instead of JSON');
        return [];
      }
      final Map<String, dynamic> json = jsonDecode(body);
      final List pricesData = json['prices'] ?? [];
      
      return pricesData.map((item) {
        return [
          (item[0] as num).toDouble(), 
          (item[1] as num).toDouble(), 
        ];
      }).toList();

    } catch (e) {
      print('Chart fetch crash prevented: $e');
      return [];
    }
  }
}
