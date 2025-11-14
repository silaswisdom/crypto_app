class Coin {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
  });

  factory Coin.fromJson(Map<String, dynamic> j) => Coin(
        id: j['id'] ?? '',
        symbol: j['symbol'] ?? '',
        name: j['name'] ?? '',
        image: j['image'] ?? '',
        currentPrice: _toDouble(j['current_price']),
        priceChangePercentage24h: _toDouble(j['price_change_percentage_24h']),
        marketCap: _toDouble(j['market_cap']),
      );

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
