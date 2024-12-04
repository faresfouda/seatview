import 'package:flutter/material.dart';
import 'package:seatview/API/restaurant_list.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredList = restaurantList;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRestaurants(String query) {
    setState(() {
      filteredList = restaurantList.where((restaurant) {
        final title = (restaurant['title'] ?? '').toLowerCase();
        final location = (restaurant['location'] ?? '').toLowerCase();
        final tags = (restaurant['tags'] as List<dynamic>? ?? []).join(', ').toLowerCase();

        return title.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase()) ||
            tags.contains(query.toLowerCase());
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          onChanged: _filterRestaurants,
          decoration: InputDecoration(
            hintText: "Search by name, Location, or tag",
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              _filterRestaurants('');
            },
          ),
        ],
      ),
      body: filteredList.isEmpty
          ? Center(
        child: Text(
          'No results found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final restaurant = filteredList[index];
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(restaurant['imageUrl']),
              ),
              title: Text(restaurant['title']),
              subtitle: Text(restaurant['description']),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  'RestaurantAboutScreen',  // Make sure this is the correct route
                  arguments: restaurant,  // Pass restaurant data
                );
              },
            ),
          );
        },
      ),
    );
  }
}
