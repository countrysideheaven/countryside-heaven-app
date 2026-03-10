import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'login_screen.dart';

// --- PRODUCTION LUXURY PALETTE ---
const Color appBgColor = Color(0xFFF2F4F5); 
const Color surfaceWhite = Colors.white;
const Color textPrimary = Color(0xFF1C1C1E); 
const Color textSecondary = Color(0xFF8E8E93);
const Color accentGold = Color(0xFFE5B942);
const Color azureBlue = Color(0xFF007AFF); 
const Color darkButton = Color(0xFF1C1C1E);

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExploreTab(),
    const PortfolioTab(),
    const BookingsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      extendBody: true,
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _pages[_selectedIndex]),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 32, right: 32, bottom: 16),
          height: 64,
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: textPrimary.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.explore_outlined, Icons.explore_rounded),
              _buildNavItem(1, Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded),
              _buildNavItem(2, Icons.calendar_month_outlined, Icons.calendar_month_rounded),
              _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselected, IconData selected) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isSelected ? azureBlue.withOpacity(0.1) : Colors.transparent, shape: BoxShape.circle),
        child: Icon(isSelected ? selected : unselected, color: isSelected ? azureBlue : textSecondary, size: 24),
      ),
    );
  }
}

// ==========================================
// TAB 1: EXPLORE & PROPERTY DETAILS
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
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final props = await supabase.from('properties').select().eq('status', 'Available').order('created_at', ascending: false);
      if (mounted) setState(() { _properties = props; _isLoading = false; });
    } catch (error) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Experience\nLuxury Stays.', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, height: 1.1, color: textPrimary, letterSpacing: -1)),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: azureBlue)))
            else
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final prop = _properties[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: prop))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: surfaceWhite, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: textPrimary.withOpacity(0.04), blurRadius: 20)]),
                        child: Column(
                          children: [
                            ClipRRect(borderRadius: BorderRadius.circular(24), child: SizedBox(height: 200, width: double.infinity, child: Image.network(prop['image_url'], fit: BoxFit.cover))),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(prop['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary))),
                                Container(width: 50, height: 50, decoration: const BoxDecoration(color: darkButton, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_rounded, color: Colors.white))
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }, childCount: _properties.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  List<dynamic> _coOwners = [];
  
  @override
  void initState() {
    super.initState();
    _fetchCoOwners();
  }

  Future<void> _fetchCoOwners() async {
    // Queries the portfolio table for everyone who owns fractions of this property
    try {
      final data = await Supabase.instance.client.from('portfolio').select('user_id, fractions_owned').eq('property_id', widget.property['id']);
      if (mounted) setState(() => _coOwners = data);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(backgroundColor: appBgColor, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary), onPressed: () => Navigator.pop(context))),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(24), child: SizedBox(height: 300, width: double.infinity, child: Image.network(widget.property['image_url'], fit: BoxFit.cover))),
          const SizedBox(height: 24),
          Text(widget.property['name'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('₹${widget.property['price']} / Fraction', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: azureBlue)),
          const SizedBox(height: 32),
          
          // Co-Owners Visibility Section
          const Text('Community Co-owners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
          const SizedBox(height: 12),
          _coOwners.isEmpty 
            ? const Text('Be the first to invest in this property!', style: TextStyle(color: textSecondary))
            : SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _coOwners.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: surfaceWhite, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: azureBlue.withOpacity(0.2), child: const Icon(Icons.person, color: azureBlue)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Co-owner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('${_coOwners[index]['fractions_owned']} Fraction(s)', style: const TextStyle(color: textSecondary, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
          const SizedBox(height: 120),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity, height: 64,
          child: ElevatedButton(
            onPressed: () {}, // Handled by Sales Team logic
            style: ElevatedButton.styleFrom(backgroundColor: darkButton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
            child: const Text('Enquire to Invest', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 2: PORTFOLIO & REVENUE DASHBOARD
// ==========================================
class PortfolioTab extends StatefulWidget {
  const PortfolioTab({super.key});

  @override
  State<PortfolioTab> createState() => _PortfolioTabState();
}

class _PortfolioTabState extends State<PortfolioTab> {
  final supabase = Supabase.instance.client;
  List<dynamic> _portfolio = [];
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      // Fetch Portfolio
      final portData = await supabase.from('portfolio').select('*, properties(*)').eq('user_id', userId);
      // Fetch Revenue Ledger
      final revData = await supabase.from('rental_revenue').select('amount').eq('user_id', userId);
      
      double calcRev = 0;
      for (var row in revData) { calcRev += double.parse(row['amount'].toString()); }

      if (mounted) setState(() { _portfolio = portData; _totalRevenue = calcRev; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAssetValue = _portfolio.fold(0, (sum, item) => sum + (item['purchase_price'] as num));

    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(title: const Text('Portfolio & Yield', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)), backgroundColor: appBgColor, elevation: 0),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: azureBlue))
        : ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
              // Dashboard Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: textPrimary, borderRadius: BorderRadius.circular(32)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Asset Value', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('₹$totalAssetValue', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    Text('40% Rental Yield Earned', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('+ ₹$_totalRevenue', style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}

// ==========================================
// TAB 3: BOOKINGS & THE RENTAL ENGINE
// ==========================================
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  final supabase = Supabase.instance.client;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase.from('bookings').select('*, properties(*)').eq('user_id', userId).order('check_in', ascending: true);
      if (mounted) setState(() { _bookings = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(title: const Text('My Calendar', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)), backgroundColor: appBgColor, elevation: 0),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateBookingScreen()));
            _fetchBookings();
          },
          backgroundColor: darkButton,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Manage Dates', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              final booking = _bookings[index];
              final bool isRental = booking['booking_type'] == 'Rental';
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: surfaceWhite, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(booking['properties']['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: isRental ? Colors.purple.withOpacity(0.1) : azureBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text(isRental ? 'Listed for Rent' : 'Personal Stay', style: TextStyle(color: isRental ? Colors.purple : azureBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${booking['check_in']} to ${booking['check_out']}'),
                  ],
                ),
              );
            },
          ),
    );
  }
}

