import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fms_app/helpers/params.dart';

class AuthService {
  /// Login method to authenticate user credentials
  Future<String?> login(String email, String password) async {
    try {
      print(Constant.loginUrl); // Log the URL
      final response = await http.post(
        Uri.parse(Constant.loginUrl), // Replace with your actual URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save token if it exists
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          print('Token saved: ${data['token']}'); // Log the saved token
          return null; // Success, no error
        } else {
          print('Error: Token missing in the response');
          return 'Invalid response from server';
        }
      } else {
        // Extract and log the error message from response
        final errorData = jsonDecode(response.body);
        final serverMessage = errorData['message'] ?? 'Unexpected error';
        print('Error ${response.statusCode}: $serverMessage'); // Log to console
        return serverMessage;
      }
    } catch (e) {
      // Handle unexpected exceptions
      print('Exception occurred: $e'); // Log exception details
      return 'Failed to connect to the server';
    }
  }

  /// Check if the user is already logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  /// Logout the user and clear the stored token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('User logged out: Token cleared');
  }
}
