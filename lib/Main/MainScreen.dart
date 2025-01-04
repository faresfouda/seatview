import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:seatview/Main/DashboardScreen.dart';
import 'package:seatview/Main/HomeScreen.dart';
import 'package:seatview/Main/InventoryManagementScreen.dart';
import 'package:seatview/Main/OwnerHomeScreen.dart';
import 'package:seatview/Main/ProfileScreen.dart';
import 'package:seatview/Main/FavouriteScreen.dart';
import 'package:seatview/Main/ReservationsScreen.dart';
import 'package:seatview/Main/SearchScreen.dart';
import 'package:seatview/Main/UpdateRestaurantScreen.dart';

class MainScreen extends StatefulWidget {
  final String userRole; // Accept user role as a parameter

  MainScreen({required this.userRole});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    print('Role: ${widget.userRole}');

    // Define screens based on user role
    _screens = widget.userRole == 'restaurantOwner'
        ? [
      ReservationsScreen(),
      InventoryManagementScreen(),
      OwnerHomeScreen(), // Home screen for restaurant owners
      UpdateRestaurantScreen(),
      ProfileScreen(),
    ]
        : [
      DashboardScreen(),
      HomeScreen(), // Regular user's HomeScreen
      FavouriteScreen(),
      ProfileScreen(),
    ];

    _motionTabBarController = MotionTabBarController(
      initialIndex: widget.userRole == 'restaurantOwner' ? 2 : 1, // Dynamic initial index
      length: _screens.length, // Adjust based on the number of screens
      vsync: this, // Pass the current State object for vsync
    );
  }

  @override
  void dispose() {
    _motionTabBarController?.dispose(); // Safely dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _motionTabBarController!.index == 1
          ? AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 140),
          child: Text(
            widget.userRole == 'restaurantOwner'
                ? 'SeatView - Owner'
                : 'SeatView - Home',
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold),
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
      )
          : null, // Hide AppBar for all other tabs
      body: IndexedStack(
        index: _motionTabBarController!.index,
        children: _screens,
      ),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController, // Connect to MotionTabBarController
        initialSelectedTab: widget.userRole == 'restaurantOwner' ? "Home" : "Home",
        labels: widget.userRole == 'restaurantOwner'
            ? ["Bookings", "Inventory", "Home", "My restaurant","Profile"]
            : ["Bookings", "Home", "Favourite", "Profile"],
        icons: widget.userRole == 'restaurantOwner'
            ? [Icons.event, Icons.inventory, Icons.home,Icons.local_restaurant ,Icons.account_circle]
            : [Icons.event, Icons.home, Icons.favorite, Icons.account_circle],
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
