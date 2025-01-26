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
    final url = 'https://restaurant-reservation-sys.vercel.app/restaurants/update/$restaurantId';

    // Ensure required fields are valid
    if (restaurantId.isEmpty || token.isEmpty) {
      _handleError("Restaurant ID and token cannot be empty.");
      return;
    }

    try {
      // Log fields for debugging
      _logFields(name, address, phone, openingHours);

      var request = http.MultipartRequest('PUT', Uri.parse(url))
        ..headers['token'] = token
        ..fields['name'] = name
        ..fields['address'] = address
        ..fields['phone'] = phone
        ..fields['openingHourse'] = openingHours; // Matches backend typo

      // Add images to request
      await _addImagesToRequest(request, profileImage, layoutImage, galleryImages);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Restaurant updated successfully.");
      } else {
        _handleError("Failed to update restaurant. Response: $responseBody");
      }
    } catch (e) {
      _handleError("Error updating restaurant: $e");
    }
  }

// Log fields for debugging
  void _logFields(String name, String address, String phone, String openingHours) {
    print("Request body:");
    print("name: $name");
    print("address: $address");
    print("phone: $phone");
    print("openingHours: $openingHours");
  }

// Add images to the request
  Future<void> _addImagesToRequest(
      http.MultipartRequest request,
      File? profileImage,
      File? layoutImage,
      List<File> galleryImages,
      ) async {
    await _addImageToRequest(request, 'profileImage', profileImage);
    await _addImageToRequest(request, 'layoutImage', layoutImage);

    if (galleryImages.isEmpty) {
      print("No gallery images to upload.");
    } else {
      for (var image in galleryImages) {
        await _addImageToRequest(request, 'galleryImages', image);
      }
    }
  }

// Helper function to add image to the request
  Future<void> _addImageToRequest(
      http.MultipartRequest request,
      String fieldName,
      File? image,
      ) async {
    if (image != null) {
      String fileType = image.path.split('.').last.toLowerCase();
      var imageFile = await http.MultipartFile.fromPath(
        fieldName,
        image.path,
        contentType: MediaType('image', fileType),
      );
      request.files.add(imageFile);
      print("$fieldName image: ${image.path}");
    }
  }

// Handle errors by setting the error message and notifying listeners
  void _handleError(String errorMessage) {
    _errorMessage = errorMessage;
    print("Error while updating: $errorMessage");

    // Notify listeners after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }




}