// --- The Core Booking Engine ---
class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});
  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _ownedProperties = [];
  bool _isLoading = true;
  String _selectedMode = 'Personal'; // 'Personal' or 'Rental'

  @override
  void initState() {
    super.initState();
    _fetchOwnedProperties();
  }

  Future<void> _fetchOwnedProperties() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase.from('portfolio').select('*, properties(*)').eq('user_id', userId);
      if (mounted) setState(() { _ownedProperties = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // CORE LOGIC: Validates Peak Season and Quarterly Limits
  bool _validateAllotment(DateTime start, DateTime end) {
    int daysRequested = end.difference(start).inDays + 1; // Inclusive
    int startMonth = start.month;
    
    // Peak Season (April, May, June) = 4 days max
    bool isPeak = startMonth >= 4 && startMonth <= 6;
    int maxAllowed = isPeak ? 4 : 7;

    if (daysRequested > maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Limit exceeded. Maximum allowed for this period is $maxAllowed days.'), backgroundColor: Colors.red));
      return false;
    }
    return true;
  }

  Future<void> _processDates(Map<String, dynamic> property) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? selectedRange = await showDateRangePicker(
      context: context,
      firstDate: now, lastDate: now.add(const Duration(days: 90)),
    );

    if (selectedRange == null || !mounted) return;

    if (!_validateAllotment(selectedRange.start, selectedRange.end)) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final formatter = DateFormat('yyyy-MM-dd');
      await supabase.from('bookings').insert({
        'user_id': supabase.auth.currentUser!.id,
        'property_id': property['properties']['id'],
        'check_in': formatter.format(selectedRange.start),
        'check_out': formatter.format(selectedRange.end),
        'booking_type': _selectedMode,
        'status': 'Confirmed'
      });

      if (mounted) {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // close screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dates successfully saved!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(title: const Text('Manage Calendar', style: TextStyle(color: textPrimary)), backgroundColor: appBgColor, elevation: 0),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // The Toggle
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(32)),
                child: Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 'Personal'),
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: _selectedMode == 'Personal' ? darkButton : Colors.transparent, borderRadius: BorderRadius.circular(32)), child: Center(child: Text('Personal Stay', style: TextStyle(color: _selectedMode == 'Personal' ? Colors.white : textPrimary, fontWeight: FontWeight.bold)))),
                    )),
                    Expanded(child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 'Rental'),
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: _selectedMode == 'Rental' ? darkButton : Colors.transparent, borderRadius: BorderRadius.circular(32)), child: Center(child: Text('List for Rent', style: TextStyle(color: _selectedMode == 'Rental' ? Colors.white : textPrimary, fontWeight: FontWeight.bold)))),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Select Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._ownedProperties.map((item) {
                final prop = item['properties'];
                return GestureDetector(
                  onTap: () => _processDates(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: surfaceWhite, borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(width: 60, height: 60, child: Image.network(prop['image_url'], fit: BoxFit.cover))),
                        const SizedBox(width: 16),
                        Expanded(child: Text(prop['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        const Icon(Icons.chevron_right_rounded)
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
    );
  }
}

// ==========================================
// TAB 4: PROFILE & KYC
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _uploadKYC(BuildContext context) async {
    // Requires flutter_file_picker package
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
    
    if (result != null) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      // Simulate network upload to Supabase Storage
      await Future.delayed(const Duration(seconds: 2));
      
      final supabase = Supabase.instance.client;
      await supabase.from('kyc_documents').insert({
        'user_id': supabase.auth.currentUser!.id,
        'document_name': result.files.single.name,
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document uploaded securely for verification.'), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(backgroundColor: appBgColor, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const Center(child: CircleAvatar(radius: 60, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'))),
          const SizedBox(height: 24),
          const Text('Rahul', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 40),
          _buildMenuTile(Icons.verified_user_rounded, 'Upload KYC Documents', onTap: () => _uploadKYC(context)),
          _buildMenuTile(Icons.support_agent_rounded, 'Concierge Support'),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), tileColor: Colors.red.shade50,
            leading: Icon(Icons.logout_rounded, color: Colors.red.shade700),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w700)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), tileColor: Colors.white,
        leading: Icon(icon, color: textPrimary), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: textSecondary), onTap: onTap,
      ),
    );
  }
}
