import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/theme.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/model/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final double rating;
  final int reviewsCount;
  final VoidCallback onFavoritePressed;
  final Restaurant restaurant;  // Pass the restaurant data as a parameter

  const RestaurantCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviewsCount,
    required this.onFavoritePressed,
    required this.restaurant,  // Receive restaurant data
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(restaurant.id);

    // Access the custom theme
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.borderRadius, // Use custom border radius
        color: Colors.grey[200], // You can change this to a theme color if needed
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // When the card is tapped, pass the restaurant data
              Navigator.pushNamed(
                context,
                'RestaurantAboutScreen',  // Make sure this is the correct route
                arguments: restaurant.toMap(),  // Pass restaurant data
              );
            },
            child: ClipRRect(
              borderRadius: AppTheme.borderRadius, // Use custom border radius
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            title: Text(
              title,
              style: theme.textTheme.bodyLarge, // Use theme font style
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 16),
                Text(
                  '${rating.toStringAsFixed(2)} ($reviewsCount Reviews)',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppTheme.primaryColor : Colors.grey, // Use primary color for favorites
              ),
              onPressed: onFavoritePressed,
            ),
          ),
        ],
      ),
    );
  }
}
