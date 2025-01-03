import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/model/restaurant.dart';


class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final double rating;
  final int reviewsCount;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;
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
    this.isFavorite = false,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite =favoritesProvider.isFavorite(restaurant.id);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // When the card is tapped, pass the restaurant data
              Navigator.pushNamed(
                context,
                'RestaurantAboutScreen',  // Make sure this is the correct route
                arguments: restaurant.toMap(),  // Pass restaurant data
              );
              print(restaurant);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            title: Text(title),
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
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoritePressed,
            ),
          ),
        ],
      ),
    );
  }
}



