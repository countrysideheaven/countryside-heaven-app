import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

// --- THEME COLORS (Nature Inspired) ---
const Color appBgColor = Color(0xFFF7F9F6); 
const Color primaryDarkGreen = Color(0xFF2E5339); 
const Color softMossGreen = Color(0xFFC5D1B5); 
const Color goldAccent = Color(0xFFD4AF37); 
const Color diamondBlue = Color(0xFFB9F2FF); // For top-tier sales achievements

class SalesMainScreen extends StatefulWidget {
  const SalesMainScreen({super.key});

  @override
  State<SalesMainScreen> createState() => _SalesMainScreenState();
}

class _SalesMainScreenState extends State<SalesMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SalesDashboardTab(),
    const SalesExploreTab(),
    const SalesNetworkTab(),
    const SalesMarketingTab(),
    const SalesProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        decoration: BoxDecoration(
          color: primaryDarkGreen,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: primaryDarkGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
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
              BottomNavigationBarItem(icon: Icon(Icons.speed_rounded), label: 'Performance'),
              BottomNavigationBarItem(icon: Icon(Icons.holiday_village_rounded), label: 'Estates'),
              BottomNavigationBarItem(icon: Icon(Icons.hub_rounded), label: 'Network'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_mosaic_rounded), label: 'Studio'),
              BottomNavigationBarItem(icon: Icon(Icons.badge_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: DASHBOARD (Sales Gamification)
// ==========================================
class SalesDashboardTab extends StatelessWidget {
  const SalesDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Performance'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Target Hero Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryDarkGreen, Color(0xFF1B3624)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: primaryDarkGreen.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Q1 Revenue Target Achieved', style: TextStyle(color: softMossGreen, fontSize: 14)),
                const SizedBox(height: 8),
                const Text('₹1.2 Cr / ₹1.5 Cr', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 1.2 / 1.5,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(diamondBlue),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: diamondBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: diamondBlue)),
                      child: const Row(
                        children: [
                          Icon(Icons.diamond_rounded, color: diamondBlue, size: 16),
                          SizedBox(width: 4),
                          Text('Diamond Executive', style: TextStyle(color: diamondBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text('12 Active CPs', style: TextStyle(color: Colors.white70)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Milestones
          const Text('Your Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quarterly Bonus Unlock', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen)),
                    Text('300 pts left', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: softMossGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.flight_takeoff_rounded, color: primaryDarkGreen),
                      SizedBox(width: 12),
                      Expanded(child: Text('Close 2 more properties via your partners to win the Bali Retreat!', style: TextStyle(color: primaryDarkGreen, fontSize: 13))),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // National Sales Leaderboard
          const Text('National Sales Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          const SizedBox(height: 16),
          _buildLeaderboardRow('1', 'Vikram Singh', '4,500 pts', true),
          _buildLeaderboardRow('2', 'You', '3,200 pts', false),
          _buildLeaderboardRow('3', 'Arjun Mehta', '2,950 pts', false),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String name, String points, bool isFirst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: name == 'You' ? diamondBlue.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: name == 'You' ? Border.all(color: diamondBlue) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isFirst ? goldAccent : appBgColor,
            radius: 16,
            child: Text(rank, style: TextStyle(color: isFirst ? Colors.white : primaryDarkGreen, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: TextStyle(fontWeight: name == 'You' ? FontWeight.bold : FontWeight.normal, color: primaryDarkGreen))),
          Text(points, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen)),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: EXPLORE (Live Database)
// ==========================================
class SalesExploreTab extends StatefulWidget {
  const SalesExploreTab({super.key});

  @override
  State<SalesExploreTab> createState() => _SalesExploreTabState();
}

class _SalesExploreTabState extends State<SalesExploreTab> {
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
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Property Portfolio'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryDarkGreen))
          : RefreshIndicator(
              color: primaryDarkGreen,
              onRefresh: _fetchProperties,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  final prop = _properties[index];
                  final imageUrl = prop['image_url'] as String?;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          child: SizedBox(
                            height: 180,
                            child: imageUrl != null ? Image.network(imageUrl, fit: BoxFit.cover) : Container(color: softMossGreen, child: const Icon(Icons.landscape, size: 60, color: primaryDarkGreen)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prop['name'] ?? 'Property', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
                              const SizedBox(height: 4),
                              Text(prop['location'] ?? 'Location', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(prop['price'] ?? 'Price', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: goldAccent)),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.send_rounded, size: 16),
                                    label: const Text('Pitch to CP'),
                                    style: OutlinedButton.styleFrom(foregroundColor: primaryDarkGreen, side: const BorderSide(color: softMossGreen)),
                                  )
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
// TAB 3: NETWORK (CPs & Their Clients)
// ==========================================
class SalesNetworkTab extends StatelessWidget {
  const SalesNetworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'My Partners'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCPCard('Elite Realtors', 'CP-SHIMLA-007', 8, [
            'Aditi Sharma (Shimla, 2 Fractions)',
            'Karan Patel (Goa, 1 Fraction)'
          ]),
          const SizedBox(height: 16),
          _buildCPCard('Prime Asset Co.', 'CP-DELHI-012', 4, [
            'Neha Gupta (Chail, 1 Fraction)'
          ]),
        ],
      ),
    );
  }

  Widget _buildCPCard(String name, String code, int sales, List<String> clients) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: softMossGreen.withOpacity(0.3))),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent), 
        child: ExpansionTile(
          iconColor: primaryDarkGreen,
          collapsedIconColor: primaryDarkGreen,
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen, fontSize: 18)),
          subtitle: Text('$code • $sales Conversions', style: const TextStyle(color: goldAccent, fontSize: 13, fontWeight: FontWeight.bold)),
          leading: const CircleAvatar(backgroundColor: softMossGreen, child: Icon(Icons.storefront_rounded, color: primaryDarkGreen)),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Align(alignment: Alignment.centerLeft, child: Text('End Clients', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
            ),
            ...clients.map((c) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: primaryDarkGreen),
                  const SizedBox(width: 8),
                  Expanded(child: Text(c, style: TextStyle(color: Colors.grey[800], fontSize: 13))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 4: MARKETING STUDIO
// ==========================================
class SalesMarketingTab extends StatelessWidget {
  const SalesMarketingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Marketing Studio'),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAssetCard('Shimla Brochure', 'PDF • 4.2 MB', Icons.picture_as_pdf_rounded),
          _buildAssetCard('Goa Video Tour', 'MP4 • 28 MB', Icons.play_circle_fill_rounded),
          _buildAssetCard('Investment Pitch', 'PPTX • 12 MB', Icons.co_present_rounded),
        ],
      ),
    );
  }

  Widget _buildAssetCard(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: softMossGreen.withOpacity(0.3), shape: BoxShape.circle), child: Icon(icon, size: 32, color: primaryDarkGreen)),
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
// TAB 5: PROFILE
// ==========================================
class SalesProfileTab extends StatelessWidget {
  const SalesProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Executive Profile'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CircleAvatar(radius: 50, backgroundColor: primaryDarkGreen, child: Icon(Icons.work_rounded, size: 50, color: Colors.white))),
          const SizedBox(height: 16),
          const Text('Pooja Desai', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          const Text('Senior Sales Executive', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          // Codes Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: softMossGreen.withOpacity(0.5))),
            child: Column(
              children: [
                _buildInfoRow('Employee Code', 'EMP-102', Icons.badge_rounded),
                const Divider(height: 24),
                _buildInfoRow('Region', 'North India', Icons.map_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: const Icon(Icons.assignment_rounded, color: primaryDarkGreen),
            title: const Text('My Employment Docs'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryDarkGreen, size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen)),
      ],
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