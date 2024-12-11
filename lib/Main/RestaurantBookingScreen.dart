import 'package:flutter/material.dart';
import 'package:seatview/Components/ElevatedButton.dart';
import 'package:seatview/Main/BookingTime.dart';

class RestaurantBookingScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant; // Add restaurant parameter

  const RestaurantBookingScreen({required this.restaurant, Key? key})
      : super(key: key);

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
                physics: const BouncingScrollPhysics(),
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
                        subtitle: const Text('Seats: 4'),
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

            // Options for booking
            if (selectedTable != null)
              Column(
                children: [
                  CustomElevatedButton(
                    onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingTime(selectedTable: selectedTable!, isOrder: false, restaurant: widget.restaurant,),
                          ),
                        );



                    },
                    buttonText: 'Book Only',
                  ),

                  const SizedBox(height: 16),

                  CustomElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingTime(selectedTable: selectedTable!, isOrder: true,restaurant: widget.restaurant,),
                        ),
                      );
                      // Logic for booking the table and making an order
                      /*ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Table ${selectedTable! + 1} booked, proceed to order!'),
                        ),
                      );*/
                    },
                    buttonText: 'Book and Order',
                  ),

                ],
              ),
          ],
        ),
      ),
    );
  }
}
