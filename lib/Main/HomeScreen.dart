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

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch restaurants once the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants();
    });

    // Start the automatic scrolling
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _scrollToNextItem();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
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
      body: SafeArea(
        child: restaurants.isEmpty
            ? Center(child: CircularProgressIndicator())
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
                    const Text(
                      'Restaurants',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'RestaurantsScreen');
                      },
                      child: const Text('View More', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Horizontal ListView for Restaurants
                Container(
                  height: 252,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];

                      return Container(
                        width: 380,
                        margin: const EdgeInsets.only(right: 10),
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
                ),
                const SizedBox(height: 15),
                const Text(
                  'Food Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 20),
                // "Best View" Section
                const SizedBox(height: 20),
                const Text(
                  'Best View',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
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
                                    Text('Perfect spot to enjoy a meal while'),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


