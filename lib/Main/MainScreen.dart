  import 'package:flutter/material.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
  import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
  import 'package:provider/provider.dart';
  import 'package:seatview/API/restaurant_list.dart';
  import 'package:seatview/Components/RestaurantCard.dart';
  import 'package:seatview/Components/bulidcard.dart';
  import 'package:seatview/Main/DashboardScreen.dart';
  import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/Main/HomeScreen.dart';
  import 'package:seatview/Main/ProfileScreen.dart';
  import 'package:seatview/Main/FavouriteScreen.dart';
  import 'package:seatview/Main/SearchScreen.dart';




  class MainScreen extends StatefulWidget {
    @override
    _MainScreenState createState() => _MainScreenState();
  }

  class _MainScreenState extends State<MainScreen>
      with SingleTickerProviderStateMixin {
    MotionTabBarController? _motionTabBarController;
    final List<Widget> _screens = [
      DashboardScreen(),
      HomeScreen(),
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
      _motionTabBarController?.dispose(); // Safely dispose
      super.dispose();
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
        body: IndexedStack(
          index: _motionTabBarController!.index,
          children: _screens,
        ),
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






