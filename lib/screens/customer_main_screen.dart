import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

// --- LUXURY PALETTE ---
const Color appBgColor = Color(0xFFF2F4F5); // Soft cool grey background
const Color surfaceWhite = Colors.white;
const Color textPrimary = Color(0xFF1C1C1E); // Deep slate, almost black
const Color textSecondary = Color(0xFF8E8E93);
const Color accentGold = Color(0xFFE5B942); // For ratings
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
    const Center(child: Text('Portfolio Coming Soon')),
    const Center(child: Text('Bookings Coming Soon')),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      extendBody: true,
      body: _pages[_selectedIndex],
      // Floating Pill Navigation (Minimalist)
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 32, right: 32, bottom: 16),
          height: 64,
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: textPrimary.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 12))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.maps_home_work_outlined, Icons.maps_home_work_rounded),
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
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? darkButton : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? selected : unselected,
          color: isSelected ? Colors.white : textSecondary,
          size: 24,
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: EXPLORE (Staggered Animations & Fluid UI)
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
  String _selectedFilter = 'All Estates';

  final List<String> _filters = ['All Estates', 'Mountains', 'Beaches', 'Forests'];

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
            // --- CUSTOM HEADER ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar
                        const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                        // Action Icons
                        Row(
                          children: [
                            _buildCircleButton(Icons.notifications_none_rounded),
                            const SizedBox(width: 12),
                            _buildCircleButton(Icons.search_rounded),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Experience\nLuxury Stays.',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, height: 1.1, color: textPrimary, letterSpacing: -1),
                    ),
                    const SizedBox(height: 24),
                    // Filters
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = filter == _selectedFilter;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = filter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? darkButton : surfaceWhite,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: isSelected ? [BoxShadow(color: darkButton.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
                              ),
                              child: Row(
                                children: [
                                  if (filter == 'All Estates') ...[
                                    Icon(Icons.business_rounded, size: 18, color: isSelected ? Colors.white : textPrimary),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    filter,
                                    style: TextStyle(color: isSelected ? Colors.white : textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- PROPERTIES LIST ---
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: darkButton)))
            else
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final prop = _properties[index];
                      // Use a staggered animation based on index
                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _buildPropertyCard(context, prop, index),
                      );
                    },
                    childCount: _properties.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: surfaceWhite, shape: BoxShape.circle),
      child: Icon(icon, color: textPrimary, size: 22),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> prop, int index) {
    final imageUrl = prop['image_url'] as String?;
    final heroTag = 'property_image_${prop['id'] ?? index}'; // Unique tag for fluid transition

    return GestureDetector(
      onTap: () {
        // Fluid transition to detail screen
        Navigator.of(context).push(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: animation,
              child: PropertyDetailScreen(property: prop, heroTag: heroTag),
            );
          },
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: textPrimary.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            // IMAGE SECTION
            Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(color: Colors.grey[200], child: const Icon(Icons.landscape, color: Colors.grey)),
                    ),
                  ),
                ),
                // Badges overlay
                Positioned(
                  top: 16, left: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: Colors.white.withOpacity(0.3),
                        child: const Text('15% YIELD', style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16, right: 16,
                  child: Row(
                    children: [
                      _buildGlassIcon(Icons.share_outlined),
                      const SizedBox(width: 8),
                      _buildGlassIcon(Icons.favorite_border_rounded),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            // DETAILS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prop['name'] ?? 'Luxury Estate', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(prop['location'] ?? 'Location', style: const TextStyle(color: textSecondary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(prop['price'] ?? '₹0', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2, left: 4),
                            child: Text('/ Fraction', style: TextStyle(fontSize: 12, color: textSecondary)),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: const [
                              Icon(Icons.star_rounded, color: accentGold, size: 16),
                              SizedBox(width: 4),
                              Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Amenities Icons
                      Row(
                        children: [
                          _buildAmenityIcon(Icons.bed_rounded, '2 bed'),
                          const SizedBox(width: 16),
                          _buildAmenityIcon(Icons.bathtub_outlined, '2 bath'),
                          const SizedBox(width: 16),
                          _buildAmenityIcon(Icons.square_foot_rounded, '1200 sqft'),
                        ],
                      )
                    ],
                  ),
                ),
                // Circular Arrow Button
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(color: darkButton, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGlassIcon(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white.withOpacity(0.3),
          child: Icon(icon, color: textPrimary, size: 18),
        ),
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 12)),
      ],
    );
  }
}

