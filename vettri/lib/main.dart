import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modules/home/home_screen.dart';
import 'routes/app_routes.dart';


void main() {
  runApp(const VettriPechuApp());
}

class VettriPechuApp extends StatelessWidget {
  const VettriPechuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vettri Pechu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFFF5A1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5A1F),
          primary: const Color(0xFFFF5A1F),
          secondary: const Color(0xFFFF7A00),
          surface: const Color(0xFFF1F1F1),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MyHomePage(title: 'Vettri Pechu'),
      routes: AppRoutes.routes,
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
