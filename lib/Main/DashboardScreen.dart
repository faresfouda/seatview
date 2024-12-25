import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:seatview/API/ReviewService.dart';
import 'package:seatview/model/user.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> bookingsOrders = [];

  @override
  void initState() {
    super.initState();
    _loadBookingsOrders(); // Fetch the bookings orders when the screen is initialized
  }

  // Retrieve token from UserProvider
  String _getToken() {
    final userProvider = Provider.of<UserProvider>(context, listen: false); // Access the UserProvider
    return userProvider.token ?? ''; // Return the token or an empty string if null
  }

  Future<void> _loadBookingsOrders() async {
    String token = _getToken(); // Get the token

    if (token.isEmpty) {
      print('Token is missing');
      return;
    }

    final response = await http.get(
      Uri.parse('https://restaurant-reservation-sys.vercel.app/reservations/user'),
      headers: {
        'token': '$token', // Include the token in the Authorization header
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          bookingsOrders = List<Map<String, dynamic>>.from(data['reservations']);
        });
      } else {
        print('Error: ${data['message']}');
      }
    } else {
      print('Failed to load data');
    }
  }

  // Calculate total cost for the order
  // Calculate total cost for the order
  double _calculateTotalCost(Map<String, dynamic> bookingOrder) {
    double totalCost = 0;
    if (bookingOrder['mealId'] != null) {
      totalCost = bookingOrder['mealId'].fold(0.0, (sum, meal) {
        double price = double.tryParse(meal['meal']['price'].toString()) ?? 0.0; // Get meal price
        int quantity = int.tryParse(meal['quantity'].toString()) ?? 0; // Get meal quantity
        return sum + (price * quantity); // Add price * quantity to the sum
      });
    }
    return totalCost;
  }


  // Function to show booking details in an alert dialog
  void _showBookingDetails(Map<String, dynamic> bookingOrder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime bookingDate = _parseDate(bookingOrder['date']);
        double totalCost = _calculateTotalCost(bookingOrder);

        return AlertDialog(
          title: Text(
            bookingOrder['restaurantId']['name'] ?? 'Unknown Restaurant',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Table: ${bookingOrder['tableId']['tableNumber']}'),
                Text('Date: ${DateFormat('MM-dd-yyyy').format(bookingDate)}'),
                Text('Time: ${bookingOrder['time']}'),
                const SizedBox(height: 8),
                ...bookingOrder['mealId'].map<Widget>((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.fastfood, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Meal: ${meal['meal']['name']} - Quantity: ${meal['quantity']}'),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                Text(
                  'Total Cost: ${totalCost.toStringAsFixed(2)} EGP',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (bookingOrder['status'] == 'completed')
              TextButton(
                onPressed: () {
                  String token = _getToken();
                  ReviewService.showReview(
                    context,
                    token,
                    bookingOrder,
                    _loadBookingsOrders,
                  );
                },
                child: const Text('Write a Review'),
              ),
            // Remove button with enhanced style
            TextButton(
              onPressed: () async {
                String reservationId = bookingOrder['_id'];
                String token = _getToken();

                // Call the delete function
                await ReviewService.deleteReservation(token, reservationId);

                // Reload the bookings orders to refresh the UI
                setState(() {
                  _loadBookingsOrders();
                });

                // Close the dialog
                Navigator.pop(context);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Bookings'),
        backgroundColor: Colors.red[900],
      ),
      body: bookingsOrders.isEmpty
          ? const Center(child: Text('No bookings found'))
          : ListView.builder(
        itemCount: bookingsOrders.length,
        itemBuilder: (context, index) {
          var bookingOrder = bookingsOrders[index];
          double totalCost = _calculateTotalCost(bookingOrder);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => _showBookingDetails(bookingOrder), // Show details in an alert dialog
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, left: 10),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        child: Container(
                          width: 100, // Constrain image width
                          height: 100, // Constrain image height
                          color: Colors.grey,
                          child: bookingOrder['restaurantId']['profileImage']?['secure_url'] != null
                              ? Image.network(
                            '${bookingOrder['restaurantId']['profileImage']['secure_url']}',
                            fit: BoxFit.cover, // Ensure image fits within the constraints
                          )
                              : const Icon(Icons.image, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded( // Ensures text content takes up remaining space without overflowing
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookingOrder['restaurantId']['name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis, // Prevents text overflow
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Table: ${bookingOrder['tableId']['tableNumber']}',
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${_formatBookingDate(bookingOrder['date'])}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              'Time: ${bookingOrder['time']}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ...bookingOrder['mealId'].map<Widget>((meal) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.fastfood, size: 16, color: Colors.green),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Order details ${meal['meal']['name']} - Quantity: ${meal['quantity']}',
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis, // Prevents text overflow
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                            Text(
                              'Total: ${totalCost.toStringAsFixed(2)} EGP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ),
          );
        },
      ),
    );
  }

  // Helper function to format date properly with fallback
  String _formatBookingDate(String date) {
    try {
      final DateTime parsedDate = _parseDate(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      print('Invalid date format: $date');
      return 'Invalid date'; // Fallback string for invalid dates
    }
  }

  // Helper function to try parsing different date formats
  DateTime _parseDate(String date) {
    List<String> formats = ['MM-dd-yyyy', 'dd-MM-yyyy'];
    for (var format in formats) {
      try {
        return DateFormat(format).parseStrict(date);
      } catch (e) {
        continue;
      }
    }
    throw FormatException("Invalid date format: $date"); // If no format works, throw an exception
  }
}
