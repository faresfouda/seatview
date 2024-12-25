import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/model/user.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userToken = userProvider.token;
    // Fetch the list of restaurants from the provider
    final allRestaurants = restaurantProvider.restaurants;

    // Filter restaurants with the "meals" tag
    final mealsRestaurants = allRestaurants.where((restaurant) {
      return restaurant.categories.contains('meals'); // Assuming `tags` is a list in your `Restaurant` model
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meals Restaurants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: mealsRestaurants.isEmpty
          ? const Center(
        child: Text(
          'No meals restaurants available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: mealsRestaurants.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final restaurant = mealsRestaurants[index];
          // final isFavorite = favoritesProvider.isFavorite(restaurant.toJson());

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RestaurantCard(
              imageUrl: restaurant.profileImage,
              title: restaurant.name,
              description: restaurant.address,
              rating: restaurant.avgRating ?? 0,
              reviewsCount: 10, // Placeholder for review count
              onFavoritePressed: () {
                if (userToken != null) {
                  // Call API to remove from favorites using the token
                  favoritesProvider.toggleFavorite(restaurant.id, userToken);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${restaurant.name} favorite status updated!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please log in to manage favorites.'),
                    ),
                  );
                }
              },
              // isFavorite: isFavorite,
              restaurant: restaurant,
            ),
          );
        },
      ),
    );
  }
}
