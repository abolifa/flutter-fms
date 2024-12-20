import 'package:flutter/material.dart';
import 'package:fms_app/screens/auth/login_screen.dart';
import 'package:fms_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  /// Handle logout
  Future<void> logout(BuildContext context) async {
    await _authService.logout(); // Clear token
    notifyListeners(); // Notify listeners about state change

    // Replace current route stack with LoginScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Clear all previous routes
    );
  }
}
