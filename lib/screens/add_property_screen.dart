import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({Key? key}) : super(key: key);

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final Color bgLight = const Color(0xFFF7F7F9);
  final Color vibrantAccent = const Color(0xFFFF5E5E);
  final Color textDark = const Color(0xFF111111);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _fractionsController = TextEditingController();

  double _calculatedFractionPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // Auto-calculate the fraction price when user types
    _valueController.addListener(_calculatePrice);
    _fractionsController.addListener(_calculatePrice);
  }

  void _calculatePrice() {
    final value = double.tryParse(_valueController.text.replaceAll(',', '')) ?? 0.0;
    final fractions = int.tryParse(_fractionsController.text) ?? 0;
    
    setState(() {
      if (fractions > 0) {
        _calculatedFractionPrice = value / fractions;
      } else {
        _calculatedFractionPrice = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _fractionsController.dispose();
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
        title: Text('New Asset 🚀', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
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
                // Image Upload Placeholder
                _buildImageUploader(),
                const SizedBox(height: 32),

                // Inputs
                _buildInputLabel('Asset Name'),
                _buildTextField(
                  controller: _titleController,
                  hint: 'e.g. Sunset Boulevard Villa',
                  icon: Icons.landscape_rounded,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Total Value (\$)'),
                          _buildTextField(
                            controller: _valueController,
                            hint: '1,000,000',
                            icon: Icons.attach_money_rounded,
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Total Fractions'),
                          _buildTextField(
                            controller: _fractionsController,
                            hint: '100',
                            icon: Icons.pie_chart_rounded,
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Smart Auto-Calculation Card
                if (_calculatedFractionPrice > 0)
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    builder: (context, double val, child) {
                      return Transform.scale(scale: val, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: textDark,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: textDark.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price per Fraction', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            '\$${_calculatedFractionPrice.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 48),

                // Big Launch Button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Save to Provider/Supabase
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Asset Launched Successfully! 🎉', style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: vibrantAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vibrantAccent,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: vibrantAccent.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Launch Asset 🚀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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

  Widget _buildImageUploader() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid), // In a real app, use dotted border package
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgLight, shape: BoxShape.circle),
            child: Icon(Icons.add_a_photo_rounded, color: textDark, size: 32),
          ),
          const SizedBox(height: 12),
          Text('Upload Cover Image', style: TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 16)),
          Text('High-res photos sell faster', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
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
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : [],
      style: TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: vibrantAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        return null;
      },
    );
  }
}