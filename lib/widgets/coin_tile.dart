import 'package:flutter/material.dart';
import '../models/coin.dart';

class CoinTile extends StatelessWidget {
  final Coin coin;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const CoinTile({
    super.key,
    required this.coin,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final change = coin.priceChangePercentage24h;
    final changeColor = change >= 0 ? Colors.greenAccent : Colors.redAccent;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: Colors.white12,
        backgroundImage: NetworkImage(coin.image),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              coin.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            coin.symbol.toUpperCase(),
            style: const TextStyle(color: Colors.white54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      subtitle: Text(
        '\$${coin.currentPrice.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 13),
      ),
      trailing: SizedBox(
        width: 110,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                '${change.toStringAsFixed(2)}%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: changeColor),
              ),
            ),
            IconButton(
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: const EdgeInsets.all(6),
              icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: Colors.amberAccent),
              onPressed: onFavoriteToggle,
              tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
            ),
          ],
        ),
      ),
    );
  }
}