// ==========================================
// TAB 5: PROFILE
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: appBgColor,
      body: Center(child: Text('Profile View', style: TextStyle(fontSize: 20, color: textPrimary))),
    );
  }
}

// ==========================================
// NEW: IMMERSIVE PROPERTY DETAIL SCREEN
// ==========================================
class PropertyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> property;
  final String heroTag;

  const PropertyDetailScreen({super.key, required this.property, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final imageUrl = property['image_url'] as String?;

    return Scaffold(
      backgroundColor: appBgColor,
      body: Stack(
        children: [
          // 1. SCROLLABLE CONTENT
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Image Region
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: SizedBox(
                        height: 400,
                        width: double.infinity,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey[300]),
                      ),
                    ),
                    // Gradient overlay for text readability
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [appBgColor, appBgColor.withOpacity(0.0)],
                        ),
                      ),
                    ),
                    // Mini Carousel Overlapping Image
                    Positioned(
                      bottom: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMiniImage(imageUrl),
                          const SizedBox(width: 8),
                          _buildMiniImage(imageUrl),
                          const SizedBox(width: 8),
                          _buildMiniImage(imageUrl),
                        ],
                      ),
                    )
                  ],
                ),
                
                // Details Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: const BoxDecoration(
                    color: appBgColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property['name'] ?? 'Luxury Estate', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(property['price'] ?? '₹0', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary)),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                              const SizedBox(width: 4),
                              Text(property['location'] ?? 'Location', style: const TextStyle(color: textSecondary, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Big Amenity Blocks
                      Row(
                        children: [
                          Expanded(child: _buildBigAmenityBlock(Icons.king_bed_rounded, '2 King Beds')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildBigAmenityBlock(Icons.wifi_rounded, 'Free wi-fi')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildBigAmenityBlock(Icons.tv_rounded, 'HD TV')),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Description
                      const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
                      const SizedBox(height: 12),
                      Text(
                        'This stunning fractional ownership property offers luxury stays with fine dining, a spa, and elegant event spaces for unforgettable memories. Invest today and unlock 28 complimentary nights every year across our global portfolio.',
                        style: TextStyle(fontSize: 14, color: textSecondary.withOpacity(0.8), height: 1.6),
                      ),
                      const SizedBox(height: 120), // Padding for the bottom sticky button
                    ],
                  ),
                )
              ],
            ),
          ),

          // 2. TOP ACTION BUTTONS (Floating)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.white.withOpacity(0.4),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
                        ),
                      ),
                    ),
                  ),
                  // Share & Percent Icons
                  Row(
                    children: [
                      _buildFloatingTopIcon(Icons.ios_share_rounded),
                      const SizedBox(width: 12),
                      _buildFloatingTopIcon(Icons.percent_rounded),
                    ],
                  )
                ],
              ),
            ),
          ),

          // 3. STICKY BOTTOM BUTTON
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [appBgColor, appBgColor.withOpacity(0.0)],
                )
              ),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkButton,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 10,
                    shadowColor: darkButton.withOpacity(0.4),
                  ),
                  child: const Text('Invest Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingTopIcon(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white.withOpacity(0.4),
          child: Icon(icon, color: textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _buildMiniImage(String? imageUrl) {
    return Container(
      width: 70, height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
    );
  }

  Widget _buildBigAmenityBlock(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: textPrimary.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: textPrimary, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
        ],
      ),
    );
  }
}