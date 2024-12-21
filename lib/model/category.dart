import 'meal.dart';

class Category {
  final String categoryName;
  final List<Meal> meals;

  Category({
    required this.categoryName,
    required this.meals,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryName: json['categoryName'],
      meals: List<Meal>.from(json['meals'].map((x) => Meal.fromJson(x))),
    );
  }
}
