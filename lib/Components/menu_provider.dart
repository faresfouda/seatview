// import 'package:flutter/material.dart';
//
//
//
// class MenuProvider with ChangeNotifier {
//   final List<Map<String, dynamic>> _favoriteMeals = [];
//   double _totalCost = 0.0;
//
//   List<Map<String, dynamic>> get favoriteMeals => _favoriteMeals;
//   List<Map<String, dynamic>> _orderedMeals = [];
//   List<Map<String, dynamic>> get orderedMeals => _orderedMeals;
//
//   double get totalCost => _totalCost;
//
//   void toggleFavorite(Map<String, dynamic> meal) {
//     if (_favoriteMeals.contains(meal)) {
//       _favoriteMeals.remove(meal);
//     } else {
//       _favoriteMeals.add(meal);
//     }
//     notifyListeners();
//   }
//
//   void addToOrder(Map<String, dynamic> meal) {
//     _orderedMeals.add(meal);
//     _totalCost += meal['price'];
//     notifyListeners();
//   }
//
//   void removeFromOrder(Map<String, dynamic> meal) {
//     _orderedMeals.remove(meal);
//     _totalCost -= meal['price'];
//     notifyListeners();
//   }
//
//   void resetOrder() {
//     _totalCost = 0.0;
//     notifyListeners();
//   }
//
//   // New function to clear the order
//   void clearOrder() {
//     _orderedMeals.clear(); // Clear all items in the ordered meals list
//     _totalCost = 0.0;      // Reset the total cost to 0
//     notifyListeners();     // Notify listeners to update the UI
//   }
// }

