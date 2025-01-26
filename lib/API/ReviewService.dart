import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

class ReviewService {
  // Function to show the review dialog with star rating
  static void showReview(
      BuildContext context,
      String token,
      Map<String, dynamic> bookingOrder,
      Function() onReviewSubmitted,
      ) {
    TextEditingController reviewController = TextEditingController();
    double rating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (value) {
                  rating = value;
                },
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(hintText: 'Enter your review'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                submitReview(
                  token,
                  bookingOrder['_id'],
                  reviewController.text,
                  rating,
                ).then((result) {
                  final success = result['success'];
                  final errorMessage = result['errorMessage'];

                  Navigator.pop(context); // Close the review dialog

                  // Show success or error popup
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              success ? Icons.check_circle : Icons.error,
                              color: success ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(success ? 'Success' : 'Error'),
                          ],
                        ),
                        content: Text(success
                            ? 'Review submitted successfully!'
                            : errorMessage ?? 'Failed to submit review. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the confirmation popup
                              if (success) onReviewSubmitted(); // Refresh bookings if successful
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              child: const Text('Submit'),
            ),

          ],
        );
      },
    );
  }

  // Function to submit the review with rating
  static Future<Map<String, dynamic>> submitReview(
      String token,
      String reservationId,
      String review,
      double rating,
      ) async {
    if (token.isEmpty) {
      print('Token is missing');
      return {'success': false, 'errorMessage': 'Authentication token is missing.'};
    }

    final uri = Uri.parse('https://restaurant-reservation-sys.vercel.app/reviews/create');
    final headers = {
      'token': token,
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'reservationId': reservationId,
      'comment': review,
      'rate': rating,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('Review submitted successfully');
          return {'success': true};
        } else {
          return {'success': false, 'errorMessage': data['message']};
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {'success': false, 'errorMessage': data['message']};
      } else {
        return {'success': false, 'errorMessage': 'Unexpected error occurred.'};
      }
    } catch (error) {
      print('Error occurred while submitting review: $error');
      return {'success': false, 'errorMessage': 'Failed to connect to the server.'};
    }
  }




  // Function to delete a reservation
  static Future<bool> deleteReservation(String token, String reservationId) async {
    if (token.isEmpty) {
      print('Token is missing');
      return false;
    }

    final response = await http.delete(
      Uri.parse('https://restaurant-reservation-sys.vercel.app/reservations/delete/$reservationId'),
      headers: {
        'token': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        print(response.body);
        print('Reservation deleted successfully');
        return true;
      } else {
        print(response.body);
        print('Error: ${data['message']}');
      }
    } else {
      print(response.body);
      print('Failed to delete reservation');
      print(response.body);
    }
    return false;
  }
}
