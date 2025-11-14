import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin.dart';

class CoinGeckoService {
  static const _base = 'https://api.coingecko.com/api/v3';

  static Future<List<Coin>> fetchTopCoins({int perPage = 50, int page = 1}) async {
    final url =
        '$_base/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=$page&sparkline=false&price_change_percentage=24h';

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) {
        print('CoinGecko error: ${res.statusCode} -> ${res.body}');
        return [];
      }

      final body = res.body;

      if (body.trim().startsWith('<')) {
        print('Received HTML instead of JSON from CoinGecko');
        return [];
      }

      final List data = jsonDecode(body);
      return data.map((e) => Coin.fromJson(e)).toList();
    } catch (e) {
      print('Crash prevented: $e');
      return [];
    }
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

      final Map data = jsonDecode(body);
      final List prices = data['prices'] ?? [];

      return prices
          .map<List<double>>((p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()])
          .toList();
    } catch (e) {
      print('Crash prevented: $e');
      return [];
    }
  }
}
