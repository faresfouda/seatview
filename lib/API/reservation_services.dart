import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seatview/model/meal.dart';

class ReservationService {
  // Base URL for the API (adjust as necessary)
  static const String baseUrl = 'https://restaurant-reservation-sys.vercel.app';

  // Create a reservation
  Future<Map<String, dynamic>> createReservation({
    required String token,
    required String tableId,
    required String restaurantId,
    required String date,
    required String time,
    required List<Map<String, dynamic>> mealId, // List of meal objects with meal and quantity
  }) async {
    // Endpoint for creating a reservation
    final url = Uri.parse('$baseUrl/reservations/create');

    // Create the request body
    final body = json.encode({
      'tableId': tableId,
      'restaurantId': restaurantId,
      'date': date,
      'time': time,
      'mealId': mealId, // List of meal objects
    });

    // Set the headers
    final headers = {
      'Content-Type': 'application/json',
      'token': '$token',
    };

    try {
      // Send the POST request
      final response = await http.post(url, headers: headers, body: body);
      print(body);

      if (response.statusCode == 200) {
        print(response.body);
        // Successful response, parse the JSON
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
          'reservation': responseData['reservation'],
        };
      } else {
        print(response.body);
        // Handle error response
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'An error occurred',
        };
      }
    } catch (error) {
      print(error);
      // Handle network errors or exceptions
      return {
        'success': false,
        'message': 'Failed to make the reservation. Please try again.',
      };
    }
  }

}
