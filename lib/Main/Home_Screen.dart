import 'package:dynamic_fa_icons/dynamic_fa_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurant_list.dart';
import 'package:seatview/Components/RestaurantCard.dart';
import 'package:seatview/Components/bulidcard.dart';
import 'package:seatview/Main/DashboardScreen.dart';
import 'package:seatview/Main/DrinksScreen.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/Main/ProfileScreen.dart';
import 'package:seatview/Main/FavouriteScreen.dart';
import 'package:seatview/Main/RestaurantAboutScreen.dart';
import 'package:seatview/Main/SearchScreen.dart';




class Home_Screen extends StatefulWidget {
  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Home_Screen>
    with SingleTickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  final List<Widget> _screens = [
    DashboardScreen(),
    HomePage(),
    FavouriteScreen(),
    ProfileScreen(),
  ];


  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 1, // Set the initial index to the "Home" tab
      length: 4, // Number of tabs
      vsync: this, // Pass the current State object for vsync
    );
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose(); // Dispose the controller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 140),
          child: const Text(
            'SeatView',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_motionTabBarController!.index],
      bottomNavigationBar: MotionTabBar(
        controller:
        _motionTabBarController, // Connect to MotionTabBarController
        initialSelectedTab: "Home", // Initial tab
        labels: const ["Dashboard", "Home", "favourite", "Profile"],
        icons: const [
          Icons.dashboard,
          Icons.home,
          Icons.favorite,
          Icons.account_circle
        ],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: Colors.red[600],
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: Colors.red[900],
        tabIconSelectedColor: Colors.white,
        tabBarColor: const Color(0xFFAFAFAF),
        onTabItemSelected: (int value) {
          setState(() {
            _motionTabBarController!.index = value; // Update the selected tab
          });
        },
      ),
    );
  }
}


// Import the RestaurantAboutScreen


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final selectedRestaurant = restaurantList[0];

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
            RestaurantCard(
              imageUrl: selectedRestaurant['imageUrl'] as String,
              title: selectedRestaurant['title'] as String,
              description: selectedRestaurant['description'] as String,
              rating: selectedRestaurant['rating'] as double,
              reviewsCount: 23, // Sample reviews count
              onFavoritePressed: () {
                if (favoritesProvider.isFavorite(selectedRestaurant)) {
                  favoritesProvider.removeFavorite(selectedRestaurant);
                } else {
                  favoritesProvider.addFavorite(selectedRestaurant);
                }
              },
              isFavorite: favoritesProvider.isFavorite(selectedRestaurant),
              restaurant: selectedRestaurant,
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
                  'Popular Items',
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

            // Example Popular Item
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
                      'https://i.pinimg.com/736x/52/1a/01/521a01d28f8bc09a8042ee20a0f6451c.jpg',
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
                          'Popular Dish',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text('Description here'),
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



