import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/model/restaurant.dart';
import 'package:seatview/model/user.dart';

class FavouriteScreen extends StatefulWidget {
  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Fetch favorites when the widget is first created
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userToken = userProvider.token;

    // Check if token is null or invalid
    if (userToken == null) {
      print("User token is null");
      setState(() {
        isLoading = false;
      });
      return;
    }

    print("User token: $userToken");  // Debugging token

    if (favoritesProvider.favoriteRestaurantIds.isEmpty) {
      try {
        await favoritesProvider.getFavorites(userToken);
        setState(() {
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        // Handle error (e.g., show a snackbar or dialog)
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userToken = userProvider.token;

    // Get the list of favorite restaurant IDs
    final favoriteRestaurantIds = favoritesProvider.favoriteRestaurantIds;

    // Debug print to check the list of favorite restaurant IDs
    print('Favorite Restaurant IDs: $favoriteRestaurantIds');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteRestaurantIds.isEmpty
          ? Center(
        child: Text(
          "No Favorites Added",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: favoriteRestaurantIds.length,
        itemBuilder: (context, index) {
          // Fetch restaurant details using the ID
          final restaurantId = favoriteRestaurantIds[index];
          final restaurant = Provider.of<RestaurantProvider>(context)
              .restaurants
              .firstWhere(
                (restaurant) => restaurant.id == restaurantId,
            orElse: () => Restaurant(
              id: '',
              name: 'Unknown',
              address: 'Unknown',
              phone: '',
              openingHours: '',
              profileImage: '',
              layoutImage: '',
              galleryImages: [],
              avgRating: 5,
              categories: [],
            ),
          );

          if (restaurant.id.isEmpty) {
            return ListTile(
              title: Text('Restaurant not found'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: RestaurantCard(
              imageUrl: restaurant.profileImage,
              title: restaurant.name,
              description: restaurant.address,
              rating: restaurant.avgRating ?? 0.0,
              reviewsCount: 23, // Placeholder for review count
              onFavoritePressed: () {
                if (userToken != null) {
                  // Call API to remove from favorites using the token
                  favoritesProvider.toggleFavorite(restaurant.id, userToken);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${restaurant.name} removed from favorites!'),
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
            ),
          );
        },
      ),
    );
  }

}
