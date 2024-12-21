import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String _baseUrl = 'https://restaurant-reservation-sys.vercel.app';

  // Login method
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Sending POST request to: $_baseUrl/users/signin');
      print('Request Body: ${jsonEncode({
        'email': email,
        'password': password,
      })}');

      final response = await http.post(
        Uri.parse('$_baseUrl/users/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];
        final token = responseData['token'];

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'user': {
            'id': user['_id'] ?? '',
            'name': user['name'] ?? '',
            'email': user['email'] ?? '',
            'phone': user['phone'] ?? '',
            'imageUrl': user['imageUrl'] ?? '', // Add imageUrl here if it exists
            'isConfirmed': user['isConfirmed'] ?? false,
          },
          'token': token ?? '', // Include the token
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Error occurred: $e');
      return {
        'success': false,
        'message': 'A network error occurred: $e',
      };
    }
  }

  // Signup method
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      print('Sending POST request to: $_baseUrl/users/signup');
      print('Request Body: ${jsonEncode({
        'name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      })}');

      final response = await http.post(
        Uri.parse('$_baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];
        final token = responseData['token'];

        return {
          'success': true,
          'message': responseData['message'] ?? 'Signup successful',
          'token': token ?? '',
          'user': {
            'id': user['_id'] ?? '',
            'name': user['name'] ?? '',
            'email': user['email'] ?? '',
            'isConfirmed': user['isConfirmed'] ?? false,

          },
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.body}',
        };
      }
    } catch (e) {
      print('Error occurred: $e');
      return {
        'success': false,
        'message': 'A network error occurred: $e',
      };
    }
  }

  // Delete Account method
  Future<Map<String, dynamic>> deleteAccount({required String token}) async {
    try {
      final url = '$_baseUrl/users/delete-account';
      final headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      print('Sending DELETE request to: $url with headers: $headers');

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Account deleted successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Account deletion failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to delete account',
        };
      }
    } catch (e) {
      print('Error occurred: $e');
      return {
        'success': false,
        'message': 'A network error occurred: $e',
      };
    }
  }
}
