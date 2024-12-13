import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seatview/API/DatabaseHelper_BookedTables.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> orders = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBookings();
    _loadorderBookings();
  }

  Future<void> _loadBookings() async {
    bookings = await DatabaseHelper().getBookings();
    setState(() {});
  }
  Future<void> _loadorderBookings() async {
    orders = await DatabaseHelper().getOrders();
    setState(() {});
  }

  Future<void> _removeBooking(int id) async {
    await DatabaseHelper().deleteBooking(id);
    _loadBookings(); // Refresh the list after deletion
    _loadorderBookings();
  }
  String _formatOrderDetails(dynamic details) {
    if (details is List) {
      Map<String, int> mealCount = {};

      for (var item in details) {
        String mealName = item['mealName'];
        if (mealCount.containsKey(mealName)) {
          mealCount[mealName] = mealCount[mealName]! + 1;
        } else {
          mealCount[mealName] = 1;
        }
      }

      return mealCount.entries
          .map((entry) => '${entry.value} x ${entry.key}: \$${details.firstWhere((item) => item['mealName'] == entry.key)['price']}')
          .join(', ');
    } else {
      return 'Invalid order details format';
    }
  }






  // Function to show booking details in an alert dialog
  void _showBookingDetails(Map<String, dynamic> booking, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(booking['restaurantName'] ?? 'Unknown Restaurant'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(booking['restaurantImage']),
              const SizedBox(height: 16),
              Text('Table: ${booking['tableNumber']}'),
              Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['date']))}'),
              Text('Time: ${booking['time']}'),
              Text('Order Details: ${_formatOrderDetails(order['orderDetails'])}'),
              Text('Cost: \$${order['totalAmount']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings found'))
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          var booking = bookings[index];
          var order = orders[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => _showBookingDetails(booking,order), // Show details in an alert dialog
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, left: 10),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          booking['restaurantImage'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['restaurantName'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Table: ${booking['tableNumber']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['date']))}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              'Time: ${booking['time']}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Booking'),
                              content: const Text('Are you sure you want to delete this booking?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await _removeBooking(booking['id']);
                        }
                      },
                    ),
                  ],
                ),

              ),
            ),

          );
        },
      ),

    );
  }
}