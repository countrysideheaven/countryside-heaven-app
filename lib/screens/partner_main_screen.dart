import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For copy to clipboard
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_user.dart';

class PartnerMainScreen extends StatefulWidget {
  const PartnerMainScreen({Key? key}) : super(key: key);

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color partnerAccent = const Color(0xFF6366F1); // Indigo for Partners
  final Color vibrantAccent = const Color(0xFFFF5E5E);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // If user is null (logged out), the wrapper in main.dart handles the redirect, 
    // but we return an empty box here just to be safe during the transition.
    if (user == null) return const SizedBox.shrink();

    // Get only the people invited by THIS partner
    final myTeam = authProvider.getDownline(user.myReferralCode);

    final List<Widget> screens = [
      _buildDashboardContent(user, myTeam, context),
      const Center(child: Text('🏡 Properties Coming Soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      const Center(child: Text('💰 Earnings Coming Soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
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
            Text('Partner Portal', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: textDark),
            onPressed: () {
              // Smooth logout
              authProvider.logout();
            },
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
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade600,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.landscape_rounded), label: 'Assets'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(AppUser user, List<AppUser> myTeam, BuildContext context) {
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text('Welcome back,', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            Text('${user.name} 🚀', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
            const SizedBox(height: 32),

            // Giant Referral Code Card
            _buildReferralCard(user.myReferralCode, context),
            const SizedBox(height: 32),

            // Quick Stats Bento Box
            Text('Your Performance 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBentoCard('Network Size', '${myTeam.length}', 'Active', partnerAccent, Colors.white),
                _buildBentoCard('Commission', '\$4,250', 'This Month', const Color(0xFFDCFCE7), const Color(0xFF22C55E)),
                _buildBentoCard('Fractions Sold', '18', '+3 this week', const Color(0xFFFEF08A), const Color(0xFFCA8A04)),
                _buildBentoCard('Conversion', '12%', 'High', const Color(0xFFFFE0E0), vibrantAccent),
              ],
            ),
            const SizedBox(height: 40),

            // Network List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Network 🌳', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                TextButton(
                  onPressed: () {}, // Future: View full network tree
                  child: Text('View All', style: TextStyle(color: partnerAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (myTeam.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.group_add_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Your network is empty!', style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16)),
                      Text('Share your referral code to start building.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myTeam.length,
                itemBuilder: (context, index) {
                  final teamMember = myTeam[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: partnerAccent.withOpacity(0.1),
                          child: Icon(Icons.person_rounded, color: partnerAccent),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(teamMember.name, style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16)),
                              Text(
                                teamMember.role == UserRole.customer ? 'Client' : 'Sales Agent', 
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(String code, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: textDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: partnerAccent.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.tag_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Your Referral Code', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(code, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Code copied to clipboard! 📋', style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: partnerAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), padding: const EdgeInsets.all(12)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(String title, String value, String subtitle, Color bgColor, Color textColor) {
    bool isDark = bgColor == partnerAccent || bgColor == textDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark) BoxShadow(color: bgColor.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 8)),
          if (isDark) BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : textColor.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w700)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : textDark, letterSpacing: -1)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : textDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}