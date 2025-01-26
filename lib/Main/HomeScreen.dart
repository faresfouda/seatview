import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Components/bulidcard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/Main/RestaurantAboutScreen.dart';
import 'package:seatview/model/restaurant.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/model/user.dart';
import 'package:seatview/Components/theme.dart'; // Import theme

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Fetch restaurants and favorites once the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRestaurants();
      _fetchFavorites();
    });

    // Start the automatic scrolling
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _scrollToNextItem();
    });
  }

  // Fetch favorites from the provider
  void _fetchFavorites() async {
    try {
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userToken = userProvider.token;

      if (userToken != null) {
        await favoritesProvider.getFavorites(userToken);
      } else {
        // Handle token error or no user logged in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You need to log in to view your favorites!')),
        );
      }
    } catch (error) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load favorites: $error')),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  // Existing code for fetching restaurants and scrolling items
  void _fetchRestaurants() async {
    try {
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      await restaurantProvider.fetchRestaurants();
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _scrollToNextItem() {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final restaurants = restaurantProvider.restaurants;

    if (_scrollController.hasClients && restaurants.isNotEmpty) {
      double itemWidth = 390.0; // Adjust based on your card width
      double nextOffset = (_currentIndex + 1 >= restaurants.length)
          ? 0
          : (_currentIndex + 1) * itemWidth;

      // Scroll to the next item
      _scrollController.animateTo(
        nextOffset,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );

      // Update the index for the next scroll
      setState(() {
        _currentIndex = (_currentIndex + 1) % restaurants.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final restaurants = restaurantProvider.restaurants;

    return Scaffold(
      appBar: AppBar(
        title: Text('SeatView'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _hasError
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading restaurants.'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchRestaurants,
                child: Text('Try Again'),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurants Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Restaurants',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'RestaurantsScreen');
                      },
                      child: Text(
                        'View More',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Horizontal ListView for Restaurants
                Container(
                  height: 252,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];

                      return Container(
                        width: 380,
                        margin: EdgeInsets.only(right: 10),
                        child: RestaurantCard(
                          imageUrl: restaurant.profileImage,
                          title: restaurant.name,
                          description: restaurant.address,
                          rating: restaurant.avgRating ?? 0,
                          reviewsCount: 10, // Placeholder
                          onFavoritePressed: () async {
                            final token = userProvider.token;

                            if (token != null) {
                              try {
                                await favoritesProvider.toggleFavorite(restaurant.id, token);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${restaurant.name} favorite status updated!')),
                                );
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update favorite: $error')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('You need to log in first!')),
                              );
                            }
                          },
                          restaurant: restaurant,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Food Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryCard(
                      title: 'Drinks',
                      icon: FontAwesomeIcons.martiniGlass,
                      count: 1,
                      color: Colors.red,
                      onPressed: () {
                        Navigator.pushNamed(context, 'DrinksScreen');
                      },
                    ),
                    SizedBox(width: 10),
                    CategoryCard(
                      title: 'Meals',
                      icon: FontAwesomeIcons.utensils,
                      count: 1,
                      color: Colors.orange,
                      onPressed: () {
                        Navigator.pushNamed(context, 'MealsScreen');
                      },
                    ),
                    SizedBox(width: 10),
                    CategoryCard(
                      title: 'Desserts',
                      icon: FontAwesomeIcons.iceCream,
                      count: 1,
                      color: Colors.red,
                      onPressed: () {
                        Navigator.pushNamed(context, 'DessertsScreen');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Best View',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  height: 110, // Adjusted height to ensure space for content
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];

                      // Get the first image from galleryImages
                      final firstImage = restaurant.galleryImages.isNotEmpty
                          ? restaurant.galleryImages[0]
                          : ''; // Use a default image or an empty string if no image

                      final rating = restaurant.avgRating.toStringAsFixed(2) ?? 0;
                      final bookedTimes = 0; // Placeholder for the number of booked tables

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantAboutScreen(
                                restaurant: restaurant.toMap(),
                                initialTabIndex: 1, // Pass the tab index for the Gallery Tab
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 380, // Set a fixed width for each item
                          margin: EdgeInsets.only(right: 20), // Increased margin between items
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white, // Set the background color for each item
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12, // Shadow effect to separate items
                                blurRadius: 4,
                                spreadRadius: 2,
                                offset: Offset(0, 4), // Position of the shadow
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  firstImage,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Table with Ocean View', // Placeholder title
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Perfect spots',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text('Rating: $rating'),
                                    Text('Booked: $bookedTimes times'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
