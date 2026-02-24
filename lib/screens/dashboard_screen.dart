import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // We need this to go back to the login screen when we log out

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: const Color(0xFF2E7D32), // Our brand green
        foregroundColor: Colors.white,
        actions: [
          // This is our Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              // Tell Supabase to log the user out
              await Supabase.instance.client.auth.signOut();
              
              // Navigate back to the Login Screen
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the inside of the app! 🚀\nWe will build the real dashboard here soon.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}