import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';


class OwnerService {
  final ImagePicker _picker = ImagePicker();

  // Pick profile image
  Future<File?> pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Pick layout image
  Future<File?> pickLayoutImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Pick multiple gallery images
  Future<List<File>> pickGalleryImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      return pickedFiles.map((file) => File(file.path)).toList();
    }
    return [];
  }

  // Submit restaurant data
  Future<void> submitRestaurantData({
    required String token,
    required String name,
    required String address,
    required String phone,
    required String openingHours,
    required List<String> categories,
    File? profileImage,
    File? layoutImage,
    List<File>? galleryImages,
    required Function onSuccess,
    required Function(String error) onError,
  }) async {
    galleryImages = galleryImages ?? [];
    // API URL
    const String url = "https://restaurant-reservation-sys.vercel.app/restaurants/create";

    // Prepare the request body
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['token'] = token
      ..fields['name'] = name
      ..fields['address'] = address
      ..fields['phone'] = phone
      ..fields['openingHours'] = openingHours;

    // Add categories to request
    for (int i = 0; i < categories.length; i++) {
      request.fields['categories[$i]'] = categories[i].trim();
    }

    // Add images if selected
    if (profileImage != null) {
      var profileImageFile = await http.MultipartFile.fromPath(
        'profileImage', profileImage.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(profileImageFile);
    }

    if (layoutImage != null) {
      var layoutImageFile = await http.MultipartFile.fromPath(
        'layoutImage', layoutImage.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(layoutImageFile);
    }

    for (var image in galleryImages) {
      var galleryImageFile = await http.MultipartFile.fromPath(
        'gallery_images[]', image.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(galleryImageFile);
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        onSuccess();
        print(responseBody);
      } else {
        final error = json.decode(responseBody);
        onError("Failed to add restaurant: ${error['message']}");
      }
    } catch (e) {
      onError("Error: $e");
    }
  }
  Future<void> submitVipRoomData({
    required String token,
    required String name,
    required String capacity,
    required String restaurantId,
    required List<File> images,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final uri = Uri.parse('https://restaurant-reservation-sys.vercel.app/vip-rooms/create');
      final request = http.MultipartRequest('POST', uri);

      request.headers['token'] = token;
      request.fields['name'] = name;
      request.fields['capacity'] = capacity;
      request.fields['restaurantId'] = restaurantId;

      for (var image in images) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();

      // Read and print the response body
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        // Notify success and call the callback
        onSuccess();
      } else {
        onError('Failed to add VIP Room: ${response.statusCode}');
      }
    } catch (e) {
      onError('An error occurred: $e');
    }
  }

  Future<void> submitMealData({
    required String token,
    required String name,
    required String desc,
    required String price,
    required String restaurantId,
    required File image,  // This should be a single File
    required String category,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final uri = Uri.parse('https://restaurant-reservation-sys.vercel.app/meals/create');
      final request = http.MultipartRequest('POST', uri);

      request.headers['token'] = token;
      request.fields['name'] = name;
      request.fields['desc'] = desc;
      request.fields['price'] = price;
      request.fields['restaurantId'] = restaurantId;
      request.fields['category'] = category;

      // Add the single image to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image', image.path,  // Use 'image' for a single file
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();

      // Read and print the response body
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        // Notify success and call the callback
        onSuccess();
      } else {
        final error = json.decode(responseBody);
        onError('Failed to add meal: ${error['message']}');
      }
    } catch (e) {
      onError('An error occurred: $e');
    }
  }

  Future<void> submitTableData({
    required String token,
    required String restaurantId,
    required String tableNumber,
    required String capacity,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final uri = Uri.parse('https://restaurant-reservation-sys.vercel.app/tables/create');

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'restaurantId': restaurantId,
        'tableNumber': tableNumber,
        'capacity': capacity,
      };

      // Print the body for debugging
      print('Request body: ${jsonEncode(requestBody)}');

      // Send the POST request with raw JSON body
      final response = await http.post(
        uri,
        headers: {
          'token': token,
          'Content-Type': 'application/json',  // Set content type to JSON
        },
        body: jsonEncode(requestBody),  // Convert requestBody to JSON
      );

      final responseBody = response.body;
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        // Notify success and call the callback
        onSuccess();
      } else {
        final error = json.decode(responseBody);
        onError('Failed to add table: ${error['message']}');
      }
    } catch (e) {
      onError('An error occurred: $e');
    }
  }



}


