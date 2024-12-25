import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/reservation_services.dart';
import 'package:seatview/model/meal.dart';
import 'package:seatview/Components/MealCardWidget.dart'; // Import the MealCardWidget

class CheckoutScreen extends StatefulWidget {
  final DateTime selectedDate ;
  final TimeOfDay selectedTime;
  final Map<String, dynamic> restaurant;
  final String selectedTable;
  final String token; // Pass the token as a parameter

  const CheckoutScreen({
    required this.selectedDate,
    required this.selectedTime,
    required this.restaurant,
    required this.selectedTable,
    required this.token, // Include token as a parameter
    Key? key,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MealProvider>(context);
    final orderedMeals = menuProvider.orderedMeals; // List of meals added to the order
    final totalCost = menuProvider.totalCost; // Get the updated total cost from MenuProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the selected date and time
                Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: ${widget.selectedTime.format(context)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Display the list of ordered meals
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
                      return CheckoutMealCardWidget(
                        mealName: meal.name,
                        mealImage: meal.imageUrl,
                        mealPrice: meal.price ?? 0.0,
                        onRemove: () {
                          menuProvider.removeFromOrder(meal); // Remove the meal from the order
                        },
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                      setState(() => _isLoading = true);
                      try {
                        // Prepare meal data (mealId and quantity)
                        final mealData = orderedMeals.map((meal) {
                          return {
                            "meal": meal.id,
                            "quantity": meal.quantity ?? 1, // Default quantity to 1 if not available
                          };
                        }).toList();

                        // Call the ReservationService to create the reservation
                        final reservationService = ReservationService();
                        final response = await reservationService.createReservation(
                          token: widget.token,
                          tableId: widget.selectedTable.toString(),
                          restaurantId: widget.restaurant['id'],
                          date: DateFormat('MM-dd-yyyy').format(widget.selectedDate),
                          time: widget.selectedTime.format(context),
                          mealId: mealData, // Pass the list of meal objects
                        );

                        if (response['message'] == 'Reservation created successfully') {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reservation Confirmed'),
                              content: Text(
                                  'Your reservation has been made for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)} at ${widget.selectedTime.format(context)}.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    'home',
                                        (Route<dynamic> route) => false,
                                  ),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Show error message
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(response['message'] ?? 'An unexpected error occurred.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } finally {
                        setState(() => _isLoading = false);
                        menuProvider.clearOrder();
                      }
                    },



                    child: const Text('Confirm Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
