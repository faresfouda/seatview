import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/MealCardWidget.dart';
import 'package:seatview/Main/CheckoutScreen.dart';
import 'package:seatview/model/meal.dart';
import 'package:seatview/model/user.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final restaurant;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedTable;

  const RestaurantMenuScreen({
    required this.restaurant,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedTable,
    Key? key,
  }) : super(key: key);

  @override
  _RestaurantMenuScreenState createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  @override
  void initState() {
    super.initState();
    final menuProvider = Provider.of<MealProvider>(context, listen: false);
    menuProvider.fetchMeals(widget.restaurant['id']);
  }

  void _showMealDetails(Meal meal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(meal.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(meal.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              const SizedBox(height: 8),
              Text('Price: ${meal.price} L.E',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
              const SizedBox(height: 8),
              Text('Details: ${meal.description}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  )),
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

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MealProvider>(context);
    final mealsData = menuProvider.meals;
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu - ${widget.restaurant['name']}'),
      ),
      body: menuProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : mealsData.isEmpty
          ? Center(child: Text("No meals available"))
          : ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.74,
            ),
            itemCount: mealsData.length,
            itemBuilder: (context, index) {
              final meal = mealsData[index];
              return MealCardWidget(
                mealName: meal.name,
                mealImage: meal.imageUrl,
                mealPrice: meal.price ?? 0.0,
                onTap: () => _showMealDetails(meal),
                onAddToOrder: () {
                  menuProvider.addMealToOrder(meal);
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          'Proceed to checkout (${menuProvider.orderedMeals.length} items) - ${menuProvider.totalCost.toStringAsFixed(2)} L.E',
        ),
        icon: Icon(FontAwesomeIcons.dollarSign),
        onPressed: () {
          // Navigate to the CheckoutScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                selectedDate: widget.selectedDate,
                selectedTime: widget.selectedTime,
                restaurant: widget.restaurant,
                selectedTable: widget.selectedTable,
                token:user.token??"", // Pass the token here
              ),
            ),
          );
        },
      ),

    );
  }
}



