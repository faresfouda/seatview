import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;
import 'package:seatview/Components/theme.dart';
import 'package:seatview/model/user.dart'; // Adjust the theme import based on your project setup

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool isNegative = false; // Toggle for negative/positive reviews
  List<dynamic> reviews = []; // List of reviews
  int positiveReviewCount = 0; // Counter for positive reviews
  int negativeReviewCount = 0; // Counter for negative reviews
  bool isLoading = true; // For loading state

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final restaurantId = userProvider.user?.restaurant ?? '';

    if (restaurantId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url =
        'https://restaurant-reservation-sys.vercel.app/reviews/restaurant/$restaurantId';

    // Debugging request and response
    print('Request URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Count positive and negative reviews
        final allReviews = data['data'];
        positiveReviewCount =
            allReviews.where((review) => review['isNegative'] == false).length;
        negativeReviewCount =
            allReviews.where((review) => review['isNegative'] == true).length;

        setState(() {
          reviews = allReviews
              .where((review) => review['isNegative'] == isNegative)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching reviews: $error');
    }
  }

  void toggleReviewType() {
    setState(() {
      isNegative = !isNegative;
      isLoading = true;
    });
    fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white, // Ensure title is visible
          ),
        ),
        backgroundColor: Colors.red, // Assuming app bar is red
        actions: [
          Row(
            children: [
              Text(
                isNegative ? 'Negative' : 'Positive',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white, // Text color for contrast
                ),
              ),
              Switch(
                value: isNegative,
                onChanged: (value) {
                  toggleReviewType();
                },
                activeColor: Colors.white, // White thumb for contrast
                inactiveThumbColor: Colors.white, // White thumb for contrast
                inactiveTrackColor: Colors.green.withOpacity(1), // Subtle green
                activeTrackColor: Colors.yellow.withOpacity(0.7), // Subtle red
              ),
            ],
          ),
        ],
      ),


      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Positive: $positiveReviewCount',
                  style: TextStyle(color: Colors.green),
                ),
                Text(
                  'Negative: $negativeReviewCount',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          Expanded(
            child: reviews.isEmpty
                ? Center(child: Text('No reviews available'))
                : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  elevation: 3, // Slight shadow for a clean look
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded edges
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(Icons.star, color: Colors.amber),
                    ),
                    title: Text(
                      review['userId']['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "${review['comment'] ?? 'No comment'}\n${DateFormat('MMM d, yyyy').format(DateTime.parse(review['createdAt']))}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4, // Line height for better readability
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        review['rate']?.toInt() ?? 0,
                            (index) => Icon(Icons.star, color: Colors.amber, size: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
