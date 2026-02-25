import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

// --- THEME COLORS (Nature Inspired) ---
const Color appBgColor = Color(0xFFF7F9F6); 
const Color primaryDarkGreen = Color(0xFF2E5339); 
const Color softMossGreen = Color(0xFFC5D1B5); 
const Color goldAccent = Color(0xFFD4AF37); 

class PartnerMainScreen extends StatefulWidget {
  const PartnerMainScreen({super.key});

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PartnerDashboardTab(),
    const PartnerExploreTab(),
    const PartnerClientsTab(),
    const PartnerMarketingTab(),
    const PartnerProfileTab(),
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
            selectedItemColor: goldAccent, // Gold for partners
            unselectedItemColor: softMossGreen.withOpacity(0.6),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.holiday_village_rounded), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'Clients'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_mosaic_rounded), label: 'Studio'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: DASHBOARD (Gamification & Earnings)
// ==========================================
class PartnerDashboardTab extends StatelessWidget {
  const PartnerDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Partner Dashboard'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Earnings Hero Card
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
                const Text('Total Commission Earned', style: TextStyle(color: softMossGreen, fontSize: 14)),
                const SizedBox(height: 8),
                const Text('₹4,50,000', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: goldAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent)),
                      child: const Row(
                        children: [
                          Icon(Icons.star_rounded, color: goldAccent, size: 16),
                          SizedBox(width: 4),
                          Text('Gold Partner', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text('8 Active Clients', style: TextStyle(color: Colors.white70)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Gamification & Milestones
          const Text('Your Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Next Milestone: Platinum', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen)),
                    Text('1,200 / 2,000 Pts', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 1200 / 2000,
                    minHeight: 12,
                    backgroundColor: appBgColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(goldAccent),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.card_giftcard_rounded, color: goldAccent),
                      SizedBox(width: 12),
                      Expanded(child: Text('Reward: Sell 2 more fractions to unlock a free 2-night stay in Goa!', style: TextStyle(color: primaryDarkGreen, fontSize: 13))),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Leaderboard Snapshot
          const Text('Regional Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          const SizedBox(height: 16),
          _buildLeaderboardRow('1', 'Elite Realtors', '2,800 pts', true),
          _buildLeaderboardRow('2', 'You', '1,200 pts', false),
          _buildLeaderboardRow('3', 'Prime Asset Co.', '950 pts', false),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String name, String points, bool isFirst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: name == 'You' ? softMossGreen.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: name == 'You' ? Border.all(color: primaryDarkGreen.withOpacity(0.3)) : null,
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
          Text(points, style: const TextStyle(fontWeight: FontWeight.bold, color: goldAccent)),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: EXPLORE (Live Database)
// ==========================================
class PartnerExploreTab extends StatefulWidget {
  const PartnerExploreTab({super.key});

  @override
  State<PartnerExploreTab> createState() => _PartnerExploreTabState();
}

class _PartnerExploreTabState extends State<PartnerExploreTab> {
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
      appBar: _buildPremiumAppBar(context, 'Explore Estates'),
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
                                    icon: const Icon(Icons.share_rounded, size: 16),
                                    label: const Text('Share Asset'),
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
// TAB 3: CLIENTS 
// ==========================================
class PartnerClientsTab extends StatelessWidget {
  const PartnerClientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'My Clients'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildClientCard('Aditi Sharma', 'Shimla Duplex', '2 Fractions', 'Active'),
          _buildClientCard('Karan Patel', 'Goa Beachfront', '1 Fraction', 'Active'),
          _buildClientCard('Suresh Rao', 'Munnar Estate', 'Pending Doc', 'Pending'),
        ],
      ),
    );
  }

  Widget _buildClientCard(String name, String prop, String fractions, String status) {
    bool isActive = status == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: softMossGreen.withOpacity(0.5), child: Text(name[0], style: const TextStyle(color: primaryDarkGreen, fontWeight: FontWeight.bold))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDarkGreen, fontSize: 16)),
                Text('$prop • $fractions', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: isActive ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: isActive ? Colors.green[700] : Colors.orange[700], fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

// ==========================================
// TAB 4: MARKETING STUDIO
// ==========================================
class PartnerMarketingTab extends StatelessWidget {
  const PartnerMarketingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Marketing Materials'),
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
class PartnerProfileTab extends StatelessWidget {
  const PartnerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Partner Profile'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CircleAvatar(radius: 50, backgroundColor: softMossGreen, child: Icon(Icons.storefront_rounded, size: 50, color: primaryDarkGreen))),
          const SizedBox(height: 16),
          const Text('Elite Realtors', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          const Text('Joined 2025', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          // Codes Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: softMossGreen.withOpacity(0.5))),
            child: Column(
              children: [
                _buildInfoRow('Partner Code', 'CP-SHIMLA-007', Icons.qr_code_rounded),
                const Divider(height: 24),
                _buildInfoRow('Account Manager', 'Vikram Singh (EMP-102)', Icons.support_agent_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: const Icon(Icons.description_rounded, color: primaryDarkGreen),
            title: const Text('My Documents (KYC/Agreements)'),
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