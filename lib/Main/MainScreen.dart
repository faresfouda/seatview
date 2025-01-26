import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Main/AddNewRestaurantScreen.dart';
import 'package:seatview/Main/DashboardScreen.dart';
import 'package:seatview/Main/HomeScreen.dart';
import 'package:seatview/Main/InventoryManagementScreen.dart';
import 'package:seatview/Main/OwnerHomeScreen.dart';
import 'package:seatview/Main/ProfileScreen.dart';
import 'package:seatview/Main/FavouriteScreen.dart';
import 'package:seatview/Main/ReservationsScreen.dart';
import 'package:seatview/Main/SearchScreen.dart';
import 'package:seatview/Main/UpdateRestaurantScreen.dart';
import 'package:seatview/Components/theme.dart';
import 'package:seatview/model/user.dart'; // Import your custom theme

class MainScreen extends StatefulWidget {
  final String userRole;

  MainScreen({required this.userRole});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late List<Widget> _screens;
  bool _isProfileLoading = true; // Add a loading state for profile data

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.userRole == 'restaurantOwner' ? 2 : 1;
    _screens = widget.userRole == 'restaurantOwner'
        ? [
      ReservationsScreen(),
      InventoryManagementScreen(),
      OwnerHomeScreen(),
      UpdateRestaurantScreen(),
      ProfileScreen(),
    ]
        : [
      DashboardScreen(),
      HomeScreen(),
      FavouriteScreen(),
      ProfileScreen(),
    ];

    // Fetch profile data and then check for restaurant
    _fetchProfileData();
  }

  // Method to fetch profile data
  Future<void> _fetchProfileData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.getProfileData(); // Fetch the profile data using the provided token

      // After fetching profile data, check if the user has a restaurant
      if (widget.userRole == 'restaurantOwner' && userProvider.user?.restaurant == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AddNewRestaurantScreen(),
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $e')),
      );
    } finally {
      // Ensure the widget is still in the tree before calling setState
      if (mounted) {
        setState(() {
          _isProfileLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isProfileLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: widget.userRole == 'restaurantOwner'
            ? [
          BottomNavyBarItem(
            icon: Icon(Icons.event),
            title: Text(
              "Bookings",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.inventory),
            title: Text(
              "Inventory",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text(
              "Home",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.local_restaurant),
            title: Text(
              "My Restaurant",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.account_circle),
            title: Text(
              "Profile",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
        ]
            : [
          BottomNavyBarItem(
            icon: Icon(Icons.event),
            title: Text(
              "Bookings",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text(
              "Home",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.favorite),
            title: Text(
              "Favourite",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.account_circle),
            title: Text(
              "Profile",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
        ],
        backgroundColor: Colors.white, // Background color of the BottomNavyBar
        showElevation: true, // Adds shadow to the bar
      ),
    );
  }
}