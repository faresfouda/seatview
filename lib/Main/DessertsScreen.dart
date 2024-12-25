import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/model/user.dart';

class DessertsScreen extends StatelessWidget {
  const DessertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userToken = userProvider.token;
    // Get the list of restaurants from the provider
    final allRestaurants = restaurantProvider.restaurants;

    // Filter restaurants by the "desserts" tag
    final dessertsRestaurants = allRestaurants.where((restaurant) {
      return restaurant.categories.contains('desserts'); // Assuming `tags` is a list in the `Restaurant` model
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Desserts Restaurants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: dessertsRestaurants.isEmpty
          ? Center(
        child: Text(
          'No dessert restaurants available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: dessertsRestaurants.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final restaurant = dessertsRestaurants[index];
          // final isFavorite = favoritesProvider.isFavorite(restaurant.toJson());

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RestaurantCard(
              imageUrl: restaurant.profileImage,
              title: restaurant.name,
              description: restaurant.address,
              rating: restaurant.avgRating ?? 0,
              reviewsCount: 10, // Placeholder
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
              restaurant: restaurant,
              // isFavorite: isFavorite,
            ),
          );
        },
      ),
    );
  }
}
