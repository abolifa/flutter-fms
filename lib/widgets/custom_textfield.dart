import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {

  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final IconData icon;


  const CustomTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(50),
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(50),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(icon, color: Colors.grey.shade500),
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
