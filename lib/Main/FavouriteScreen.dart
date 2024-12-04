import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';


class FavouriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    // Get the list of favorite restaurants
    final favoriteRestaurants = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: favoriteRestaurants.isEmpty
          ? Center(child: Text("No Favorites Added"))
          : ListView.builder(
        itemCount: favoriteRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = favoriteRestaurants[index];
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RestaurantCard(
                imageUrl: restaurant['imageUrl'] as String,
                title: restaurant['title'] as String,
                description: restaurant['description'] as String,
                rating: restaurant['rating'] as double,
                reviewsCount: 23, // You can update this with actual review count if needed
                onFavoritePressed: () {
                  favoritesProvider.removeFavorite(restaurant);
                },
                isFavorite: true,
                restaurant: restaurant, // Since it's already a favorite
              ),
            ),
          );
        },
      ),
    );
  }
}
