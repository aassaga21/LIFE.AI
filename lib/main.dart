import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'providers/user_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/features_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/about_screen.dart';
import 'screens/blog_screen.dart';
import 'screens/entreprises_screen.dart';
import 'screens/pricing_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/checkin_screen.dart';
import 'features/history/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialise le format de dates en français
  await initializeDateFormatting('fr_FR');
  // Initialise le service de notifications (no-op sur le web)
  await NotificationService().initialize();
  runApp(const LifeAIApp());
}

class LifeAIApp extends StatelessWidget {
  const LifeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'LIFE.AI',
        debugShowCheckedModeBanner: false,
        // Clé navigator utilisée par NotificationService pour les banners in-app
        navigatorKey: NotificationService.navigatorKey ??=
            GlobalKey<NavigatorState>(),
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
            case '/dashboard':
              page = const DashboardScreen();
            case '/checkin':
              page = const CheckinScreen();
            case '/history':
              page = const HistoryScreen();
            default:
              page = const HomeScreen();
          }
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, _) => page,
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 350),
          );
        },
      ),
    );
  }
}
