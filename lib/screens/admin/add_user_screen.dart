import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color vibrantAccent = const Color(0xFFFF5E5E);
  final Color textDark = const Color(0xFF111111);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  UserRole _selectedRole = UserRole.customer; // Default role

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Network Member ⚡️', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, double value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: vibrantAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: vibrantAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Linking users with referral codes automatically builds your network tree.',
                          style: TextStyle(color: textDark.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Core Inputs
                _buildInputLabel('Full Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. Jane Doe',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 24),

                _buildInputLabel('Email Address'),
                _buildTextField(
                  controller: _emailController,
                  hint: 'jane@example.com',
                  icon: Icons.alternate_email_rounded,
                  isEmail: true,
                ),
                const SizedBox(height: 32),

                // Playful Role Selector
                _buildRoleSelector(),
                const SizedBox(height: 32),

                // Referral Code (Optional)
                _buildInputLabel('Invited By (Referral Code)'),
                _buildTextField(
                  controller: _referralController,
                  hint: 'Leave blank for Admin',
                  icon: Icons.tag_rounded,
                  isRequired: false,
                ),
                const SizedBox(height: 48),

                // Giant Action Button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textDark, // Deep ink color looks great for submit
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: textDark.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Add to Network 🚀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 1. Grab the provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 2. Register the user via our mock database logic
      authProvider.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _selectedRole,
        enteredReferralCode: _referralController.text.trim(),
      );

      // 3. Show a bouncy success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} added to the network! 🎉', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );

      // 4. Pop back to dashboard
      Navigator.pop(context);
    }
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Assign Role'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: UserRole.values.map((role) {
              if (role == UserRole.admin) return const SizedBox.shrink(); // Don't allow creating new master admins here
              
              final isSelected = _selectedRole == role;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? vibrantAccent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected 
                          ? [BoxShadow(color: vibrantAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))]
                          : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Text(
                      _getRoleName(role),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.channelPartner: return 'Channel Partner';
      case UserRole.salesAgent: return 'Sales Agent';
      case UserRole.customer: return 'Client';
      default: return '';
    }
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: textDark, fontSize: 14)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isEmail = false,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: vibrantAccent, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) return 'This field is required';
        return null;
      },
    );
  }
}