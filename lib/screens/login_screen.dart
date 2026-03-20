import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Added for password support
  bool _isLoading = false;

  final Color bgDark = const Color(0xFF111111);
  final Color bgLight = const Color(0xFFF7F7F9);
  final Color vibrantAccent = const Color(0xFFFF5E5E);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Updated to handle both email and password
  Future<void> _handleLogin(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both email and password')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(email, password);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: vibrantAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [BoxShadow(color: vibrantAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: -10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: vibrantAccent.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.rocket_launch_rounded, color: vibrantAccent, size: 48),
                    ),
                    const SizedBox(height: 24),
                    const Text('Countryside', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111111), letterSpacing: -1)),
                    Text('Fractional Real Estate, Fast.', style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleLogin(_emailController.text.trim(), _passwordController.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          shadowColor: bgDark.withOpacity(0.3),
                        ),
                        child: _isLoading 
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('Sign In ⚡️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Quick Dev Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                    const SizedBox(height: 16),
                    
                    // Unified Dev Buttons for all roles
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildDevButton('Admin', 'admin@test.com', vibrantAccent),
                        _buildDevButton('Partner', 'partner@test.com', const Color(0xFF8B5CF6)),
                        _buildDevButton('Sales', 'sales@test.com', const Color(0xFFCA8A04)),
                        _buildDevButton('Customer', 'customer@test.com', const Color(0xFF22C55E)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDevButton(String label, String email, Color color) {
    return InkWell(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = 'password@123'; // Standard test password
        _handleLogin(email, 'password@123');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    );
  }
}