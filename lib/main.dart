import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fms_app/providers/auth_provider.dart';
import 'package:fms_app/screens/auth/login_screen.dart';
import 'package:fms_app/screens/home/main_layout.dart';
import 'package:fms_app/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final authService = AuthService();
    return await authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()), // Loading screen
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fuel Management System',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: const Locale('ar', ''),
          supportedLocales: const [Locale('ar', '')],
          theme: ThemeData(
            fontFamily: 'Almarai',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontWeight: FontWeight.w400),
              bodyMedium: TextStyle(fontWeight: FontWeight.w300),
              titleLarge: TextStyle(fontWeight: FontWeight.w700),
              headlineMedium: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          home: snapshot.data == true ? const MainLayout() : const LoginScreen(),
        );
      },
    );
  }
}
