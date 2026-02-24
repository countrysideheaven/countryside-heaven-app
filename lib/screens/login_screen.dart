import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import all three dashboards
import 'admin_dashboard.dart';
import 'partner_dashboard.dart';
import 'customer_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1. Log the user in
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;

      if (user != null) {
        // 2. Fetch their role from the 'profiles' table
        final profileData = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle(); // maybeSingle means it won't crash if the profile is missing

        String role = 'customer'; // Default role if something goes wrong
        
        if (profileData != null && profileData['role'] != null) {
          role = profileData['role'];
        }

        // 3. Navigate based on their role!
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as $role! 🎉'), backgroundColor: Colors.green),
          );

          if (role == 'admin') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminDashboard()));
          } else if (role == 'partner') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PartnerDashboard()));
          } else {
            // Default to customer
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CustomerMainScreen()));
          }
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), backgroundColor: Colors.red));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  // ... (The build method for the UI stays exactly the same as before)
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.landscape_rounded, size: 80, color: Color(0xFF2E7D32)),
                const SizedBox(height: 16),
                const Text('Countryside Heaven', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('Sign in to access your properties & holidays', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 40),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}