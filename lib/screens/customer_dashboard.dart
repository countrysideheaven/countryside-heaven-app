import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final supabase = Supabase.instance.client;
  
  List<dynamic> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    try {
      // Fetch 'Available' properties, newest first
      final data = await supabase
          .from('properties')
          .select()
          .eq('status', 'Available')
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _properties = data;
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching properties: $error");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Countryside Heaven', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile & Logout',
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen())
                );
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              onRefresh: _fetchProperties,
              color: const Color(0xFF2E7D32),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to Magical Holidays',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explore your fractional properties and book your 28 complimentary nights.',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    _properties.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No properties available at the moment.', style: TextStyle(fontSize: 16)),
                          )
                        : ListView.builder(
                            shrinkWrap: true, 
                            physics: const NeverScrollableScrollPhysics(), 
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _properties.length,
                            itemBuilder: (context, index) {
                              final property = _properties[index];
                              return _buildPropertyCard(property);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    // Extract the image URL we saved in the database
    final imageUrl = property['image_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- UPDATED IMAGE SECTION ---
            SizedBox(
              height: 200,
              width: double.infinity,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover, // Makes sure the image fills the box beautifully
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child; // Image is fully loaded
                        return Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFF2E7D32),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // If the link is broken, show a fallback icon
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        );
                      },
                    )
                  : Container(
                      // Fallback if no image was uploaded at all
                      color: Colors.green[50],
                      child: const Center(child: Icon(Icons.landscape, size: 80, color: Color(0xFF2E7D32))),
                    ),
            ),
            // ------------------------------
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property['name'] ?? 'Premium Resort',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.favorite_border, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        property['location'] ?? 'Location',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Investment starting at', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            property['price'] ?? 'Contact for price',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Future feature: Open detailed property view
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Explore'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}