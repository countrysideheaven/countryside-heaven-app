import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'add_property_screen.dart';

// --- THEME COLORS (Nature Inspired) ---
const Color appBgColor = Color(0xFFF7F9F6); // Soft earthy off-white
const Color primaryDarkGreen = Color(0xFF2E5339); // Deep forest green
const Color softMossGreen = Color(0xFFC5D1B5); // Bubbly light green
const Color goldAccent = Color(0xFFD4AF37); // Premium gold

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminPropertiesTab(),
    const AdminNetworkTab(),
    const AdminMarketingTab(),
    const AdminCalendarTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      // Smooth fade transition between tabs
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      // Custom "Bubbly" Floating Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        decoration: BoxDecoration(
          color: primaryDarkGreen,
          borderRadius: BorderRadius.circular(40), // Ultra rounded
          boxShadow: [
            BoxShadow(
              color: primaryDarkGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: softMossGreen.withOpacity(0.6),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.holiday_village_rounded), label: 'Estates'),
              BottomNavigationBarItem(icon: Icon(Icons.account_tree_rounded), label: 'Network'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_mosaic_rounded), label: 'Studio'),
              BottomNavigationBarItem(icon: Icon(Icons.edit_calendar_rounded), label: 'Reserve'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: PROPERTIES (Live Database + Update Price)
// ==========================================
class AdminPropertiesTab extends StatefulWidget {
  const AdminPropertiesTab({super.key});

  @override
  State<AdminPropertiesTab> createState() => _AdminPropertiesTabState();
}

class _AdminPropertiesTabState extends State<AdminPropertiesTab> {
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
      final data = await supabase.from('properties').select().order('created_at', ascending: false);
      if (mounted) setState(() { _properties = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Bubbly Dialog to Update Price (UI Demo)
  void _showUpdatePriceDialog(String propertyName, String currentPrice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text('Update Price: $propertyName', style: const TextStyle(color: primaryDarkGreen, fontSize: 18)),
        content: TextField(
          decoration: InputDecoration(
            hintText: currentPrice,
            filled: true,
            fillColor: appBgColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.currency_rupee, color: primaryDarkGreen),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Price updated successfully!'), backgroundColor: primaryDarkGreen));
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Estate Management'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryDarkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
          if (result == true) {
            setState(() => _isLoading = true);
            _fetchProperties();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryDarkGreen))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                final prop = _properties[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(prop['name'] ?? 'Property', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkGreen))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: softMossGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                              child: Text(prop['status'] ?? 'Available', style: const TextStyle(color: primaryDarkGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(prop['location'] ?? 'Location', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(prop['price'] ?? 'No price', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: goldAccent)),
                            OutlinedButton.icon(
                              onPressed: () => _showUpdatePriceDialog(prop['name'], prop['price']),
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text('Update Price'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryDarkGreen,
                                side: const BorderSide(color: softMossGreen),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// TAB 2: NETWORK (Sales -> CP -> Clients)
// ==========================================
class AdminNetworkTab extends StatelessWidget {
  const AdminNetworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Global Network'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSalesPersonCard('Vikram Singh', 'Regional Head', 12, 45, [
            _buildCPCard('Elite Realtors', 8, [
              'Aditi Sharma (Shimla, 2 Fractions)',
              'Karan Patel (Goa, 1 Fraction)'
            ]),
            _buildCPCard('Prime Asset Co.', 4, [
              'Neha Gupta (Chail, 1 Fraction)'
            ]),
          ]),
          const SizedBox(height: 16),
          _buildSalesPersonCard('Pooja Desai', 'Senior Executive', 5, 18, [
            _buildCPCard('Luxury Homes Ltd', 3, ['Rohan Verma (Shimla, 1 Fraction)']),
          ]),
        ],
      ),
    );
  }

  // Smooth, bubbly expansion cards
  Widget _buildSalesPersonCard(String name, String role, int cps, int conversions, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: softMossGreen.withOpacity(0.3))),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent), // Removes the ugly default lines
        child: ExpansionTile(
          iconColor: primaryDarkGreen,
          collapsedIconColor: primaryDarkGreen,
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen, fontSize: 18)),
          subtitle: Text('$role • $cps Partners • $conversions Conversions', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          leading: const CircleAvatar(backgroundColor: softMossGreen, child: Icon(Icons.person, color: primaryDarkGreen)),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: children,
        ),
      ),
    );
  }

  Widget _buildCPCard(String name, int sales, List<String> clients) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: appBgColor, borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          subtitle: Text('$sales Total Sales', style: const TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          leading: const Icon(Icons.handshake_rounded, color: primaryDarkGreen, size: 20),
          children: clients.map((c) => Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 12, right: 16),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: softMossGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(c, style: TextStyle(color: Colors.grey[800], fontSize: 13))),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 3: MARKETING STUDIO (UI Demo)
// ==========================================
class AdminMarketingTab extends StatelessWidget {
  const AdminMarketingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Marketing Studio'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryDarkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: const Text('Upload Material', style: TextStyle(color: Colors.white)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker opening...')));
        },
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAssetCard('Shimla Brochure', 'PDF • 4.2 MB', Icons.picture_as_pdf_rounded),
          _buildAssetCard('Goa Video Tour', 'MP4 • 28 MB', Icons.play_circle_fill_rounded),
          _buildAssetCard('Investment Pitch', 'PPTX • 12 MB', Icons.co_present_rounded),
          _buildAssetCard('Social Banners', 'ZIP • 18 MB', Icons.image_rounded),
        ],
      ),
    );
  }

  Widget _buildAssetCard(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: softMossGreen.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: primaryDarkGreen),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 4: CALENDAR / RESERVATIONS (UI Demo)
// ==========================================
class AdminCalendarTab extends StatefulWidget {
  const AdminCalendarTab({super.key});

  @override
  State<AdminCalendarTab> createState() => _AdminCalendarTabState();
}

class _AdminCalendarTabState extends State<AdminCalendarTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Reserve Dates'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select Dates to Block for Maintenance or VIPs.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dates blocked successfully!'), backgroundColor: primaryDarkGreen));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDarkGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Block Selected Dates', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SHARED HELPER FOR PREMIUM APP BAR ---
AppBar _buildPremiumAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: primaryDarkGreen, fontSize: 22)),
    backgroundColor: appBgColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    actions: [
      IconButton(
        icon: const Icon(Icons.logout_rounded, color: Colors.grey),
        onPressed: () async {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      )
    ],
  );
}