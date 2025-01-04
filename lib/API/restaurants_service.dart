import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seatview/model/restaurant.dart';
import 'package:seatview/model/user.dart';


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






class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  Restaurant? _restaurant;
  bool _isLoading = false;
  String? _errorMessage;

  List<Restaurant> get restaurants => _restaurants;

  Restaurant? get restaurant => _restaurant;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // Fetch all restaurants
  Future<void> fetchRestaurants() async {
    try {
      _restaurants = await _restaurantService.fetchRestaurants();
      notifyListeners(); // Notify all listeners about the change
    } catch (e) {
      print("Error fetching restaurants: $e");
      throw Exception("Failed to load restaurants");
    }
  }

  // Fetch a single restaurant by ID
  Future<void> fetchRestaurant(String restaurantId, String token) async {
    print("Fetching restaurant with ID: $restaurantId...");
    _isLoading = true;
    _errorMessage = null;

    // Schedule state change after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final url = 'https://restaurant-reservation-sys.vercel.app/restaurants/$restaurantId';
    print("Making GET request to $url...");

    try {
      final response = await http.get(
          Uri.parse(url), headers: {'token': token});
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Fetched restaurant data: $data");
        _restaurant = Restaurant.fromJson(data['restaurant']);
        _isLoading = false;

        // Notify listeners after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        _errorMessage = 'Failed to load restaurant data';
        _isLoading = false;
        print("Error: ${response.body}");

        // Notify listeners after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      print("Error while fetching: $e");

      // Notify listeners after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Update a restaurant
  Future<void> updateRestaurant({
    required String restaurantId,
    required String token,
    required String name,
    required String address,
    required String phone,
    required String openingHours,
    required File? profileImage,
    required File? layoutImage,
    required List<File> galleryImages,
  }) async {
    print("Updating restaurant with ID: $restaurantId...");
    _isLoading = true;
    _errorMessage = null;

    // Schedule state change after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final url = 'https://restaurant-reservation-sys.vercel.app/restaurants/update/$restaurantId';
    print("Making PUT request to $url...");

    try {
      // Prepare the multipart request
      var request = http.MultipartRequest('PUT', Uri.parse(url))
        ..headers['token'] = token
        ..fields['name'] = name
        ..fields['address'] = address
        ..fields['phone'] = phone
        ..fields['openingHours'] = openingHours;

      // Log request body (fields)
      print("Request body:");
      print("name: $name");
      print("address: $address");
      print("phone: $phone");
      print("openingHours: $openingHours");

      // Add images if selected
      if (profileImage != null) {
        var profileImageFile = await http.MultipartFile.fromPath(
          'profileImage', profileImage.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(profileImageFile);
        print("Profile image: ${profileImage.path}");
      }

      if (layoutImage != null) {
        var layoutImageFile = await http.MultipartFile.fromPath(
          'layoutImage', layoutImage.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(layoutImageFile);
        print("Layout image: ${layoutImage.path}");
      }

      for (var image in galleryImages) {
        var galleryImageFile = await http.MultipartFile.fromPath(
          'galleryImages', image.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(galleryImageFile);
        print("Gallery image: ${image.path}");
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        print("Updated restaurant data: $data");
        _restaurant = Restaurant.fromJson(data);
        _restaurants = _restaurants.map((r) {
          return r.id == restaurantId ? _restaurant! : r;
        }).toList();

        // Notify listeners after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        _errorMessage = 'Failed to update restaurant';
        print("Error: ${responseBody}");
        // Notify listeners after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print("Error while updating: $e");
      // Notify listeners after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }



}
