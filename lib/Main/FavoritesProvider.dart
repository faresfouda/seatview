import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoritesProvider with ChangeNotifier {
  final List<String> _favoriteRestaurantIds = [];
  String? userToken;

  // Getter for favorite restaurant IDs
  List<String> get favoriteRestaurantIds => _favoriteRestaurantIds;

  // Check if a restaurant is a favorite
  bool isFavorite(String restaurantId) {
    return _favoriteRestaurantIds.contains(restaurantId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String restaurantId, String token) async {
    if (isFavorite(restaurantId)) {
      await removeFavoriteFromServer(restaurantId, token);
    } else {
      await addFavoriteToServer(restaurantId, token);
    }
    notifyListeners();
  }

  // Add a restaurant to favorites on the server
  Future<void> addFavoriteToServer(String restaurantId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://restaurant-reservation-sys.vercel.app/users/favorites/add'),
        headers: {
          'token': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'restaurantId': restaurantId}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        _favoriteRestaurantIds.add(restaurantId); // Update local state
      } else {
        print(response.body);
        throw Exception('Failed to add favorite');
      }
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  // Remove a restaurant from favorites on the server
  Future<void> removeFavoriteFromServer(String restaurantId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://restaurant-reservation-sys.vercel.app/users/favorites/remove'),
        headers: {
          'token': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'restaurantId': restaurantId}),
      );

      if (response.statusCode == 200) {
        _favoriteRestaurantIds.remove(restaurantId); // Update local state
      } else {
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  // Get all favorite restaurants from the server
  Future<void> getFavorites(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://restaurant-reservation-sys.vercel.app/users/favorites/'),
        headers: {
          'token': token,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Check if the "data" field exists and is a list
        if (data['data'] is List) {
          final List<dynamic> favorites = data['data'];

          // Debug print to check the data structure
          print('Favorites data: $favorites');

          // Clear existing data and update the favorite restaurants list
          _favoriteRestaurantIds.clear();
          for (var restaurant in favorites) {
            _favoriteRestaurantIds.add(restaurant['_id']);
          }

          notifyListeners(); // Notify listeners after updating the list
        } else {
          print('Favorites data field is not a list');
        }
      } else {
        print('Failed to load favorites: ${response.body}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      rethrow;
    }
  }

  Future<void> fetchFavorites(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://restaurant-reservation-sys.vercel.app/users/favorites/'),
        headers: {
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['data'] is List) {
          final List<dynamic> favorites = data['data'];

          _favoriteRestaurantIds.clear();
          for (var restaurant in favorites) {
            _favoriteRestaurantIds.add(restaurant['_id']);
          }

          notifyListeners();
        } else {
          print('Favorites data field is not a list');
        }
      } else {
        print('Failed to load favorites: ${response.body}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      rethrow;
    }
  }

}
