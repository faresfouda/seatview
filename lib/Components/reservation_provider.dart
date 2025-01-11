import 'package:flutter/material.dart';

class ReservationStatusProvider with ChangeNotifier {
  bool _isLoading = true;
  bool _hasError = false;
  bool _hasNoReservations = false; // New property
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get hasNoReservations => _hasNoReservations; // Getter
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(bool value, {String? message}) {
    _hasError = value;
    _errorMessage = message;
    notifyListeners();
  }

  void setNoReservations(bool value) { // New setter
    _hasNoReservations = value;
    notifyListeners();
  }

  void reset() {
    _isLoading = true;
    _hasError = false;
    _hasNoReservations = false; // Reset this flag
    _errorMessage = null;
    notifyListeners();
  }
}
