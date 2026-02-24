import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minio/minio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added for .env security

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedStatus = 'Available';
  bool _isLoading = false;

  // --- IMAGE PICKING VARIABLES ---
  XFile? _selectedImage;
  Uint8List? _imageBytes; // Required for web image preview

  final supabase = Supabase.instance.client;

  // Function to pick an image from the computer/phone
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  // Function to save everything
  Future<void> _saveProperty() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first!'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        print("👀 HERE IS WHAT FLUTTER SEES IN THE ENV FILE: ${dotenv.env}");
        // --- SECURELY LOADING R2 DETAILS FROM .ENV ---
        final String r2Endpoint = dotenv.env['R2_ENDPOINT'] ?? ''; 
        final String r2AccessKey = dotenv.env['R2_ACCESS_KEY'] ?? '';
        final String r2SecretKey = dotenv.env['R2_SECRET_KEY'] ?? '';
        final String r2BucketName = dotenv.env['R2_BUCKET_NAME'] ?? '';
        final String r2PublicUrl = dotenv.env['R2_PUBLIC_URL'] ?? ''; 
        // ---------------------------------------------

        // Failsafe in case the .env file wasn't loaded properly
        if (r2Endpoint.isEmpty || r2AccessKey.isEmpty) {
          throw Exception("Missing Cloudflare R2 credentials in .env file");
        }

        // 1. Setup Minio (R2 connection) using the secure keys
        final minio = Minio(
          endPoint: r2Endpoint,
          accessKey: r2AccessKey,
          secretKey: r2SecretKey,
          region: 'auto',
        );

        // 2. Create a unique file name to prevent overwriting
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}';

        // 3. Upload the image to Cloudflare R2
        // 3. Upload the image to Cloudflare R2
        await minio.putObject(
          r2BucketName,
          fileName,
          Stream.value(_imageBytes!),
          size: _imageBytes!.length, // <-- ADD "size:" RIGHT HERE
          metadata: {'content-type': 'image/jpeg'}, 
        );

        // 4. Create the final public URL
        final finalImageUrl = '$r2PublicUrl/$fileName';

        // 5. Save the property text AND the image link to Supabase
        await supabase.from('properties').insert({
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'price': _priceController.text.trim(),
          'status': _selectedStatus,
          'image_url': finalImageUrl, 
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property added successfully! 🎉'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } catch (error) {
        print("Upload Error: $error");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- IMAGE UPLOAD PREVIEW AREA ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    image: _imageBytes != null 
                      ? DecorationImage(
                          image: MemoryImage(_imageBytes!), // Shows the selected image
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text('Tap to upload an image', style: TextStyle(color: Colors.grey[600])),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Property Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.holiday_village)),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_rupee)),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder(), prefixIcon: Icon(Icons.info_outline)),
                items: ['Available', 'Coming Soon', 'Sold Out'].map((String status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _selectedStatus = newValue);
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProperty,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Save Property with Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}