import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../models/app_user.dart';
import '../models/property_models.dart';
import 'admin/client_portfolio_screen.dart'; // Reusing this excellent screen
import 'customer/customer_property_details_screen.dart';
import 'package:flutter/services.dart';

class SalesMainScreen extends StatefulWidget {
  const SalesMainScreen({Key? key}) : super(key: key);

  @override
  State<SalesMainScreen> createState() => _SalesMainScreenState();
}

class _SalesMainScreenState extends State<SalesMainScreen> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color salesAccent = const Color(0xFFCA8A04); // Yellow/Gold for Sales
  final Color vibrantAccent = const Color(0xFFFF5E5E);

  // Helper to recursively get ALL downlines (Direct + Partners' Clients)
  List<AppUser> _getAllDownlines(AppUser root, AuthProvider provider) {
    List<AppUser> all = [];
    List<AppUser> direct = provider.getDownline(root.myReferralCode);
    all.addAll(direct);
    for (var child in direct) {
      all.addAll(_getAllDownlines(child, provider)); // Recursive call
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox.shrink();

    final List<Widget> screens = [
      _buildDashboardTab(user, authProvider, propertyProvider),
      _buildNetworkTab(user, authProvider),
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
              decoration: BoxDecoration(color: salesAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.headset_mic_rounded, color: salesAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Sales Hub', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
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
            selectedItemColor: salesAccent,
            unselectedItemColor: Colors.grey.shade600,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
              BottomNavigationBarItem(icon: Icon(Icons.account_tree_rounded), label: 'Network'),
              BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Assets'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 📊 1. DASHBOARD TAB
  // ==========================================
  Widget _buildDashboardTab(AppUser user, AuthProvider authProvider, PropertyProvider propertyProvider) {
    final allDownlines = _getAllDownlines(user, authProvider);
    final downlineIds = allDownlines.map((u) => u.id).toList();

    int totalNetworkSales = 0;
    double totalNetworkVolume = 0.0;
    double myEstimatedCommission = 0.0;

    // Calculate Sales
    for (var prop in propertyProvider.properties) {
      for (var unit in prop.units) {
        for (var frac in unit.fractions) {
          if (frac.ownerId != null && downlineIds.contains(frac.ownerId)) {
            totalNetworkSales++;
            totalNetworkVolume += unit.fractionPrice;
            myEstimatedCommission += (unit.fractionPrice * 0.10); // Assuming 5% commission
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          Text('${user.name} 🚀', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 32),

          // Main Earnings Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: textDark,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: textDark.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Commissions', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('\$${myEstimatedCommission.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('From $totalNetworkSales Network Sales', style: TextStyle(color: salesAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Volume', '\$${(totalNetworkVolume / 1000).toStringAsFixed(1)}K', Icons.trending_up_rounded, salesAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Team Size', '${allDownlines.length}', Icons.groups_rounded, const Color(0xFF6366F1)),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Your Referral Code
          Text('My Referral Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(user.myReferralCode, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: salesAccent)),
                IconButton(
  onPressed: () async {
    // 1. Actually copy the text to the system clipboard
    await Clipboard.setData(ClipboardData(text: user.myReferralCode));
    
    // 2. Then show the success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied to clipboard! 📋')),
      );
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
  // 🌳 2. NETWORK TAB (The Interactive Tree)
  // ==========================================
  Widget _buildNetworkTab(AppUser user, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Network 🌳', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Tap any client to view their real estate portfolio.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          
          // Render the tree rooted at the Sales Agent
          _SalesNetworkNode(
            user: user,
            provider: authProvider,
            isRoot: true,
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
          Text('Browse available properties to share with your clients.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
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
                                    decoration: BoxDecoration(color: salesAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                    child: Text('10% Comm.', style: TextStyle(color: salesAccent, fontWeight: FontWeight.w900, fontSize: 12)),
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

// ==========================================
// 🌳 THE INTERACTIVE NETWORK NODE WIDGET
// ==========================================
class _SalesNetworkNode extends StatefulWidget {
  final AppUser user;
  final AuthProvider provider;
  final bool isRoot;

  const _SalesNetworkNode({
    Key? key,
    required this.user,
    required this.provider,
    this.isRoot = false,
  }) : super(key: key);

  @override
  State<_SalesNetworkNode> createState() => _SalesNetworkNodeState();
}

class _SalesNetworkNodeState extends State<_SalesNetworkNode> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isRoot; // Expand the root agent by default
  }

  @override
  Widget build(BuildContext context) {
    final downlines = widget.provider.getDownline(widget.user.myReferralCode);
    final hasTeam = downlines.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tapping the whole card navigates to the Portfolio Screen (Unless it's the Agent themselves)
        GestureDetector(
          onTap: () {
            if (!widget.isRoot) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientPortfolioScreen(user: widget.user)),
              );
            }
          }, 
          child: _buildUserCard(widget.user, downlines.length, isRoot: widget.isRoot, hasTeam: hasTeam),
        ),
        
        // 2. The Animated Branch
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: (!hasTeam || !_isExpanded)
              ? const SizedBox(width: double.infinity) 
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 28),
                        width: 3,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: downlines.map((childUser) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: _SalesNetworkNode(
                                user: childUser,
                                provider: widget.provider,
                                isRoot: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(AppUser user, int downlineCount, {bool isRoot = false, required bool hasTeam}) {
    final vibrantAccent = const Color(0xFFFF5E5E);
    final textDark = const Color(0xFF111111);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRoot ? textDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isRoot) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
          if (isRoot) BoxShadow(color: textDark.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isRoot ? Colors.white.withOpacity(0.1) : const Color(0xFFE0E7FF),
            child: Icon(_getRoleIcon(user.role), color: isRoot ? Colors.white : const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(isRoot ? "You" : user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isRoot ? Colors.white : textDark)),
                    _buildRoleTag(user.role),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Code: ${user.myReferralCode}', style: TextStyle(fontSize: 13, color: isRoot ? Colors.white70 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Interactive Downline Pill - Tapping this expands/collapses the tree
          if (hasTeam)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: isRoot ? vibrantAccent.withOpacity(0.2) : const Color(0xFFDCFCE7), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text('$downlineCount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isRoot ? vibrantAccent : const Color(0xFF22C55E), height: 1)),
                        Text('Team', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isRoot ? vibrantAccent : const Color(0xFF22C55E))),
                      ],
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0, 
                      duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: isRoot ? vibrantAccent : const Color(0xFF22C55E)),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildRoleTag(UserRole role) {
    String label = '';
    Color color = Colors.grey;
    final vibrantAccent = const Color(0xFFFF5E5E);
    
    switch (role) {
      case UserRole.admin: label = 'Admin'; color = vibrantAccent; break;
      case UserRole.channelPartner: label = 'Partner'; color = const Color(0xFF6366F1); break;
      case UserRole.salesAgent: label = 'Sales'; color = const Color(0xFFCA8A04); break;
      case UserRole.customer: label = 'Client'; color = const Color(0xFF22C55E); break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin: return Icons.security_rounded;
      case UserRole.channelPartner: return Icons.handshake_rounded;
      case UserRole.salesAgent: return Icons.headset_mic_rounded;
      case UserRole.customer: return Icons.person_rounded;
    }
  }
}