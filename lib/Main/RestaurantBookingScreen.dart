import 'dart:convert'; // For jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'package:provider/provider.dart';
import 'package:seatview/Components/ElevatedButton.dart';
import 'package:seatview/Main/BookingTime.dart';
import 'package:seatview/model/user.dart';

class RestaurantBookingScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant; // Add restaurant parameter

  const RestaurantBookingScreen({required this.restaurant, Key? key})
      : super(key: key);

  @override
  _RestaurantBookingScreenState createState() =>
      _RestaurantBookingScreenState();
}

class _RestaurantBookingScreenState extends State<RestaurantBookingScreen> {
  int? selectedTableIndex; // To keep track of the selected table index
  List<Map<String, dynamic>> tables = []; // List to store tables
  bool noAvailableTables = false; // To track if there are no available tables

  @override
  void initState() {
    super.initState();
    fetchTables(); // Fetch the tables when the widget is initialized
  }

  // Fetch tables from the API
  Future<void> fetchTables() async {
    final restaurantId = widget.restaurant['id']; // Get restaurant ID
    final url =
        'https://restaurant-reservation-sys.vercel.app/tables/restaurant/$restaurantId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);

        // Check if the 'data' key is null or empty
        if (data['data'] == null || data['data'].isEmpty) {
          setState(() {
            noAvailableTables = true; // Set flag if no tables are available
            tables = []; // Ensure tables is empty
          });
        } else {
          setState(() {
            noAvailableTables = false; // Reset the flag if tables are available
            tables = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      } else {
        // Handle the error here if the request fails
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      // Handle the exception here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
            Text(
              widget.restaurant['name'] ?? 'Restaurant Name',
              style: const TextStyle(
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

            // Check if no tables are available
            if (noAvailableTables)
              const Center(
                child: Text(
                  'No available tables at the moment.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              )
            else
            // List of tables fetched from the API
              Expanded(
                child: tables.isEmpty
                    ? const Center(
                  child: CircularProgressIndicator(),
                ) // Show loading indicator while fetching
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    final imageUrl = table['image']?['secure_url']; // Safely access the image URL
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTableIndex = index; // Select the tapped table
                        });
                      },
                      child: Card(
                        color: selectedTableIndex == index
                            ? Colors.red[100]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: selectedTableIndex == index
                                ? Colors.red
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Display Table Image
                            imageUrl != null
                                ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 150, // Larger height for better visibility
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
                            )
                                : Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.chair, // Fallback icon if no image is available
                                color: Colors.red,
                                size: 48,
                              ),
                            ),

                            // Table Details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(
                                  'Table ${table['tableNumber']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Seats: ${table['capacity']}'),
                                trailing: selectedTableIndex == index
                                    ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.red,
                                )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )


              ),

            // Options for booking
            if (selectedTableIndex != null)
              Column(
                children: [
                  CustomElevatedButton(
                    onPressed: () {
                      final selectedTableNumber =
                      tables[selectedTableIndex!]['tableNumber'];
                      final selectedTableId =
                      tables[selectedTableIndex!]['_id'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingTime(
                            token: userProvider.token??'',
                            selectedTable: selectedTableNumber,
                            isOrder: false,
                            restaurant: widget.restaurant, selectedTableId: selectedTableId,
                          ),
                        ),
                      );
                    },
                    buttonText: 'Book Only',
                  ),
                  const SizedBox(height: 16),
                  CustomElevatedButton(
                    onPressed: () {
                      final selectedTableNumber =
                      tables[selectedTableIndex!]['tableNumber'];
                      final selectedTableId =
                      tables[selectedTableIndex!]['_id'];
                      print(selectedTableNumber);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingTime(
                            selectedTable: selectedTableNumber,
                            isOrder: true,
                            restaurant: widget.restaurant, selectedTableId: selectedTableId,
                          ),
                        ),
                      );
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