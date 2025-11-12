import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/coingecko_service.dart';
import '../utils/favorites.dart';
import '../widgets/coin_tile.dart';
import 'coin_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Coin> _coins = [];
  List<Coin> _filtered = [];
  Set<String> _favorites = {};
  bool _loading = true;
  String _query = '';
  bool _showOnlyFav = false;

  Coin? _selectedCoin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final coins = await CoinGeckoService.fetchTopCoins(perPage: 50);
    final favs = await Favorites.load();
    setState(() {
      _coins = coins;
      _favorites = favs;
      _applyFilter();
      _loading = false;
      if (_selectedCoin == null && coins.isNotEmpty) _selectedCoin = coins.first;
    });
  }

  void _applyFilter() {
    final q = _query.toLowerCase();
    var list = _coins.where((c) {
      final match = c.name.toLowerCase().contains(q) || c.symbol.toLowerCase().contains(q);
      if (!_showOnlyFav) return match;
      return match && _favorites.contains(c.id);
    }).toList();
    setState(() => _filtered = list);
  }

  void _onToggleFavorite(String id) async {
    await Favorites.toggle(id);
    final favs = await Favorites.load();
    setState(() => _favorites = favs);
    _applyFilter();
  }

  void _onSelectCoin(Coin coin, double width) {
    if (width < 900) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CoinDetailScreen(coin: coin),
      ));
    } else {
      setState(() {
        _selectedCoin = coin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isWide = width >= 900;
      final isTablet = width >= 600 && width < 900;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Crypto Wallet'),
          actions: [
            IconButton(
              icon: Icon(_showOnlyFav ? Icons.star : Icons.star_border),
              onPressed: () {
                setState(() {
                  _showOnlyFav = !_showOnlyFav;
                  _applyFilter();
                });
              },
              tooltip: 'Favorites',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _load,
              tooltip: 'Refresh',
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name or symbol',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFF0F1724),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) {
                    _query = v;
                    _applyFilter();
                  },
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: isWide
                          ? Row(
                              children: [
                                Container(
                                  width: 380,
                                  decoration: BoxDecoration(
                                    border: Border(right: BorderSide(color: Colors.white12)),
                                  ),
                                  child: _buildList(width, compact: true),
                                ),
                                Expanded(
                                  child: _selectedCoin == null
                                      ? const Center(child: Text('Select a coin', style: TextStyle(color: Colors.white54)))
                                      : CoinDetailScreen(coin: _selectedCoin!),
                                )
                              ],
                            )
                          : _buildList(width),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildList(double width, {bool compact = false}) {
    final isTablet = width >= 600 && width < 900;
    if (isTablet) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 5.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _filtered.length,
        itemBuilder: (ctx, i) {
          final coin = _filtered[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onSelectCoin(coin, width),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF071022),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(coin.image), backgroundColor: Colors.white12),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(coin.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(coin.symbol.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${coin.currentPrice.toStringAsFixed(2)}'),
                        Text('${coin.priceChangePercentage24h.toStringAsFixed(2)}%', style: TextStyle(color: coin.priceChangePercentage24h >= 0 ? Colors.greenAccent : Colors.redAccent)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(_favorites.contains(coin.id) ? Icons.star : Icons.star_border, color: Colors.amberAccent),
                      onPressed: () => _onToggleFavorite(coin.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
      itemBuilder: (ctx, i) {
        final coin = _filtered[i];
        return CoinTile(
          coin: coin,
          isFavorite: _favorites.contains(coin.id),
          onFavoriteToggle: () => _onToggleFavorite(coin.id),
          onTap: () => _onSelectCoin(coin, width),
        );
      },
    );
  }
}