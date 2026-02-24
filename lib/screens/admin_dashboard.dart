import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'add_property_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final supabase = Supabase.instance.client;
  
  // This list will hold the properties we get from the database
  List<dynamic> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProperties(); // Fetch the data as soon as the screen loads
  }

  // Function to get properties from Supabase
  Future<void> _fetchProperties() async {
    try {
      final data = await supabase
          .from('properties')
          .select()
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin Command Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
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
      // Floating button to add new properties
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to the Add Property screen and wait for it to return
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
          );
          
          // If it returns true (meaning a property was added), refresh the list!
          if (result == true) {
            setState(() {
              _isLoading = true; // Show loading spinner while refreshing
            });
            _fetchProperties();
          }
        },
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show a spinner while loading
          : _properties.isEmpty
              ? const Center(child: Text('No properties found. Add one!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _properties.length,
                  itemBuilder: (context, index) {
                    final property = _properties[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.holiday_village, color: Colors.red[800], size: 30),
                        ),
                        title: Text(
                          property['name'] ?? 'Unknown Property',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(property['location'] ?? 'Unknown Location'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              property['price'] ?? 'Price not set',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(property['status'] ?? 'Available'),
                          backgroundColor: Colors.green[50],
                          labelStyle: TextStyle(color: Colors.green[800]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}