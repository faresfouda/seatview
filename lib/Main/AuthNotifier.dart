import 'package:flutter/material.dart';

enum AuthState { loading, authenticated, unauthenticated, error }

class AuthNotifier extends ChangeNotifier {
  AuthState _state = AuthState.loading;
  AuthState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void checkCurrentUser() {
    // Simulate user authentication check
    Future.delayed(const Duration(seconds: 2), () {
      _state = AuthState.unauthenticated; // Default to unauthenticated
      notifyListeners();
    });
  }

  void login() {
    _state = AuthState.loading;
    notifyListeners();

    // Simulate login process
    Future.delayed(const Duration(seconds: 2), () {
      _state = AuthState.authenticated;
      notifyListeners();
    });
  }

  void logout() {
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
