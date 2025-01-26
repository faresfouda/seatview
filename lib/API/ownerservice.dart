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
  Future<void> submitRestaurantImages({
    required String token,
    required String restaurantId,
    File? profileImage,
    File? layoutImage,
    List<File>? galleryImages,
    required Function onSuccess,
    required Function(String error) onError,
  }) async {
    const String url = "https://restaurant-reservation-sys.vercel.app/restaurants/create/images";

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['token'] = token
      ..fields['restaurantId'] = restaurantId;

    // Attach profile image if available
    if (profileImage != null) {
      var profileImageFile = await http.MultipartFile.fromPath(
        'profileImage',
        profileImage.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(profileImageFile);
    }

    // Attach layout image if available
    if (layoutImage != null) {
      var layoutImageFile = await http.MultipartFile.fromPath(
        'layoutImage',
        layoutImage.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(layoutImageFile);
    }

    // Attach gallery images if available
    if (galleryImages != null) {
      for (var image in galleryImages) {
        var galleryImageFile = await http.MultipartFile.fromPath(
          'galleryImages',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(galleryImageFile);
      }
    }

    // Log the request details
    print("Request URL: $url");
    print("Headers: ${request.headers}");
    print("Fields: ${request.fields}");
    print("Number of files attached: ${request.files.length}");

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Log the response details
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess();
      } else {
        final error = json.decode(responseBody);
        onError("Failed to upload images: ${error['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception occurred: $e");
      onError("Exception: $e");
    }
  }



  Future<void> submitRestaurantDetails({
    required String token,
    required String name,
    required String address,
    required String phone,
    required String openingHours,
    required List<String> categories,
    required Function(String restaurantId) onSuccess,
    required Function(String error) onError,
  }) async {
    const String url = "https://restaurant-reservation-sys.vercel.app/restaurants/create/data";

    final requestBody = {
      'name': name,
      'address': address,
      'phone': phone,
      'openingHours': openingHours,
      'categories': categories,
    };

    // Log the request details
    print("Request URL: $url");
    print("Headers: {'Content-Type': 'application/json', 'token': $token}");
    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(requestBody),
      );

      // Log the response details
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final restaurantId = responseData['restaurant']['_id']; // Extract restaurantId from response
        onSuccess(restaurantId);
      } else {
        final error = json.decode(response.body);
        onError("Failed to create restaurant: ${error['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception occurred: $e");
      onError("Exception: $e");
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

      // Debug log
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.map((file) => file.filename)}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
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
    required File image,
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

      request.files.add(await http.MultipartFile.fromPath(
        'image', image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Debug log
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.map((file) => file.filename)}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
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
    required File image, // Add image parameter
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final uri = Uri.parse('https://restaurant-reservation-sys.vercel.app/tables/create');
      final request = http.MultipartRequest('POST', uri);

      // Add headers and fields
      request.headers['token'] = token;
      request.fields['restaurantId'] = restaurantId;
      request.fields['tableNumber'] = tableNumber;
      request.fields['capacity'] = capacity;

      // Attach the image
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Field name
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Debug log
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.map((file) => file.filename)}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
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
