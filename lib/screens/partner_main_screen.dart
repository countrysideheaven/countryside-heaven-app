import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For the Copy functionality
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../models/app_user.dart';
import '../models/property_models.dart';

import 'admin/client_portfolio_screen.dart'; 
import 'customer/customer_property_details_screen.dart';

class PartnerMainScreen extends StatefulWidget {
  const PartnerMainScreen({Key? key}) : super(key: key);

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color partnerAccent = const Color(0xFF8B5CF6); // Vibrant Purple for Partners

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox.shrink();

    final List<Widget> screens = [
      _buildDashboardTab(user, authProvider, propertyProvider),
      _buildClientsTab(user, authProvider),
      _buildPropertiesTab(propertyProvider),
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
              decoration: BoxDecoration(color: partnerAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.handshake_rounded, color: partnerAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Partner Hub', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
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
            selectedItemColor: partnerAccent,
            unselectedItemColor: Colors.grey.shade600,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Earnings'),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Clients'),
              BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Assets'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 📊 1. EARNINGS DASHBOARD TAB
  // ==========================================
  Widget _buildDashboardTab(AppUser user, AuthProvider authProvider, PropertyProvider propertyProvider) {
    // Partners only see their DIRECT clients
    final directClients = authProvider.getDownline(user.myReferralCode);
    final clientIds = directClients.map((u) => u.id).toList();

    int totalFractionsSold = 0;
    double totalSalesVolume = 0.0;
    double myEarnings = 0.0;

    // Calculate Sales
    for (var prop in propertyProvider.properties) {
      for (var unit in prop.units) {
        for (var frac in unit.fractions) {
          if (frac.ownerId != null && clientIds.contains(frac.ownerId)) {
            totalFractionsSold++;
            totalSalesVolume += unit.fractionPrice;
            myEarnings += (unit.fractionPrice * 0.10); // 10% commission
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Partner,', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          Text('${user.name} 🤝', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 32),

          // Main Earnings Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: partnerAccent,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: partnerAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Commission Earned', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('\$${myEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('From $totalFractionsSold Client Purchases', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Volume', '\$${(totalSalesVolume / 1000).toStringAsFixed(1)}K', Icons.trending_up_rounded, const Color(0xFF22C55E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Active Clients', '${directClients.length}', Icons.groups_rounded, const Color(0xFF6366F1)),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Your Referral Code
          Text('My Referral Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 8),
          Text('Share this code with clients. You earn 10% on every fraction they buy.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(user.myReferralCode, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: partnerAccent)),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: user.myReferralCode));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard! 📋')));
                    }
                  },
                  icon: Icon(Icons.copy_rounded, color: Colors.grey.shade600),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
        ],
      ),
    );
  }

  // ==========================================
  // 👥 2. CLIENTS TAB
  // ==========================================
  Widget _buildClientsTab(AppUser user, AuthProvider authProvider) {
    final directClients = authProvider.getDownline(user.myReferralCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Clients 👥', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Tap a client to view their real estate portfolio.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          
          if (directClients.isEmpty)
             Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Icon(Icons.group_off_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No Clients Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  Text('Share your referral code to start building your network!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: directClients.length,
              itemBuilder: (context, index) {
                final client = directClients[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ClientPortfolioScreen(user: client)));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: const Color(0xFFDCFCE7), child: const Icon(Icons.person_rounded, color: Color(0xFF22C55E))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark)),
                              const SizedBox(height: 4),
                              Text(client.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 🏢 3. PROPERTIES TAB (Asset Catalog)
  // ==========================================
  Widget _buildPropertiesTab(PropertyProvider propertyProvider) {
    final properties = propertyProvider.properties;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Asset Catalog 🏢', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Browse available properties to pitch to your clients.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),

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

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerPropertyDetailsScreen(property: prop, startingPrice: startingPrice)));
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
                          child: prop.imageUrls.isNotEmpty
                              ? (kIsWeb
                                  ? Image.network(prop.imageUrls.first, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildFallbackBanner())
                                  : Image.file(File(prop.imageUrls.first), fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildFallbackBanner()))
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
                                  Text(prop.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: partnerAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                    child: Text('10% Comm.', style: TextStyle(color: partnerAccent, fontWeight: FontWeight.w900, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(prop.location, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('Fractions from \$${startingPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(child: Icon(Icons.landscape_rounded, size: 64, color: Colors.grey.shade300)),
    );
  }
}