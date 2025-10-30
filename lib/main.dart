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

  // Initialize AuthService
  final authService = AuthService();
  await authService.init();

  runApp(PandaGardenApp(authService: authService));
}

class PandaGardenApp extends StatelessWidget {
  final AuthService authService;

  const PandaGardenApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
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
