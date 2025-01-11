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
  final String userRole; // Accept user role as a parameter

  MainScreen({required this.userRole});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late List<Widget> _screens;
  bool _isLoading = false;  // Add a loading state for the account deletion process
  bool _isProfileLoading = true; // Loading state for profile data

  @override
  void initState() {
    super.initState();

    // Log the user role and token for debugging
    print('Role: ${widget.userRole}');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userToken = userProvider.token;
    print('User Token: $userToken');

    // Use a post-frame callback to safely interact with the widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfileData(); // Fetch profile data after the first frame

      // Redirect restaurant owners without a registered restaurant
      if (userProvider.user?.role == 'restaurantOwner' && userProvider.user?.restaurant == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AddNewRestaurantScreen(),
          ),
        );
      }
    });

    // Define screens based on the user role
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

    // Set initial index based on user role
    _currentIndex = widget.userRole == 'restaurantOwner' ? 2 : 1;
  }

// Method to fetch profile data
  Future<void> _fetchProfileData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.getProfileData(); // Fetch the profile data using the provided token
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $e')),
      );
    } finally {
      // Update the loading state in all cases
      setState(() {
        _isProfileLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1 && widget.userRole != 'restaurantOwner'
          ? AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 140),
          child: Text(
            'SeatView - Home',
            style: TextStyle(
                color: AppTheme.primaryColor, // Use theme color
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.primaryColor), // Use theme color
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
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
        },
        items: widget.userRole == 'restaurantOwner'
            ? [
          BottomNavyBarItem(
            icon: Icon(Icons.event, size: 30),
            title: Text(
              "Bookings",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.inventory, size: 30),
            title: Text(
              "Inventory",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.home, size: 30),
            title: Text(
              "Home",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.local_restaurant, size: 30),
            title: Text(
              "My Restaurant",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.account_circle, size: 30),
            title: Text(
              "Profile",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
        ]
            : [
          BottomNavyBarItem(
            icon: Icon(Icons.event, size: 30),
            title: Text(
              "Bookings",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.home, size: 30),
            title: Text(
              "Home",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.favorite, size: 30),
            title: Text(
              "Favourite",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.account_circle, size: 30),
            title: Text(
              "Profile",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.primaryColor), // Use theme color
            ),
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.secondaryColor,
          ),
        ],
        backgroundColor: Colors.white,
        iconSize: 30.0,
        showElevation: true, // Adds shadow to the bar
      ),
    );
  }
}
