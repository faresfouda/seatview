import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Meal {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String imagePublicId;
  int quantity; // Add quantity property to the Meal class

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.imagePublicId,
    this.quantity = 1, // Default quantity to 1
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['desc'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image'] != null && json['image']['secure_url'] != null
          ? json['image']['secure_url']
          : 'https://i.pinimg.com/736x/f1/ae/2c/f1ae2cfe01f039a354c1d15238035612.jpg', // Fallback to an empty string if image or URL is null
      imagePublicId: json['image'] != null && json['image']['public_id'] != null
          ? json['image']['public_id']
          : '', // Fallback to an empty string
      quantity: json['quantity'] ?? 1, // Set the quantity from the JSON if available
    );
  }

}




class MealProvider with ChangeNotifier {
  List<Meal> _meals = [];
  bool _isLoading = false;
  List<Meal> _orderedMeals = [];
  double _totalCost = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  List<Meal> get orderedMeals => _orderedMeals;
  double get totalCost => _totalCost;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Fetch meals data from API
  Future<void> fetchMeals(String restaurantId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final url = 'https://restaurant-reservation-sys.vercel.app/meals/restaurant/$restaurantId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final mealsList = responseData['meals'] as List? ?? [];
          List<Meal> loadedMeals = [];

          for (var meal in mealsList) {
            loadedMeals.add(Meal.fromJson(meal));
          }

          _meals = loadedMeals;
        } else {
          print('Failed to fetch meals: ${responseData['message']}');
        }
      } else {
        print('Failed to load data, Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching meals: $e");
      _hasError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add meal to the order
  void addMealToOrder(Meal meal) {
    // Check if the meal already exists in the order
    final existingMealIndex = _orderedMeals.indexWhere((m) => m.id == meal.id);
    if (existingMealIndex >= 0) {
      // Increase quantity if meal already exists
      _orderedMeals[existingMealIndex].quantity++;
    } else {
      // Add as a new item
      _orderedMeals.add(meal);
    }

    // Update total cost
    _totalCost += meal.price;
    notifyListeners();
  }

  // Remove meal from the order
  void removeFromOrder(Meal meal) {
    final existingMealIndex = _orderedMeals.indexWhere((m) => m.id == meal.id);
    if (existingMealIndex >= 0) {
      if (_orderedMeals[existingMealIndex].quantity > 1) {
        // Decrease quantity if more than one
        _orderedMeals[existingMealIndex].quantity--;
        _totalCost -= meal.price;
      } else {
        // Remove meal if only one left
        _totalCost -= _orderedMeals[existingMealIndex].price;
        _orderedMeals.removeAt(existingMealIndex);
      }
    }
    notifyListeners();
  }

  Future<void> searchMeals(String restaurantId, String query) async {
    _isLoading = true;
    notifyListeners();

    final url =
        'https://restaurant-reservation-sys.vercel.app/meals/restaurant/$restaurantId?search=$query';

    print("Request URL: $url");
    print("Request Header: ");

    try {
      final response = await http.get(Uri.parse(url));

      // Print response status and body
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final mealsList = responseData['meals'] as List? ?? [];
          List<Meal> loadedMeals = [];

          for (var meal in mealsList) {
            loadedMeals.add(Meal.fromJson(meal));
          }

          _meals = loadedMeals;
        } else {
          print('Failed to fetch meals: ${responseData['message']}');
        }
      } else {
        print('Failed to load data, Status code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error searching meals: $error");
    }

    _isLoading = false;
    notifyListeners();
  }


  // Clear the order
  void clearOrder() {
    _orderedMeals.clear();
    _totalCost = 0.0;
    notifyListeners();
  }
}

