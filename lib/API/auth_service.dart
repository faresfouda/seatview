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
            'imageUrl': user['image'] ?? '',
            'isConfirmed': user['isConfirmed'] ?? false,
            'role': user['role']??'',
            'restaurant':user['restaurant'],
          },
          'token': token ?? '',
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
    required String role,
  }) async {
    try {
      print('Sending POST request to: $_baseUrl/users/signup');
      print('Request Body: ${jsonEncode({
        'name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'role' : role,
      })}');

      final response = await http.post(
        Uri.parse('$_baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'role' : role,
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
            'role' : user['role'],
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

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    const String url = 'https://your-api-url.com/users/forgot-password';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password reset email sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send password reset email',
        };
      }
    } catch (e) {
      print("Forgot password error: $e");
      return {
        'success': false,
        'message': 'An error occurred. Please try again later.',
      };
    }
  }
}

Future<void> addFavorite(String token, String restaurantId) async {
  const String url = 'https://restaurant-reservation-sys.vercel.app/users/favorites/add';

  try {
    // Construct the body
    final body = jsonEncode({'restaurantId': restaurantId});

    // Make the HTTP POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'token': '$token', // Include the token in the header
      },
      body: body,
    );

    // Check the response status
    if (response.statusCode == 200) {
      print('Restaurant added to favorites successfully!');
      print(response.body);
    } else {
      print('Failed to add favorite: ${response.body}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }


}

