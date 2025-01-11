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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MealProvider>(context, listen: false);
      menuProvider.fetchMeals(widget.restaurant['id']);
      print(menuProvider.meals);
    });
  }


  void _showMealDetails(Meal meal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            meal.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: SizedBox(
            width: 350, // Set a fixed width to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    meal.imageUrl,
                    height: 180, // Fixed image height to avoid overflow
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Price: ${meal.price} L.E',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Use SingleChildScrollView to handle long text without overflowing
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    'Details: ${meal.description}',
                    maxLines: 3, // Limit the description to 3 lines
                    overflow: TextOverflow.ellipsis, // Show ellipsis for long text
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
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
        title: Text(
          'Menu - ${widget.restaurant['name']}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: menuProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : mealsData.isEmpty
          ? Center(
        child: Text(
          "No meals available",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 9.0,
              mainAxisSpacing: 11.0,
              childAspectRatio: 0.8,
            ),
            itemCount: mealsData.length,
            itemBuilder: (context, index) {
              final meal = mealsData[index];
              return MealCardWidget(
                mealName: meal.name,
                mealImage: meal.imageUrl??'',
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
          'Checkout (${menuProvider.orderedMeals.length} items) - ${menuProvider.totalCost.toStringAsFixed(2)} L.E',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        icon: Icon(
          FontAwesomeIcons.dollarSign,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                selectedDate: widget.selectedDate,
                selectedTime: widget.selectedTime,
                restaurant: widget.restaurant,
                selectedTable: widget.selectedTable,
                token: user.token ?? "", // Pass the token here
              ),
            ),
          );
        },
      ),
    );
  }
}
