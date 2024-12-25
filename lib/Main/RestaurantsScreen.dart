import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/model/restaurant.dart';
import 'package:seatview/model/user.dart';

class RestaurantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Get the list of restaurants from the provider
    final restaurants = restaurantProvider.restaurants;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Restaurants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: restaurants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: restaurants.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RestaurantCard(
              imageUrl: restaurant.profileImage,
              title: restaurant.name,
              description: restaurant.address,
              rating: restaurant.avgRating ?? 0,
              reviewsCount: 10, // Placeholder
              onFavoritePressed: () async {
                final token = userProvider.token;
                print(token);

                if (token != null) {
                  try {
                    await favoritesProvider.toggleFavorite(restaurant.id, token);
                    // Notify user of success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${restaurant.name} favorite status updated!')),

                    );

                  } catch (error) {
                    // Notify user of failure
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update favorite: $error')),
                    );
                  }
                } else {
                  // Notify user to log in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You need to log in first!')),
                  );
                }
              },
              restaurant: restaurant,
            ),
          );
        },
      ),
    );
  }
}
