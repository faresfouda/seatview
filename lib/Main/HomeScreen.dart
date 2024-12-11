import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurant_list.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Components/bulidcard.dart';
import 'package:seatview/Main/FavoritesProvider.dart';

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

    return SingleChildScrollView(
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
            Container(
              height: 250, // Set a fixed height to prevent overflow
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: restaurantList.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurantList[index];
                  final isFavorite = favoritesProvider.isFavorite(restaurant);

                  return Container(
                    width: 380, // Set a fixed width for each item
                    margin: const EdgeInsets.only(right: 10), // Add some spacing between items
                    child: SingleChildScrollView(
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
              children:  [
                CategoryCard(
                  title: 'Drinks',
                  icon: FontAwesomeIcons.martiniGlass,
                  count: drinksCount,
                  color: Colors.red,
                  onPressed: (){
                    Navigator.pushNamed(context, 'DrinksScreen');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Meals',
                  icon: FontAwesomeIcons.utensils,
                  count: mealsCount,
                  color: Colors.orange,
                  onPressed: (){
                    Navigator.pushNamed(context, 'MealsScreen');
                  },
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Desserts',
                  icon: FontAwesomeIcons.iceCream,
                  count: dessertsCount,
                  color: Colors.red,
                  onPressed: (){
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
                  'Best View Seats',  // Change the title to reflect the view theme
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Handle 'View More' click
                  },
                  child: const Text('View More', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 10),

// Example Best View Seat Item
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://i.pinimg.com/736x/4c/51/24/4c51242cfa51bb8c205242739b4bd0c4.jpg',  // Replace with actual image of a table with a great view
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Table with Ocean View',  // Update with a descriptive name for the view
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text('Perfect spot to enjoy a meal while '),  // Update the description with details about the view
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ),
    );
  }
}