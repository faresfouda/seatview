import 'package:flutter/material.dart';

class RestaurantBookingScreen extends StatefulWidget {
  @override
  _RestaurantBookingScreenState createState() =>
      _RestaurantBookingScreenState();
}

class _RestaurantBookingScreenState extends State<RestaurantBookingScreen> {
  int? selectedTable; // To keep track of the selected table

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Book a Table',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name
            const Text(
              'Restaurant Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Select a table to book:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // List of tables
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Example: 10 tables
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTable = index; // Select the tapped table
                      });
                    },
                    child: Card(
                      color: selectedTable == index
                          ? Colors.red[100]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selectedTable == index
                              ? Colors.red
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.chair,
                          color: Colors.red,
                          size: 32,
                        ),
                        title: Text(
                          'Table ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Seats: 4'),
                        trailing: selectedTable == index
                            ? const Icon(
                          Icons.check_circle,
                          color: Colors.red,
                        )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Book Now Button
            ElevatedButton(
              onPressed: selectedTable != null
                  ? () {
                // Perform booking logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Table ${selectedTable! + 1} booked successfully!'),
                  ),
                );
              }
                  : null, // Disable button if no table is selected
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
