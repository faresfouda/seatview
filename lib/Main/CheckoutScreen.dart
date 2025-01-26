import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/reservation_services.dart';
import 'package:seatview/model/meal.dart';
import 'package:seatview/Components/MealCardWidget.dart';
import 'package:seatview/Components/theme.dart';

class CheckoutScreen extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Map<String, dynamic> restaurant;
  final String selectedTable;
  final String token;

  const CheckoutScreen({
    required this.selectedDate,
    required this.selectedTime,
    required this.restaurant,
    required this.selectedTable,
    required this.token,
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
    final orderedMeals = menuProvider.orderedMeals;
    final totalCost = menuProvider.totalCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Section with an icon
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time Section with an icon
                Row(
                  children: [
                    Icon(Icons.access_time, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Time: ${widget.selectedTime.format(context)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Order Details Section with meal cards
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
                        quantity: meal.quantity,
                        onRemove: () {
                          menuProvider.removeFromOrder(meal);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Total Cost Section with a card
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.monetization_on, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Total Cost:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${totalCost.toStringAsFixed(2)} L.E',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Checkout Button with professional styling
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      setState(() => _isLoading = true);
                      try {
                        final mealData = orderedMeals.map((meal) {
                          return {
                            "meal": meal.id,
                            "quantity": meal.quantity ?? 1,
                          };
                        }).toList();

                        final reservationService = ReservationService();
                        final response = await reservationService.createReservation(
                          token: widget.token,
                          tableId: widget.selectedTable.toString(),
                          restaurantId: widget.restaurant['id'],
                          date: DateFormat('MM-dd-yyyy').format(widget.selectedDate),
                          time: widget.selectedTime.format(context),
                          mealId: mealData,
                        );

                        if (response['message'] == 'Reservation created successfully') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reservation Confirmed'),
                              content: Text(
                                'Your reservation has been made for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)} at ${widget.selectedTime.format(context)}.',
                              ),
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
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
