import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seatview/API/DatabaseHelper_BookedTables.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> bookingsOrders = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBookingsOrders();
  }

  Future<void> _loadBookingsOrders() async {
    bookingsOrders = await DatabaseHelper().getBookingsOrders();
    setState(() {});
  }

  Future<void> _removeBookingOrder(int id) async {
    await DatabaseHelper().deleteBookingOrder(id);
    _loadBookingsOrders(); // Refresh the list after deletion
  }

  String _formatOrderDetails(dynamic details) {
    if (details == null) {
      return 'Invalid order details format';
    }

    if (details is String) {
      // Ensure both keys and values are properly quoted
      details = details.replaceAll("'", '"').replaceAllMapped(
          RegExp(r'(\w+): ([^,}]+)'),
              (match) => '"${match[1]}": "${match[2]?.replaceAll('"', '').trim()}"'
      );
      try {
        details = jsonDecode(details);
      } catch (e) {
        print('Error decoding JSON: $e');
        return 'Invalid order details format';
      }
    }

    if (details is List) {
      Map<String, Map<String, dynamic>> mealCount = {};

      for (var item in details) {
        String mealName = item['mealName'];
        double price = item['price'] is String ? double.tryParse(item['price']) ?? 0.0 : item['price'];
        if (mealCount.containsKey(mealName)) {
          mealCount[mealName]!['count']++;
          mealCount[mealName]!['totalPrice'] += price;
        } else {
          mealCount[mealName] = {'count': 1, 'totalPrice': price};
        }
      }

      return mealCount.entries
          .map((entry) => '${entry.value['count']} x ${entry.key}: \$${entry.value['totalPrice'].toStringAsFixed(2)}')
          .join(', ');
    } else {
      return 'Invalid order details format';
    }
  }

  // Function to show booking details in an alert dialog
  void _showBookingDetails(Map<String, dynamic> bookingOrder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            bookingOrder['restaurantName'] ?? 'Unknown Restaurant',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bookingOrder['restaurantImage'] != null && bookingOrder['restaurantImage'].isNotEmpty) ...[
                  Image.network(
                    bookingOrder['restaurantImage'],
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Failed to load image');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Icon(Icons.table_chart),
                    const SizedBox(width: 8),
                    Text('Table: ${bookingOrder['tableNumber']}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.date_range),
                    const SizedBox(width: 8),
                    Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(bookingOrder['date']))}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text('Time: ${bookingOrder['time']}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.receipt),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Order Details: ${_formatOrderDetails(bookingOrder['orderDetails'])}'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money),
                    const SizedBox(width: 8),
                    Text('Cost: \$${bookingOrder['totalAmount']}'),
                  ],
                ),
              ],
            ),
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
      body: bookingsOrders.isEmpty
          ? const Center(child: Text('No bookings found'))
          : ListView.builder(
        itemCount: bookingsOrders.length,
        itemBuilder: (context, index) {
          var bookingOrder = bookingsOrders[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => _showBookingDetails(bookingOrder), // Show details in an alert dialog
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
                        child: bookingOrder['restaurantImage'] != null && bookingOrder['restaurantImage'].isNotEmpty
                            ? Image.network(
                          bookingOrder['restaurantImage'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text('Failed to load image');
                          },
                        )
                            : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                          child: Icon(Icons.error),
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
                              bookingOrder['restaurantName'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Table: ${bookingOrder['tableNumber']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(bookingOrder['date']))}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              'Time: ${bookingOrder['time']}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            if (bookingOrder['orderDetails'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Order Details: ${_formatOrderDetails(bookingOrder['orderDetails'])}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cost: \$${bookingOrder['totalAmount']}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
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
                          await _removeBookingOrder(bookingOrder['id']);
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