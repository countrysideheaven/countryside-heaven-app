import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- NEW IMPORT

import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'models/app_user.dart';
import 'screens/login_screen.dart';
import 'screens/admin_main_screen.dart';
import 'screens/partner_main_screen.dart';
import 'screens/customer_main_screen.dart';
import 'screens/sales_main_screen.dart';

Future<void> main() async {
  // Required to ensure Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the .env file
  await dotenv.load(fileName: ".env");

  // 2. Safely grab the keys
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  // Safety check to ensure the .env file is set up correctly
  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file');
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