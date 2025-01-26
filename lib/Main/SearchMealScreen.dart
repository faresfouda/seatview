import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/model/meal.dart';
import 'package:seatview/Components/MealCardWidget.dart';

class SearchScreen extends StatefulWidget {
  final String restaurantId;

  const SearchScreen({required this.restaurantId, Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _searchMeals() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });

    if (_searchQuery.isEmpty) {
      // Fetch all meals if the search query is empty
      Provider.of<MealProvider>(context, listen: false)
          .fetchMeals(widget.restaurantId);
    } else {
      // Perform the search
      Provider.of<MealProvider>(context, listen: false)
          .searchMeals(widget.restaurantId, _searchQuery);
    }

    FocusScope.of(context).unfocus(); // Dismiss the keyboard
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final mealsData = mealProvider.meals;

    void _showMealDetails(Meal meal) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              meal.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            content: SizedBox(
              width: 350, // Set a fixed width to prevent overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      meal.imageUrl,
                      height: 180, // Fixed image height to avoid overflow
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Price: ${meal.price} L.E',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Use SingleChildScrollView to handle long text without overflowing
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      'Details: ${meal.description}',
                      maxLines: 3, // Limit the description to 3 lines
                      overflow: TextOverflow.ellipsis, // Show ellipsis for long text
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Close',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search meals...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            filled: true,
            fillColor: Theme.of(context).canvasColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onSubmitted: (value) => _searchMeals(), // Search on submit
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
                Provider.of<MealProvider>(context, listen: false)
                    .fetchMeals(widget.restaurantId);
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchMeals, // Search when the search icon is pressed
          ),
        ],
      ),
      body: mealProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : mealProvider.hasError
          ? Center(
        child: Text(
          'An error occurred: ${mealProvider.errorMessage}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
          : mealsData.isEmpty
          ? Center(
        child: Text(
          'No meals found for "$_searchQuery"',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 20),
        itemCount: mealsData.length,
        itemBuilder: (context, index) {
          final meal = mealsData[index];
          return MealCardWidget(
            mealName: meal.name,
            mealImage: meal.imageUrl ?? '',
            mealPrice: meal.price ?? 0.0,
            onTap: () {
              _showMealDetails(meal);
            },
            onAddToOrder: () {
              mealProvider.addMealToOrder(meal);
            },
          );
        },
      ),
    );
  }
}
