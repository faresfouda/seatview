import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurant_list.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';

class DrinksScreen extends StatelessWidget {
  const DrinksScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final mealsRestaurants = restaurantList.where((restaurant) {
      return restaurant['tags'].contains('drinks');
    }).toList();
    return  Scaffold(
      appBar: AppBar(
        title: const Text(
          'Drinks Restaurants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: mealsRestaurants.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final restaurant = mealsRestaurants[index];
          final isFavorite = favoritesProvider.isFavorite(restaurant);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RestaurantCard(
              imageUrl: restaurant['imageUrl'] as String,
              title: restaurant['title'] as String,
              description: restaurant['description'] as String,
              rating: restaurant['rating'] as double,
              reviewsCount: 23,
              onFavoritePressed: () {
                favoritesProvider.toggleFavorite(favoritesProvider, restaurant, isFavorite);
              },
              isFavorite: isFavorite,
              restaurant: restaurant,
            ),
          );
        },
      ),
    );
  }
}
