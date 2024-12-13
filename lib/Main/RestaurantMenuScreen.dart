import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icon.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/MealCardWidget.dart';
import 'package:seatview/Components/menu_provider.dart';
import 'package:seatview/Main/CheckoutScreen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const RestaurantMenuScreen({
    required this.restaurant,
    required this.selectedDate,
    required this.selectedTime,
    Key? key,
  }) : super(key: key);

  @override
  _RestaurantMenuScreenState createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> with SingleTickerProviderStateMixin {
  void _showMealDetails(Map meal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(meal['mealName']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(meal['mealImage'],
              height: 300,),
              const SizedBox(height: 8),
              Text('Price: ${meal['price']} L.E',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,),
              ),
              Text('Details: ${meal['description']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,)
                ,)
              // Add more details if necessary
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final categoriesData = widget.restaurant['categories'] as List<Map<String, dynamic>>? ?? [];
    _tabController = TabController(length: categoriesData.length + 1, vsync: this); // +1 for the Favorites tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesData = widget.restaurant['categories'] as List<Map<String, dynamic>>? ?? [];
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu - ${widget.restaurant['title']}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            ...categoriesData.map((category) => Tab(text: category['categoryName'])).toList(),
            const Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Categories Tabs
          ...categoriesData.map((category) {
            final meals = category['meals'] as List? ?? [];
            return GridView.builder(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8.0), // Add padding around the grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two cards per row
                crossAxisSpacing: 10.0, // Space between columns
                mainAxisSpacing: 12.0, // Space between rows
                childAspectRatio: 0.83, // Adjust the aspect ratio of the cards
              ),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return MealCardWidget(
                  mealName: meal['mealName'],
                  mealImage: meal['mealImage'],
                  mealFavorites: menuProvider.favoriteMeals.contains(meal),
                  onFavoriteToggle: () => menuProvider.toggleFavorite(meal),
                  onAddToOrder: () {
                  menuProvider.addToOrder(meal);
                },
                  mealPrice: meal['price'] ?? 0.0,
                  onTap: () => _showMealDetails(meal),
                );
              },
            );
          }).toList(),
          // Favorites Tab
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: menuProvider.favoriteMeals.length,
            itemBuilder: (context, index) {
              final meal = menuProvider.favoriteMeals[index];
              return MealCardWidget(
                mealName: meal['mealName'],
                mealImage: meal['mealImage'],
                mealFavorites: true,
                onFavoriteToggle: () => menuProvider.toggleFavorite(meal),
                onAddToOrder: () => menuProvider.addToOrder(meal['price'] ?? 0.0),
                mealPrice: meal['price'] ?? 0.0,
                onTap: () => _showMealDetails(meal),
              );
            },
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text('Procced to checkout Total: ${menuProvider.totalCost.toStringAsFixed(2)} L.E'),
          icon: Icon(FontAwesomeIcons.dollarSign),
          onPressed: () {
            // Navigate to the checkout screen with the selected date, time, and total cost
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutScreen(
                  selectedDate: widget.selectedDate,
                  selectedTime: widget.selectedTime,
                  restaurant:widget.restaurant,
                ),
              ),
            );

          },
        )

    );
  }
}
