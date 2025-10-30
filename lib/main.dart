import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/garden_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/panda_dashboard.dart';
import 'screens/visitor_dashboard.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService.instance.initialize();

  runApp(const PandaGardenApp());
}

class PandaGardenApp extends StatelessWidget {
  const PandaGardenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GardenService()),
      ],
      child: MaterialApp(
        title: '🐼 Panda in the Garden',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/panda-dashboard': (context) => const PandaDashboard(),
          '/visitor-dashboard': (context) => const VisitorDashboard(),
        },
      ),
    );
  }
}
