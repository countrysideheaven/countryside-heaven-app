import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';

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
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController(text: '1');
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _fractionsController = TextEditingController();

  double _calculatedFractionPrice = 0.0;
  bool _isUploading = false; 

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ---> NEW: Actually pushes the bytes to R2 using your provider
  Future<List<String>> _uploadImagesToR2(PropertyProvider provider) async {
    List<String> uploadedUrls = [];

    for (var image in _selectedImages) {
      try {
        // 1. Read the bytes (Works safely on Flutter Web)
        final bytes = await image.readAsBytes();
        
        // 2. Send to R2 via provider and get the public URL back
        final publicUrl = await provider.uploadPropertyImage(bytes, image.name);
        
        // 3. Store the public URL
        uploadedUrls.add(publicUrl);
        debugPrint("✅ Successfully uploaded to R2: $publicUrl");

      } catch (e) {
        debugPrint("🚨 Failed to upload image to R2: $e");
      }
    }
    
    return uploadedUrls;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _unitsController.dispose();
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
                _buildImageUploader(),
                const SizedBox(height: 32),

                _buildInputLabel('Asset Name'),
                _buildTextField(controller: _titleController, hint: 'e.g. Sunset Boulevard Villa', icon: Icons.landscape_rounded),
                const SizedBox(height: 24),

                _buildInputLabel('Location'),
                _buildTextField(controller: _locationController, hint: 'e.g. Bali, Indonesia', icon: Icons.location_on_rounded),
                const SizedBox(height: 24),

                _buildInputLabel('Description'),
                _buildTextField(controller: _descriptionController, hint: 'Describe the property, amenities...', icon: Icons.description_rounded, maxLines: 4),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Total Value (\$)'),
                          _buildTextField(controller: _valueController, hint: '1000000', icon: Icons.attach_money_rounded, isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Number of Units'),
                          _buildTextField(controller: _unitsController, hint: '1', icon: Icons.meeting_room_rounded, isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Total Fractions (across all units)'),
                    _buildTextField(controller: _fractionsController, hint: '100', icon: Icons.pie_chart_rounded, isNumber: true),
                  ],
                ),
                const SizedBox(height: 32),

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
                          const Text('Avg. Price per Fraction', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            '\$${_calculatedFractionPrice.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        
                        setState(() {
                          _isUploading = true;
                        });

                        final provider = Provider.of<PropertyProvider>(context, listen: false);

                        // 1. Actually upload the bytes to R2
                        List<String> finalImageUrls = await _uploadImagesToR2(provider);
                        
                        int unitsCount = int.tryParse(_unitsController.text) ?? 1;
                        if (unitsCount < 1) unitsCount = 1;

                        try {
                          // 2. Safely create the property and retrieve its unique ID
                          final String newPropertyId = await provider.addProperty(
                            _titleController.text,
                            _locationController.text,
                            unitsCount, 
                            _calculatedFractionPrice,
                          );

                          // 3. Update Supabase with the exact R2 URLs and Description
                          await provider.updatePropertyExtraData(
                            newPropertyId, 
                            _descriptionController.text, 
                            finalImageUrls,
                          );
                        } catch (e) {
                          debugPrint("🚨 Error saving to Supabase: $e");
                        }

                        if (mounted) {
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vibrantAccent,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: vibrantAccent.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      disabledBackgroundColor: vibrantAccent.withOpacity(0.6),
                    ),
                    child: _isUploading 
                      ? const SizedBox(
                          height: 24, width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                      : const Text('Launch Asset 🚀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Property Gallery'),
        if (_selectedImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.shade300, width: 2), 
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
                  Text('Upload Images', style: TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('High-res photos sell faster', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_rounded, size: 40, color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade200, 
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: kIsWeb
                          ? Image.network(
                              _selectedImages[index].path, // Uses local Blob path while in preview state
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : Image.file(
                              File(_selectedImages[index].path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : [],
      maxLines: maxLines,
      style: TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey.shade500) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(maxLines > 1 ? 20 : 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: vibrantAccent, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
    );
  }
}