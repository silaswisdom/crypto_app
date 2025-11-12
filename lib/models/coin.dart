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
        currentPrice: (j['current_price'] ?? 0).toDouble(),
        priceChangePercentage24h:
            (j['price_change_percentage_24h'] ?? 0).toDouble(),
        marketCap: (j['market_cap'] ?? 0).toDouble(),
      );
}