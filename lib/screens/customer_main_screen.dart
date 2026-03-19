import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_user.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({Key? key}) : super(key: key);

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color customerAccent = const Color(0xFF22C55E); // Mint Green for growth/buyers
  final Color vibrantAccent = const Color(0xFFFF5E5E);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox.shrink();

    final List<Widget> screens = [
      _buildDiscoverTab(user),
      const Center(child: Text('💼 Portfolio Coming Soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      const Center(child: Text('⚙️ Settings Coming Soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    ];

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: customerAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.eco_rounded, color: customerAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Countryside', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: textDark),
            onPressed: () => authProvider.logout(),
          ),
          const SizedBox(width: 8),
        ],
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

  Widget _buildDiscoverTab(AppUser user) {
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
            // Happening Header
            Text('Ready to invest,', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            Text('${user.name}? 🚀', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
            const SizedBox(height: 32),

            // Quick Categories (Zomato/Zepto style)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildCategoryPill('🔥 Trending', true),
                  _buildCategoryPill('💰 High Yield', false),
                  _buildCategoryPill('🏖️ Vacation', false),
                  _buildCategoryPill('🏢 Commercial', false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Featured Assets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Featured Assets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
                Icon(Icons.tune_rounded, color: textDark),
              ],
            ),
            const SizedBox(height: 16),

            // Mock Property List
            _buildPropertyCard(
              title: 'Sunset Boulevard Villa',
              location: 'Malibu, California',
              fractionPrice: '\$5,000',
              yieldRate: '8.5%',
              color: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 24),
            _buildPropertyCard(
              title: 'Downtown Skyline Penthouse',
              location: 'New York City, NY',
              fractionPrice: '\$2,500',
              yieldRate: '6.2%',
              color: const Color(0xFFFFE0E0),
              iconColor: const Color(0xFFFF5E5E),
            ),
            const SizedBox(height: 24),
            _buildPropertyCard(
              title: 'Lakeside Cabin Retreat',
              location: 'Lake Tahoe, Nevada',
              fractionPrice: '\$1,200',
              yieldRate: '10.1%',
              color: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF22C55E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? textDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : textDark,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String location,
    required String fractionPrice,
    required String yieldRate,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Image Area (Placeholder)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: Center(
              child: Icon(Icons.landscape_rounded, size: 80, color: iconColor.withOpacity(0.5)),
            ),
          ),
          // Content Area
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
                      child: Text('Est. Yield $yieldRate', style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                    Icon(Icons.favorite_border_rounded, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 16),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(location, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
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
                        Text('Fraction Price', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(fractionPrice, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {}, // Future: Buy fraction
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: textDark.withOpacity(0.4),
                      ),
                      child: const Text('Invest Now ⚡️', style: TextStyle(fontWeight: FontWeight.w800)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}