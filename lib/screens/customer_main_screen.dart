import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart'; // Needed for KYC Upload
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../models/app_user.dart';
import '../models/property_models.dart';
import 'customer/customer_property_details_screen.dart'; // Import the new screen

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({Key? key}) : super(key: key);

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = '🔥 Trending'; // State for the pills

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color customerAccent = const Color(0xFF22C55E); 
  final Color vibrantAccent = const Color(0xFFFF5E5E);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox.shrink();

    final List<Widget> screens = [
      _buildDiscoverTab(user, propertyProvider),
      _buildPortfolioTab(user, propertyProvider),
      _buildProfileTab(user, authProvider),
    ];

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👉 NEW: The Company Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            
            // 👉 NEW: Company Name (Wrapped in Flexible to prevent overflow)
            Flexible(
              child: Text(
                'Countryside Heaven',
                style: TextStyle(
                  color: textDark, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 20, 
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: textDark,
            selectedItemColor: customerAccent,
            unselectedItemColor: Colors.grey.shade600,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Discover'),
              BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'Portfolio'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🌍 1. THE DISCOVER TAB
  // ==========================================
  Widget _buildDiscoverTab(AppUser user, PropertyProvider provider) {
    final properties = provider.properties;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.95 + (0.05 * value), child: child),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ready to invest,', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            Text('${user.name}? 🚀', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
            const SizedBox(height: 32),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildCategoryPill('🔥 Trending'),
                  _buildCategoryPill('💰 High Yield'),
                  _buildCategoryPill('🏖️ Vacation'),
                  _buildCategoryPill('🏢 Commercial'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Featured Assets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
                Icon(Icons.tune_rounded, color: textDark),
              ],
            ),
            const SizedBox(height: 16),

            if (properties.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Icon(Icons.landscape_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No Assets Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
                    Text('Check back later for new investments.', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  double startingPrice = 0.0;
                  if (prop.units.isNotEmpty) {
                    startingPrice = prop.units.map((u) => u.fractionPrice).reduce((a, b) => a < b ? a : b);
                  }

                  return _buildLivePropertyCard(
                    property: prop,
                    startingPrice: startingPrice,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Interactive Category Pill
  Widget _buildCategoryPill(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? textDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : textDark, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  // Clickable Property Card
  Widget _buildLivePropertyCard({required Property property, required double startingPrice}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerPropertyDetailsScreen(property: property, startingPrice: startingPrice),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              // 👉 FIXED: Image loading strictly via Network for R2 URLs
              child: property.imageUrls.isNotEmpty
                  ? Image.network(
                      property.imageUrls.first, 
                      fit: BoxFit.cover, 
                      errorBuilder: (c, e, s) => _buildFallbackBanner(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator(color: customerAccent));
                      },
                    )
                  : _buildFallbackBanner(),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Est. Yield 8-12%', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                      Icon(Icons.favorite_border_rounded, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(property.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(property.location, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fraction starts at', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                          // 👉 FIXED: Currency updated to Rupee
                          Text('₹${startingPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerPropertyDetailsScreen(property: property, startingPrice: startingPrice)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: textDark.withOpacity(0.4),
                        ),
                        child: const Text('Invest', style: TextStyle(fontWeight: FontWeight.w800)),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(child: Icon(Icons.landscape_rounded, size: 64, color: Colors.grey.shade300)),
    );
  }

  // ==========================================
  // 💼 2. THE PORTFOLIO TAB
  // ==========================================
  Widget _buildPortfolioTab(AppUser user, PropertyProvider provider) {
    List<Map<String, dynamic>> ownedFractions = [];
    double totalPortfolioValue = 0.0;

    for (var prop in provider.properties) {
      for (var unit in prop.units) {
        for (var frac in unit.fractions) {
          if (frac.ownerId == user.id) {
            ownedFractions.add({'property': prop, 'unit': unit, 'fraction': frac});
            totalPortfolioValue += unit.fractionPrice;
          }
        }
      }
    }

    final userBookings = provider.bookings.where((b) => b.userId == user.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Portfolio 💼', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: customerAccent,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: customerAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Asset Value', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // 👉 FIXED: Currency updated to Rupee
                Text('₹${totalPortfolioValue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${ownedFractions.length} Fractions Owned', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),

          Text('My Properties', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 16),
          if (ownedFractions.isEmpty)
            _buildEmptyState(Icons.key_off_rounded, 'No Assets Yet', 'Explore the discover tab to find your first fractional property.')
          else
            ...ownedFractions.map((item) => _buildOwnedAssetCard(item['property'], item['unit'], item['fraction'])).toList(),
          
          const SizedBox(height: 40),

          Text('Upcoming Stays', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 16),
          if (userBookings.isEmpty)
            _buildEmptyState(Icons.event_busy_rounded, 'No Stays Booked', 'Ready for a vacation? Contact your agent to book a slot.')
          else
            ...userBookings.map((b) => _buildBookingCard(b)).toList(),
        ],
      ),
    );
  }

  Widget _buildOwnedAssetCard(Property property, Unit unit, Fraction fraction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(height: 60, width: 60, decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.key_rounded, color: Color(0xFF6366F1), size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                const SizedBox(height: 4),
                Text('${unit.name} • Fraction ${fraction.id}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact your agent to book dates!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: textDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    bool isLiving = booking.type == 'living';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(height: 60, width: 60, decoration: BoxDecoration(color: isLiving ? const Color(0xFFE0E7FF) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(16)), child: Icon(isLiving ? Icons.home_rounded : Icons.monetization_on_rounded, color: isLiving ? const Color(0xFF6366F1) : const Color(0xFFD97706), size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.unitName ?? 'Unknown Unit', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                const SizedBox(height: 4),
                Text('${booking.startDate.day}/${booking.startDate.month} - ${booking.endDate.day}/${booking.endDate.month}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isLiving ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFD97706).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(isLiving ? 'LIVING' : 'RENTING', style: TextStyle(color: isLiving ? const Color(0xFF6366F1) : const Color(0xFFD97706), fontWeight: FontWeight.w900, fontSize: 10))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==========================================
  // ⚙️ 3. THE PROFILE TAB
  // ==========================================
  Widget _buildProfileTab(AppUser user, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings ⚙️', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 32),
          
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 50, backgroundColor: customerAccent.withOpacity(0.2), child: Text(user.name[0].toUpperCase(), style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: customerAccent))),
                const SizedBox(height: 16),
                Text(user.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                Text(user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Working Profile Buttons
          _buildProfileOption(Icons.verified_user_rounded, 'KYC & Documents', 'Upload ID or view contracts', onTap: () {
            _showKycUploadDialog(context, user);
          }),
          _buildProfileOption(Icons.support_agent_rounded, 'Contact My Agent', 'Reach out to your representative', onTap: () {
            _showAgentContactDialog(context, user);
          }),
          _buildProfileOption(Icons.logout_rounded, 'Log Out', 'Securely sign out', color: Colors.red, onTap: () => authProvider.logout()),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, {Color color = const Color(0xFF111111), required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  // --- INTERACTIVE DIALOGS ---

  void _showAgentContactDialog(BuildContext context, AppUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 36, backgroundColor: customerAccent.withOpacity(0.1), child: Icon(Icons.support_agent_rounded, size: 36, color: customerAccent)),
              const SizedBox(height: 24),
              Text('Your Agent Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
              const SizedBox(height: 8),
              Text('Provide this code to support or use it when making a new purchase.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, width: 2)),
                child: Center(
                  child: SelectableText(user.referredByCode ?? 'ADMIN123', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: textDark)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  void _showKycUploadDialog(BuildContext context, AppUser user) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    Uint8List? fileBytes;
    String? fileName;
    String? fileExt;
    bool isUploading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload KYC Document', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                    const SizedBox(height: 8),
                    Text('Upload your ID or Passport for verification.', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 32),

                    InkWell(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                          withData: true, 
                        );

                        if (result != null) {
                          setState(() {
                            fileBytes = result.files.first.bytes;
                            fileName = result.files.first.name;
                            fileExt = result.files.first.extension;
                            errorMessage = null;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(color: const Color(0xFFF7F7F9), border: Border.all(color: Colors.grey.shade300, width: 2), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Icon(fileBytes != null ? Icons.file_present_rounded : Icons.cloud_upload_rounded, size: 48, color: fileBytes != null ? customerAccent : Colors.grey),
                            const SizedBox(height: 16),
                            Text(fileBytes != null ? fileName! : 'Tap to Browse Files', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: fileBytes != null ? customerAccent : textDark)),
                            if (fileBytes == null) const Text('Supports PDF, JPG, PNG', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                        child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: isUploading ? null : () async {
                          if (fileBytes == null || fileExt == null || fileName == null) {
                            setState(() => errorMessage = 'Please select a file to upload.');
                            return;
                          }

                          setState(() => isUploading = true);
                          try {
                            await propertyProvider.uploadKycDocument(user.id, fileName!, fileBytes!, fileExt!);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document sent for verification! 🔒'), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                            setState(() {
                              isUploading = false;
                              errorMessage = 'Upload failed. Please check your network connection.';
                            });
                          }
                        },
                        child: isUploading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Submit for Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}