import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:seatview/API/auth_service.dart'; // Import your auth service


class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isConfirmed;
  final String? image;


  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isConfirmed,
    this.image,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isConfirmed: json['isConfirmed'] ?? '',
      image: json['image'], // Optional
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isConfirmed':isConfirmed,
      'image': image,
    };
  }
}

class UserProvider with ChangeNotifier {
  static const String _tokenKey = 'userToken';
  static const String _userKey = 'userData';

  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;

  bool get isLoggedIn => _user != null && _token != null;

  // Check if user session exists
  Future<void> checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_tokenKey);
    final storedUserData = prefs.getString(_userKey);

    print('Stored token: $storedToken');
    print('Stored user data: $storedUserData');

    if (storedToken != null && storedUserData != null) {
      _token = storedToken;
      Map<String, dynamic> userJson = jsonDecode(storedUserData);
      _user = UserModel.fromJson(userJson);
    } else {
      print('Token is missing, logging out.');
      await logout();
    }

    notifyListeners();
  }

  // Set user data and token when logging in
  Future<void> setUserData(UserModel userModel, String token) async {
    final prefs = await SharedPreferences.getInstance();
    _user = userModel;
    _token = token;

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userModel.toJson()));

    print('User data saved: ${userModel.name}, Token: $token');

    notifyListeners();
  }

  // Login function
  Future<void> login(String email, String password) async {
    final authService = AuthService();
    try {
      final result = await authService.login(email: email, password: password);
      if (result['success']) {
        final user = UserModel.fromJson(result['user']);
        await setUserData(user, result['token']);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      print("Login failed: $e");
      throw Exception("Login failed. Please try again.");
    }
  }

  // Logout function
  Future<void> logout() async {
    _user = null;    // Clear user data
    _token = null;   // Clear token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);  // Remove token from local storage
    await prefs.remove(_userKey);  // Remove user data from local storage
    notifyListeners();  // Notify listeners to update the UI or dependent components
  }
}


