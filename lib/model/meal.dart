class Meal {
  final String mealName;
  final String mealImage;
  final bool mealFavorites;
  final double price;
  final String description;

  Meal({
    required this.mealName,
    required this.mealImage,
    required this.mealFavorites,
    required this.price,
    required this.description,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealName: json['mealName'],
      mealImage: json['mealImage'],
      mealFavorites: json['mealFavorites'],
      price: json['price'],
      description: json['description'],
    );
  }
}
