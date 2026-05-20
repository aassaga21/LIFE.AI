import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/features_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/about_screen.dart';
import 'screens/blog_screen.dart';
import 'screens/entreprises_screen.dart';
import 'screens/pricing_screen.dart';
import 'screens/feedback_screen.dart'; // Import des écrans
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'theme/app_colors.dart';// Import des écrans et du thème
import 'package:firebase_core/firebase_core.dart'; // Firebase core package
import 'firebase_options.dart'; // Firebase configuration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // Toutes les navigations utilisent une transition fade fluide
      onGenerateRoute: (settings) {
        final Widget page;
        switch (settings.name) {
          case '/features':
            page = const FeaturesScreen();
          case '/contact':
            page = const ContactScreen();
          case '/about':
            page = const AboutScreen();
          case '/blog':
            page = const BlogScreen();
          case '/entreprises':
            page = const EntreprisesScreen();
          case '/pricing':
            page = const PricingScreen();
          case '/feedback':
            page = const FeedbackScreen();
          case '/login':
            page = const LoginScreen();
          case '/register':
            page = const RegisterScreen();
          default:
            page = const HomeScreen();
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, _) => page,
          transitionsBuilder: (context, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    );
  }
}
