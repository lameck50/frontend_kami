import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/supervisor_dashboard/presentation/providers/supervisor_provider.dart';
import 'features/admin/presentation/providers/admin_provider.dart';
import 'features/agent_dashboard/presentation/providers/agent_provider.dart';

void main() {
  runApp(const KamiGeolocApp());
}

class KamiGeolocApp extends StatelessWidget {
  const KamiGeolocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SupervisorProvider>(
          create: (context) => SupervisorProvider(authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => SupervisorProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (context) => AdminProvider(authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => AdminProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AgentProvider>(
          create: (context) => AgentProvider(authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => AgentProvider(authProvider: auth),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'KamiGeoloc',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
