import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurant_list.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Components/bulidcard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/Main/RestaurantAboutScreen.dart';

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

    // Wait until the first frame is rendered before starting the timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start the automatic scrolling every 3 seconds after the page is loaded
      _timer = Timer.periodic(Duration(seconds: 3), (timer) {
        _scrollToNextItem();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  void _scrollToNextItem() {
    if (_scrollController.hasClients) {
      double itemWidth = 390.0;
      double nextOffset = (_currentIndex + 1 >= restaurantList.length)
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
        _currentIndex = (_currentIndex + 1) % restaurantList.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    final drinksCount = restaurantList.where((restaurant) {
      return restaurant['tags'].contains('drinks');
    }).length;
    final mealsCount = restaurantList.where((restaurant) {
      return restaurant['tags'].contains('meals');
    }).length;
    final dessertsCount = restaurantList.where((restaurant) {
      return restaurant['tags'].contains('desserts');
    }).length;

    return Scaffold(
        body: SafeArea(
      // Ensures no overlap with system UI
      child: SingleChildScrollView(
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
                    child: const Text('View More',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Fixed height for horizontal ListView to prevent overflow
              Container(
                height: 250, // Set a fixed height to prevent overflow
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection:
                      Axis.horizontal, // Set scroll direction to horizontal
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: restaurantList.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurantList[index];
                    final isFavorite = favoritesProvider.isFavorite(restaurant);

                    return Container(
                      width: 380, // Set a fixed width for each item
                      margin: const EdgeInsets.only(
                          right: 10), // Add some spacing between items
                      child: SingleChildScrollView(
                        child: RestaurantCard(
                          imageUrl: restaurant['imageUrl'] as String,
                          title: restaurant['title'] as String,
                          description: restaurant['description'] as String,
                          rating: restaurant['rating'] as double,
                          reviewsCount: 23,
                          onFavoritePressed: () {
                            favoritesProvider.toggleFavorite(
                                favoritesProvider, restaurant, isFavorite);
                          },
                          isFavorite: isFavorite,
                          restaurant: restaurant,
                        ),
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
                    count: drinksCount,
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pushNamed(context, 'DrinksScreen');
                    },
                  ),
                  SizedBox(width: 10),
                  CategoryCard(
                    title: 'Meals',
                    icon: FontAwesomeIcons.utensils,
                    count: mealsCount,
                    color: Colors.orange,
                    onPressed: () {
                      Navigator.pushNamed(context, 'MealsScreen');
                    },
                  ),
                  SizedBox(width: 10),
                  CategoryCard(
                    title: 'Desserts',
                    icon: FontAwesomeIcons.iceCream,
                    count: dessertsCount,
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pushNamed(context, 'DessertsScreen');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Popular Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Best View Seats',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle 'View More' click
                    },
                    child: const Text('View More',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Best View Seat Item
              Container(
                height: 110, // Adjusted height to ensure space for content
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurantList.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurantList[index];

                    // Get the first image from galleryImages
                    final firstImage = restaurant['galleryImages'][0];
                    final rating = restaurant['rating'];
                    final bookedTimes = restaurant['tables']
                        .where((table) => table['isBooked'] == true)
                        .length;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantAboutScreen(
                              restaurant: restaurant,
                              initialTabIndex: 1,  // Pass the tab index for the Gallery Tab
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
                                'https://i.pinimg.com/236x/5a/2b/83/5a2b8359d5d772bae0359c77cb8967a3.jpg', // Use the first image from galleryImages
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
                                    'Table with Ocean View',
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
              )



            ],
          ),
        ),
      ),
    ));
  }
}
