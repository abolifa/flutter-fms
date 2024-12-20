import 'package:flutter/material.dart';
import 'package:fms_app/screens/home/main_layout.dart';
import 'package:fms_app/services/auth_service.dart';
import 'package:fms_app/widgets/custom_textfield.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    String? error = await authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (error == null) {
      // Navigate to HomeScreen after successful login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } else {
      // Display error message
      setState(() {
        errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),

                SvgPicture.asset('assets/svg/logo.svg', width: 160, height: 160),

                const SizedBox(height: 20),
                const Text(
                    'جهاز الطيران الإلكتروني',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                ),

                const SizedBox(height: 10),

                const Text(
                    'مركز مصراتة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                ),

                const SizedBox(height: 50),

                CustomTextfield(
                  hintText: 'البريد الإلكتروني',
                  controller: emailController,
                  obscureText: false,
                  icon: Icons.mail,
                ),

                const SizedBox(height: 20),



                CustomTextfield(
                  hintText: 'كلمة المرور',
                  controller: passwordController,
                  obscureText: true,
                  icon: Icons.lock,
                ),

                const SizedBox(height: 50),

                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),

                const SizedBox(height: 5),

                SizedBox(
                  width: 400,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900),
                      foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
                    ),
                      child: isLoading ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
