import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  // Getter to retrieve the favorite restaurants
  List<Map<String, dynamic>> get favorites => _favorites;

  // Method to add a restaurant to favorites
  void addFavorite(Map<String, dynamic> item) {
    if (!isFavorite(item)) {
      _favorites.add(item);
      notifyListeners();
    }
  }

  // Method to remove a restaurant from favorites
  void removeFavorite(Map<String, dynamic> item) {
    _favorites.removeWhere((favorite) => favorite['title'] == item['title']);
    notifyListeners();
  }

  void toggleFavorite(FavoritesProvider favoritesProvider, Map<String, dynamic> restaurant, bool isFavorite) {
    if (isFavorite) {
      favoritesProvider.removeFavorite(restaurant);
    } else {
      favoritesProvider.addFavorite(restaurant);
    }
  }

  // Check if the restaurant is already in favorites
  bool isFavorite(Map<String, dynamic> item) {
    return _favorites.any((favorite) => favorite['title'] == item['title']);
  }
}
