import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/features_screen.dart';
import 'screens/contact_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const LifeAIApp());
}

class LifeAIApp extends StatelessWidget {
  const LifeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIFE.AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/features': (context) => const FeaturesScreen(),
        '/contact': (context) => const ContactScreen(),
      },
    );
  }
}
