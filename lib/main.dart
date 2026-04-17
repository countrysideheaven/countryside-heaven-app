import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'models/app_user.dart';
import 'screens/login_screen.dart';
import 'screens/admin_main_screen.dart';
import 'screens/partner_main_screen.dart';
import 'screens/customer_main_screen.dart';
import 'screens/sales_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Grab keys securely from the compile-time environment
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // 2. Proper safety check for compile-time strings
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw Exception('Missing variables. You must run the app with --dart-define-from-file=env.json');
  }

  // 3. Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countryside Heaven',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F9), 
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5E5E)), 
      ),
      
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.currentUser == null) {
            return const LoginScreen();
          }
          
          switch (auth.currentUser!.role) {
            case UserRole.admin:
              return const AdminMainScreen();
            case UserRole.channelPartner:
              return const PartnerMainScreen(); 
            case UserRole.salesAgent:
              return const SalesMainScreen(); 
            case UserRole.customer:
              return const CustomerMainScreen(); 
          }
        },
      ),
    );
  }
}