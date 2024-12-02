import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:seatview/Components/bulidcard.dart';
import 'package:seatview/Components/component.dart';
import 'package:seatview/Main/DashboardScreen.dart';
import 'package:seatview/Main/ProfileScreen.dart';
import 'package:seatview/Main/FavouriteScreen.dart';




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
        title: const Text(
          'SeatView',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.red),
            onPressed: () {
              // Handle notification button click
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

  // A placeholder for adding items to the favorites list
  void _addToFavorites(Map<String, dynamic> item) {

  }

  @override
  Widget build(BuildContext context) {
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
                    // Handle 'View More' click
                  },
                  child: const Text('View More', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to the RestaurantAboutScreen
                      Navigator.pushNamed(context, 'RestaurantAboutScreen');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://i.pinimg.com/736x/6b/08/3b/6b083bd6cfa02b3ca4cce07a018600c8.jpg',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Asparagus'),
                    subtitle: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        Text('5.0 (23 Reviews)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () {
                        _addToFavorites({
                          'title': 'Asparagus',
                          'description': 'Delicious grilled asparagus.',
                          'rating': 5.0,
                          'imageUrl': 'https://via.placeholder.com/150',
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Food Categories Section
            const Text(
              'Food Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                CategoryCard(
                  title: 'Drinks',
                  icon: Icons.local_drink,
                  count: 5,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Meals',
                  icon: Icons.restaurant,
                  count: 20,
                  color: Colors.orange,
                ),
                SizedBox(width: 10),
                CategoryCard(
                  title: 'Hot',
                  icon: Icons.local_fire_department,
                  count: 8,
                  color: Colors.red,
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
