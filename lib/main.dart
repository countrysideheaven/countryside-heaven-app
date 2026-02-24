import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  // Ensure Flutter is ready before initializing plugins
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Supabase (Replace with your actual keys)
  await Supabase.initialize(
    url: 'https://hgscvzlarsnirawgliri.supabase.co',
    anonKey: 'sb_publishable_BSiuNispQZto5M_lQzwPcw_FUYnvN1a',
  );

  runApp(const CountrysideApp());
}

class CountrysideApp extends StatelessWidget {
  const CountrysideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countryside Heaven',
      debugShowCheckedModeBanner: false, // Removes the little "DEBUG" banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)), // A nice earthy green
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}