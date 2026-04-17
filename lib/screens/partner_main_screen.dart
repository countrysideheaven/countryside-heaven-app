import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../models/app_user.dart';
import '../models/property_models.dart';

import 'admin/client_portfolio_screen.dart'; 
import 'customer/customer_property_details_screen.dart';
import 'shared/marketing_hub_screen.dart';

class PartnerMainScreen extends StatefulWidget {
  const PartnerMainScreen({Key? key}) : super(key: key);

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color partnerAccent = const Color(0xFF8B5CF6);

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
            
            // 👉 NEW: Company Name with Subtext (Wrapped in Flexible to prevent overflow)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Countryside Heaven',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w900, 
                      color: Color(0xFF111111), 
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Partner Hub',
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w800, 
                      color: partnerAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.campaign_rounded, color: partnerAccent),
            tooltip: 'Marketing Materials',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketingHubScreen()));
            },
          ),
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
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Earnings'),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Clients'),
              BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Assets'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. EARNINGS DASHBOARD TAB
  // ==========================================
  Widget _buildDashboardTab(AppUser user, AuthProvider authProvider, PropertyProvider propertyProvider) {
    final directClients = authProvider.getDownline(user.myReferralCode);
    final clientIds = directClients.map((u) => u.id).toList();

    int totalFractionsSold = 0;
    double totalSalesVolume = 0.0;
    double myEarnings = 0.0;

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
                Text('₹${myEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
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

          Row(
            children: [
              Expanded(child: _buildStatCard('Total Volume', '₹${(totalSalesVolume / 1000).toStringAsFixed(1)}K', Icons.trending_up_rounded, const Color(0xFF22C55E))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Active Clients', '${directClients.length}', Icons.groups_rounded, const Color(0xFF6366F1))),
            ],
          ),
          const SizedBox(height: 40),

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
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard! 📋')));
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
        ],
      ),
    );
  }

  // ==========================================
  // 2. CLIENTS TAB
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
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
  // 3. PROPERTIES TAB
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 10))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: prop.imageUrls.isNotEmpty
                              // 👉 FIXED: Always use Image.network because R2 URLs are web links!
                              ? Image.network(
                                  prop.imageUrls.first, 
                                  fit: BoxFit.cover, 
                                  errorBuilder: (context, error, stackTrace) => _buildFallbackBanner(),
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
                              Text('Fractions from ₹${startingPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark)),
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
    return Container(color: Colors.grey.shade100, child: Center(child: Icon(Icons.landscape_rounded, size: 64, color: Colors.grey.shade300)));
  }

  // ==========================================
  // 4. THE PROFILE TAB (With Branding Setup)
  // ==========================================
  Widget _buildProfileTab(AppUser user, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Profile ⚙️', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
          const SizedBox(height: 32),
          
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50, 
                  backgroundColor: partnerAccent.withOpacity(0.2), 
                  child: Text(user.name[0].toUpperCase(), style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: partnerAccent)),
                ),
                const SizedBox(height: 16),
                Text(user.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                Text(user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 40),

          Text('Partner Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 16),

          _buildProfileOption(
            Icons.brush_rounded, 
            'Co-Branding Details', 
            'Set your logo, company name, and phone', 
            color: partnerAccent,
            onTap: () => _showBrandingSetupDialog(context, user)
          ),
          _buildProfileOption(
            Icons.account_balance_rounded, 
            'Payout Method', 
            'Manage where your commissions are sent', 
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout settings coming soon!')));
            }
          ),
          _buildProfileOption(
            Icons.logout_rounded, 
            'Log Out', 
            'Securely sign out', 
            color: Colors.red, 
            onTap: () => authProvider.logout()
          ),
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

  void _showBrandingSetupDialog(BuildContext context, AppUser user) {
    final companyNameCtrl = TextEditingController(text: user.companyName ?? "${user.name} Real Estate"); 
    final phoneCtrl = TextEditingController(text: user.phoneNumber ?? ""); 
    Uint8List? logoBytes;
    String? logoName;
    bool isSaving = false;

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
                    Text('Co-Branding Setup 🎨', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                    const SizedBox(height: 8),
                    Text('These details will be stamped on your marketing materials.', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 32),

                    TextField(
                      controller: companyNameCtrl,
                      decoration: InputDecoration(labelText: 'Company Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), prefixIcon: const Icon(Icons.business_rounded)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), prefixIcon: const Icon(Icons.phone_rounded)),
                    ),
                    const SizedBox(height: 24),

                    const Text('Company Logo (Transparent PNG recommended)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                        if (result != null) {
                          setState(() {
                            logoBytes = result.files.first.bytes;
                            logoName = result.files.first.name;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(color: const Color(0xFFF7F7F9), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Icon(logoBytes != null ? Icons.check_circle_rounded : Icons.add_photo_alternate_rounded, size: 40, color: logoBytes != null ? partnerAccent : Colors.grey),
                            const SizedBox(height: 12),
                            Text(logoBytes != null ? logoName! : 'Upload Logo', style: TextStyle(fontWeight: FontWeight.bold, color: logoBytes != null ? partnerAccent : textDark)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: isSaving ? null : () async {
                          setState(() => isSaving = true);
                          
                          try {
                            final authProv = Provider.of<AuthProvider>(context, listen: false);
                            await authProv.updateBrandingDetails(companyNameCtrl.text, phoneCtrl.text);
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Branding saved successfully! ✅'), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                            setState(() => isSaving = false);
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save. Try again.'), backgroundColor: Colors.red));
                          }
                        },
                        child: isSaving 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Save Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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