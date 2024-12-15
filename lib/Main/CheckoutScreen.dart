import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/DatabaseHelper_BookedTables.dart';
import 'package:seatview/Components/menu_provider.dart';

class CheckoutScreen extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Map<String, dynamic> restaurant;

  const CheckoutScreen({
    required this.selectedDate,
    required this.selectedTime,
    required this.restaurant,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final orderedMeals = menuProvider.orderedMeals; // List of meals added to the order
    final totalCost = menuProvider.totalCost; // Get the updated total cost from MenuProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the selected date and time
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${selectedTime.format(context)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Display the list of ordered meals with their prices
            Text(
              'Order Details:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: orderedMeals.length,
                itemBuilder: (context, index) {
                  final meal = orderedMeals[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        meal['mealName'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('${meal['price'].toStringAsFixed(2)} L.E'),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          meal['mealImage'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          menuProvider.removeFromOrder(meal); // Remove item from order
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Display the total cost
            Text(
              'Total Cost: ${totalCost.toStringAsFixed(2)} L.E',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.deepOrange,
              ),
            ),
            const Spacer(),

            // Checkout button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Prepare order data
                  final orderDetails = orderedMeals.map((meal) {
                    return {
                      'mealName': meal['mealName'],
                      'price': meal['price'],
                    };
                  }).toList();

                  Map<String, dynamic> bookingOrder = {
                    'tableNumber': restaurant['tableNumber'],
                    'date': selectedDate.toIso8601String(),
                    'time': selectedTime.format(context),
                    'restaurantName': restaurant['name'],
                    'restaurantImage': restaurant['image'],
                    'orderDetails': jsonEncode(orderDetails),
                    'totalAmount': totalCost,
                  };

                  // Save to database
                  await DatabaseHelper().insertBookingOrder(bookingOrder);

                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Order Confirmed'),
                      content: const Text('Thank you for your purchase!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, 'home'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );

                  // Clear the order in the provider
                  menuProvider.clearOrder();
                },
                child: const Text('Confirm Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}