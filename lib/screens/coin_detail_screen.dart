import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/coingecko_service.dart';
import '../widgets/price_chart.dart';
import '../utils/favorites.dart';

class CoinDetailScreen extends StatefulWidget {
  final Coin coin;
  const CoinDetailScreen({super.key, required this.coin});
  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  bool _loading = true;
  List<List<double>> _prices = [];
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final favs = await Favorites.load();
    setState(() => _isFav = favs.contains(widget.coin.id));
    await _loadChart();
  }

  Future<void> _loadChart() async {
    setState(() => _loading = true);
    final p = await CoinGeckoService.fetchMarketChart(widget.coin.id, days: 7);
    setState(() {
      _prices = p;
      _loading = false;
    });
  }

  void _toggleFav() async {
    await Favorites.toggle(widget.coin.id);
    final favs = await Favorites.load();
    setState(() => _isFav = favs.contains(widget.coin.id));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.coin;
    return Scaffold(
      appBar: AppBar(
        title: Text('${c.name} (${c.symbol.toUpperCase()})'),
        actions: [
          IconButton(
            icon: Icon(_isFav ? Icons.star : Icons.star_border, color: Colors.amberAccent),
            onPressed: _toggleFav,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: const Color(0xFF0F1624),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Image.network(c.image, width: 48, height: 48),
                      title: Text('\$${c.currentPrice.toStringAsFixed(4)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text('Market Cap: \$${(c.marketCap / 1e9).toStringAsFixed(2)}B'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${c.priceChangePercentage24h.toStringAsFixed(2)}%', style: TextStyle(color: c.priceChangePercentage24h >= 0 ? Colors.greenAccent : Colors.redAccent))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(child: PriceChart(prices: _prices)),
                ],
              ),
            ),
    );
  }
}