import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seatview/model/restaurant.dart';


class RestaurantService {
  final String baseUrl = 'https://restaurant-reservation-sys.vercel.app';  // Replace with your actual API URL

  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the data
      final data = json.decode(response.body)['data']['restaurants'] as List;
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
}
