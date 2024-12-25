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
      imageUrl: json['image']['secure_url'] ?? '',
      imagePublicId: json['image']['public_id'] ?? '',
      quantity: json['quantity'] ?? 1, // Set the quantity from the JSON if available
    );
  }
}




class MealProvider with ChangeNotifier {
  List<Meal> _meals = [];
  bool _isLoading = false;
  List<Meal> _orderedMeals = [];
  double _totalCost = 0.0;

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  List<Meal> get orderedMeals => _orderedMeals;
  double get totalCost => _totalCost;

  // Fetch meals data from API
  Future<void> fetchMeals(String restaurantId) async {
    _isLoading = true;
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
    } catch (error) {
      print("Error fetching meals: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add meal to the order
  void addMealToOrder(Meal meal) {
    _orderedMeals.add(meal);
    _totalCost += meal.price ?? 0.0;
    notifyListeners();
  }

  // Remove meal from the order
  void removeFromOrder(Meal meal) {
    _orderedMeals.remove(meal);
    _totalCost -= meal.price ?? 0.0;
    notifyListeners();
  }

  // Clear the order
  void clearOrder() {
    _orderedMeals.clear();
    _totalCost = 0.0;
    notifyListeners();
  }
}
