import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  // List of all the tabs we are building
  final List<Widget> _pages = [
    const ExploreTab(),
    const PortfolioTab(),
    const BookingTab(),
    const CoOwnersTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Keeps all icons visible
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2E7D32), // Brand Green
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Co-owners'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: EXPLORE (Connected to Database)
// ==========================================
class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
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
      final data = await supabase.from('properties').select().eq('status', 'Available').order('created_at', ascending: false);
      if (mounted) setState(() { _properties = data; _isLoading = false; });
    } catch (error) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Countryside Heaven', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              onRefresh: _fetchProperties,
              color: const Color(0xFF2E7D32),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  final property = _properties[index];
                  final imageUrl = property['image_url'] as String?;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    clipBehavior: Clip.antiAlias,
                    elevation: 5,
                    shadowColor: Colors.black26,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 200,
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Container(color: Colors.green[50], child: const Icon(Icons.landscape, size: 80, color: Color(0xFF2E7D32))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(property['name'] ?? 'Property', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(property['location'] ?? 'Location', style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Fraction Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(property['price'] ?? 'Contact us', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enquiry sent to Sales Team!')));
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                                    child: const Text('Enquire'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ==========================================
// TAB 2: PORTFOLIO (Demonstration)
// ==========================================
class PortfolioTab extends StatelessWidget {
  const PortfolioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Portfolio'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]), borderRadius: BorderRadius.circular(20)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(height: 8),
                Text('₹13.80L', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Total Fractions Owned: 2', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Your Assets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.holiday_village))),
            title: const Text('Luxury Duplex Villa, Shimla', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('1 Fraction • Purchased at ₹6.90L'),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹7.20L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                Text('+4.3%', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// TAB 3: BOOKINGS (Demonstration)
// ==========================================
class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Holiday Bookings'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(child: Text('You have 7 nights remaining this quarter. Remember to book 90 days in advance!', style: TextStyle(color: Colors.blue))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Mock Calendar UI
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
              child: CalendarDatePicker(
                initialDate: _focusedDay,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) {
                  setState(() => _focusedDay = date);
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dates Booked!'))),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Book Stay'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dates listed for rent!'))),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: const Color(0xFF2E7D32), side: const BorderSide(color: Color(0xFF2E7D32))),
                    child: const Text('Rent Out'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 4: CO-OWNERS (Demonstration)
// ==========================================
class CoOwnersTab extends StatelessWidget {
  const CoOwnersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Your Co-owners (Shimla Duplex)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildOwner('Aarav Sharma', 'Invested Oct 2025'),
          _buildOwner('Priya Patel', 'Invested Jan 2026'),
          _buildOwner('Rahul Singh', 'Invested Feb 2026'),
        ],
      ),
    );
  }

  Widget _buildOwner(String name, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF2E7D32), child: Text(name[0], style: const TextStyle(color: Colors.white))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
      ),
    );
  }
}

// ==========================================
// TAB 5: PROFILE & DOCS (Demonstration)
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 16),
          const Text('Rahul', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Member since 2026', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('My Documents (KYC)'),
            trailing: const Icon(Icons.upload_file, color: Color(0xFF2E7D32)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document upload coming soon'))),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}