import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/farmer/home_screen.dart';
import '../screens/farmer/alerts_screen.dart';
import '../screens/farmer/alert_detail_screen.dart';
import '../screens/farmer/settings_screen.dart';
import '../screens/camera/camera_screen.dart';
import '../models/alert_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String alerts = '/alerts';
  static const String alertDetail = '/alert-detail';
  static const String settings = '/settings';
  static const String camera = '/camera';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        home: (_) => const HomeScreen(),
        alerts: (_) => const AlertsScreen(),
        settings: (_) => const SettingsScreen(),
        camera: (_) => const CameraScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case alertDetail:
        final alert = settings.arguments as Alert;
        return MaterialPageRoute(
          builder: (_) => AlertDetailScreen(alert: alert),
        );
      default:
        return null;
    }
  }
}